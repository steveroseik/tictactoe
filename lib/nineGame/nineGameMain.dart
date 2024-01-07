import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/Controllers/classicGameController.dart';
import 'package:tictactoe/Controllers/constants.dart';
import 'package:tictactoe/UIUX/themesAndStyles.dart';
import 'package:tictactoe/objects/classicObjects.dart';
import '../UIUX/customWidgets.dart';
import '../ClassicGame/classicGameModule.dart';
import '../spritesConfigurations.dart';



class NineGameMain extends StatefulWidget {
  final Socket? socket;
  final bool inTournament;
  const NineGameMain({super.key, this.inTournament = false, this.socket});

  @override
  State<NineGameMain> createState() => _NineGameMainState();
}

class _NineGameMainState extends State<NineGameMain> with TickerProviderStateMixin{

  late AnimationController animationController;
  late Animation animation;
  late AnimationController focusController;
  late Animation focusAnimation;

  List<Widget> nineGames = [];
  double gridSize = 90.w;

  List<int> focusedGrid = [];
  int selectedIndex = -1;
  Alignment startFrom = Alignment.topLeft;

  Alignment setStartPoint(int index){
    late Alignment ret;
    switch(index){
      case 0 : ret = Alignment.topLeft;
        break;
      case 1 : ret = Alignment.topCenter;
        break;
      case 2 : ret = Alignment.topRight;
        break;
      case 3 : ret = Alignment.centerLeft;
        break;
      case 4 : ret = Alignment.center;
        break;
      case 5 : ret = Alignment.centerRight;
        break;
      case 6 : ret = Alignment.bottomLeft;
        break;
      case 7 : ret = Alignment.bottomCenter;
        break;
      case 8 : ret = Alignment.bottomRight;
        break;
    }
    return ret;
  }

  late Socket socket;

  ValueNotifier<GameState> currentState = ValueNotifier(GameState.connecting);

  ClassicRoom? roomInfo;

  int gameStartsIn = 0;

  DateTime? gameStartTime;

  String uid = '';

  double _progress = 0.0;

  late Timer gameTimer;

  int nextGridPlay = -1;

  late Widget opponentCharacter;
  late Widget myCharacter;

  Timer? timeoutTimer;


  ClassicGameController? gameController;

  bool oppConnected = true;
  bool gotDisconnected = false;
  bool canLeave = true;

  @override
  void initState() {
    initSocket();

    animationController = AnimationController(duration: const Duration(milliseconds: 3000), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController);

    focusController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    focusAnimation = CurvedAnimation(parent: focusController, curve: Curves.easeInOut);


    opponentCharacter = Sprites.characterOf[characters.angryPig]!;
    myCharacter = Sprites.characterOf[characters.chameleon]!;


    runTimeoutTimer();

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (gameStartsIn <= 0){
        if (roomInfo != null && roomInfo!.sessionEnd.isAfter(DateTime.now())){
          timer.cancel();
        }
      }else{
        setState(() {
          gameStartsIn--;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    focusController.dispose();
    super.dispose();
    socket.disconnect();
    timeoutTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        setState(() {
         selectedIndex = -1;
        });
        if (focusController.isCompleted){
          focusController.reverse();
        }
      },
      child: ValueListenableBuilder<GameState>(
        valueListenable: currentState,
        builder: (context, state, child) {
          return Scaffold(
            body: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.deepOrange,
                            Colors.deepOrange,
                            Colors.deepPurple.shade800
                          ])),
                ),
                const BackgroundScroller(),
                Center(
                  child:
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: state != GameState.started && state != GameState.paused
                        && state != GameState.ended ? Column(
                      key: Key('Classdj2!###kjds'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        state == GameState.connecting ? const Text("Connecting...")
                            : state == GameState.starting ? Text("Starting in $gameStartsIn..") : const Text("Waiting for opponent..."),
                        SizedBox(height: 30),
                        SizedBox(
                            width: 50.w,
                            child: LoadingWidget(circular: true, scaleFactor: 12))
                      ],
                    ) : ChangeNotifierProvider<ClassicGameController>(
                      create: (context) => gameController!,
                      child: Consumer<ClassicGameController>(
                        builder: (context, controller, child) {
                          return AnimatedBuilder(
                              animation: Listenable.merge([animationController, focusController]),
                              builder: (context, child) {
                                List<Widget> lines = [];
                                createGridLines(
                                    gridSize, gridSize, 3, 3, lines,
                                    colorDarkBlue, animationController,
                                    thickness: 4);
                                return Stack(

                                  children: [
                                    SafeArea(
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: IconButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          icon: Icon(CupertinoIcons.back),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                          height: gridSize,
                                          width: gridSize,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            gradient: const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [Colors.purple, Colors.green]
                                            )
                                          ),
                                          child: Stack(
                                            children: [
                                              ...lines,
                                              GridView.builder(
                                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                                                  shrinkWrap: true,
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  padding: EdgeInsets.zero,
                                                  itemCount: 9,
                                                  itemBuilder: (context, index){
                                                    return Transform(
                                                      transform: Matrix4.identity()
                                                        ..scale(selectedIndex == index ? 1 + (focusController.value/2) : 1.0),
                                                      alignment: setStartPoint(index),
                                                      child: Opacity(
                                                        opacity: selectedIndex == index ? 1 - focusController.value : 1,
                                                        child: GestureDetector(
                                                            behavior: HitTestBehavior.opaque,
                                                            onTap: () async{
                                                              print('leh msh tapped');
                                                              focusedGrid = controller.grid[index];
                                                              setState(() {
                                                                selectedIndex = index;
                                                                startFrom = setStartPoint(index);
                                                              });
                                                              focusController.forward();
                                                              print('tapped: $selectedIndex');
                                                            },
                                                            child: IgnorePointer(
                                                                ignoring: true,
                                                                child: Stack(
                                                                  children: [
                                                                    if (controller.nineWins[index] == -1) nineGames[index],
                                                                    Positioned.fill(child:
                                                                    (controller.nineWins[index] != -1) ? (controller.nineWins[index] == 1) ?
                                                                    myCharacter : opponentCharacter : Container())
                                                                  ],
                                                                ))),
                                                      ),
                                                    );
                                                  }),
                                              Transform(
                                                transform: Matrix4.identity()
                                                  ..scale(0.3 + (focusController.value * 0.7)),
                                                alignment: startFrom,
                                                child: Visibility(
                                                  visible: focusController.value*4 > 0.25 ? true : false,
                                                  child: Opacity(
                                                    opacity: focusController.value*4 > 1 ? 1 : focusController.value*4,
                                                    child: Center(
                                                      child: Transform(
                                                        transform: Matrix4.identity()
                                                          ..scale(1.0),
                                                        child: Builder(
                                                            builder: (context) {
                                                              List<Widget> lines = [];
                                                              createGridLines(
                                                                  gridSize, gridSize, 3, 3, lines,
                                                                  Colors.lightBlueAccent, animationController,
                                                                  thickness: 3);
                                                              return Container(
                                                                height: gridSize,
                                                                width: gridSize,
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    gradient: const LinearGradient(
                                                                        begin: Alignment.topLeft,
                                                                        end: Alignment.bottomRight,
                                                                        colors: [Colors.purple, Colors.green]
                                                                    )
                                                                ),
                                                                child: Stack(
                                                                  children: [
                                                                    ...lines,
                                                                    GridView.builder(
                                                                        gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                                                                        itemCount: 9,
                                                                        padding: EdgeInsets.zero,
                                                                        physics: const NeverScrollableScrollPhysics(),
                                                                        shrinkWrap: true,
                                                                        itemBuilder: (context, index){
                                                                          return GestureDetector(
                                                                            behavior: HitTestBehavior.opaque,
                                                                            onTap: () async{
                                                                              if (selectedIndex == -1){
                                                                                setState(() {
                                                                                  selectedIndex = -1;
                                                                                });
                                                                                await focusController.reverse();
                                                                                return;
                                                                              }
                                                                              if (controller.isMyTurn && controller.state == GameState.started){
                                                                                if (nextGridPlay == -1 || (controller.nineWins[nextGridPlay] == -1 && selectedIndex == nextGridPlay)
                                                                                || (controller.nineWins[selectedIndex] == -1 && controller.nineWins[nextGridPlay] != -1)){
                                                                                  if (selectedIndex != -1){
                                                                                    final resp = controller.setManualMove((selectedIndex, index), myPlay: true);

                                                                                    if (resp != null){
                                                                                      socket.emitWithAck('gameListener', resp, ack: (data){
                                                                                        // nothin
                                                                                      });
                                                                                    }
                                                                                    setState(() {
                                                                                      selectedIndex = -1;
                                                                                    });
                                                                                    await Future.delayed(const Duration(milliseconds: 400));
                                                                                    await focusController.reverse();
                                                                                  }else{
                                                                                    print('??');
                                                                                  }
                                                                                }

                                                                              }

                                                                            },
                                                                            child: focusedGrid.isNotEmpty ? Container(
                                                                              margin: const EdgeInsets.all(10),
                                                                              child: focusedGrid[index] == 0 ? myCharacter :
                                                                              focusedGrid[index] == 1 ? opponentCharacter : Container(),
                                                                            ) : Container(),
                                                                          );
                                                                        }),
                                                                  ],
                                                                ),
                                                              );
                                                            }
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                      ),
                                    ),
                                    SafeArea(
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: ElevatedButton(
                                          onPressed: (){
                                            setState(() {});
                                          },
                                          child: const Text('RESET'),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              }
                          );
                        }
                      ),
                    ))
                  ,
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  initSocket(){
    if (widget.socket != null){
      socket = widget.socket!;

    }else{
      /// 172.20.10.5
      /// 169.254.201.45
      socket = io(Const.gameServerUrl,
          OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .enableForceNewConnection()
              .build());

      socket.connect();
    }


    socket.onConnect((_) async{
      print("Connection established : ${socket.id}");
      if (gotDisconnected){
        gotDisconnected = false;
        if (gameController != null){
          socket.emitWithAck('reJoin', gameController!.rejoin(), ack: (data){
            print(data);
            if (data['success'] == true){
              setState(() {
                if (data['other'] == true) oppConnected = true;
              });
              gameController!.getBackOnline(data['other']);
            }
          });
        }else{
          if (!widget.inTournament) requestJoin();
        }
      }else{
        if (!widget.inTournament) requestJoin();
      }
    });

    socket.on('gameConnection', (data) {
      if (data['type'] == 'disconnect'){
        setState(() {
          oppConnected = false;
        });
        gameController!.setOppConnection(GameConn.offline);

      }else if(data['type'] == 'connect'){
        setState(() {
          oppConnected = true;
        });
        gameController!.setOppConnection(GameConn.online, clientId: data['clientId']);
      }
    });


    socket.on('gameListener', (data) {

      // print('got data: ${jsonEncode(data)}');

      switch(data['type']){

        case 'gameInit': gameInitAction(data);
        break;
        case 'nineAction': gameClassicAction(data);
        break;
        case 'nineValidation': gameClassicValidation(data);
        break;
        case 'gameConnectionOff': gameEndedWithDisconnect(data);
        break;
        default: print('lel asaf ${jsonEncode(data)}');
      }

    });

    socket.onDisconnect((_){
      print("Disconnected");
      currentState.value = GameState.connecting;
      if (mounted){
        gotDisconnected = true;
        if (gameController != null &&
            gameController!.hasListeners) gameController!.gotOffline();
      }
    });

    int errorCounter = 0;
    socket.onConnectError((err) {
      if (errorCounter == 4){
        try{
          socket.disconnect();
        }catch (e){
          print(e);
        }
        if (!widget.inTournament) Navigator.of(context).pop();
      }else{
        errorCounter++;
      }
    });

    socket.onError((err)=>print('Socket Error: $err'));
  }

  calculateGameStartTime(DateTime endTime){
    return endTime.subtract(const Duration(minutes: 5));
  }

  gameInitAction(Map<String, dynamic> data){

    setState(() {
      canLeave = false;
    });

    roomInfo = ClassicRoom.fromResponse(data['roomInfo']);

    gameStartTime = calculateGameStartTime(roomInfo!.sessionEnd);


    gameStartsIn = gameStartTime!.difference(DateTime.now()).inSeconds;


    currentState.value = GameState.starting;


    Timer.periodic(gameStartTime!.difference(DateTime.now()), (timer){
      gameController = ClassicGameController(
          roomInfo: roomInfo!,
          currentState: currentState,
          uid: uid,
          gridLength: 9);
      nineGames = List<Widget>
          .generate(9, (index) => ClassicGameModule(
          controller: gameController!, socket: socket,
          isNine: true,
          smallIndex: index,
          gameStateChanged: (s, t){}));
      currentState.value = gameController!.setState(GameState.started);
      timer.cancel();});
  }

  gameClassicValidation(data){
    if (data['success'] != true){
      print('YOU ARE CHEATING!!');
      Navigator.of(context).pop();
    }else{
      gameController!.moveValidated(data: data);
    }
  }

  gameClassicAction(Map<String, dynamic> data){
    int? move = data['move'];
    int? grid = data['grid'];
    String? hash = data['hash'];
    if (move != null && hash != null && grid != null){
      final resp = gameController!.validateMove(move, hash, grid: grid);
      // print("respValida: $resp");
      socket.emitWithAck('gameListener', resp, ack: (data){
        gameController!.moveValidated();
        nextGridPlay = move;
      });

    }
  }

  gameEndedWithDisconnect(Map<String, dynamic> data ){

    if (gameController!.endGameDueConnection(data).$1) {
      print('You won!!');
    }else{
      print('Not the same');
    }
  }

  requestJoin(){
    uid = 'user${Random().nextInt(1000)}';
    socket.emitWithAck('joinNine',  {
      'token': 'nine.1.$uid'
    }, ack:  (response) {
      if (response['success'] == true){
        if (currentState.value == GameState.connecting) currentState.value = GameState.waiting;
      }else{
        print('failed');
        Navigator.of(context).pop();
      }
    });
  }

  runTimeoutTimer() async{
    // await Future.delayed(const Duration(seconds: 3));
    // setState(() {});

    timeoutTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {

      if (gameController != null){
        if (gameController!.state == GameState.ended) {
          timer.cancel();
          return;
        }
        if (gameController!.state == GameState.paused){
          return;
        }
        if (gameController!.timeout == null && _progress != 0) {
          setState(() {
            _progress = 0;
          });
        }else{
          final now = DateTime.now();
          if (gameController!.timeout!.isAfter(now)){
            setState(() {

              final perc = gameController!.timeout!.difference(now).inSeconds / 30;
              _progress = perc > 1 ? 1 : perc < 0 ? 0 : perc;
            });
          }else{
            if (gameController!.isMyTurn){
              final req = gameController!.playRandom(nextGrid: nextGridPlay);
              if (req != null){
                print('played Random');
                socket.emitWithAck('gameListener', req, ack: (data){
                });
              }
            }
            setState(() {
              _progress = 0;
            });
          }
        }
      }

    });
  }
}


