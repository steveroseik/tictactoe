import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/Controllers/classicGameController.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/UIUX/themesAndStyles.dart';
import 'package:tictactoe/objects/classicObjects.dart';
import '../UIUX/customWidgets.dart';
import '../ClassicGame/classicGameModule.dart';
import '../objects/powerRoomObject.dart';
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
  List<ClassicGameModule> nineGames = [];
  double gridSize = 90.w;

  List<int> focusedGrid = [];
  int selectedIndex = -1;
  Alignment startFrom = Alignment.topLeft;

  late Socket socket;

  ValueNotifier<GameState> currentState = ValueNotifier(GameState.connecting);

  GameRoom? roomInfo;

  int gameStartsIn = 0;

  DateTime? gameStartTime;

  String uid = '';

  final ValueNotifier<double> _progress = ValueNotifier(0.0);

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
   timeoutTimer?.cancel();
   socket.disconnect();
   animationController.dispose();
   focusController.dispose();
  super.dispose();
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
                    child: state != GameState.started && state != GameState.paused ?
                    viewMiddleWidget(state)
                        : AnimatedBuilder(
                        animation: Listenable.merge([animationController, focusController]),
                        builder: (context, child) {
                          List<Widget> lines = [];
                          createGridLines(
                              gridSize, gridSize, 3, 3, lines,
                              colorDarkBlue, animationController,
                              thickness: 4);
                          return Stack(

                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3.w),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            height: 6.h,
                                            padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 3.w),
                                            decoration: BoxDecoration(
                                                border: !gameController?.isMyTurn ? Border.all(color: colorLightYellow, width: 0.5.w): null,
                                                borderRadius: BorderRadius.circular(25.sp),
                                                gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: !gameController?.isMyTurn ?
                                                    [Colors.deepOrange, colorPurple]
                                                        : [Colors.deepOrange, Colors.deepOrange.shade900]
                                                )
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('ENEMY', style: TextStyle(
                                                    fontSize: 11.sp,
                                                    fontWeight: FontWeight.w800,
                                                    color: gameController?.isMyTurn ? Colors.grey : Colors.black),),
                                                SizedBox(width: 10.w),
                                                AspectRatio(aspectRatio: 1, child: opponentCharacter),
                                              ],
                                            )),
                                        Expanded(
                                          child: ValueListenableBuilder(
                                              valueListenable: _progress,
                                              builder: (context, progress, child) {
                                                return gameController?.oppConnection == GameConn.offline ?
                                                Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: LinearProgressIndicator(
                                                    color: Colors.purple,
                                                    backgroundColor: Colors.black,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                )
                                                    : AnimatedOpacity(
                                                  duration: const Duration(milliseconds: 200),
                                                  opacity: (!gameController?.isMyTurn && gameController?.winner == GameWinner.none) ?
                                                  progress > 0 ? 1 : 0 : 0,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: LinearPercentIndicator(
                                                      animation: true,
                                                      animateFromLastPercent: true,
                                                      animationDuration: 600,
                                                      progressColor: Colors.purple,
                                                      backgroundColor: Colors.black,
                                                      percent: progress <= 0 ? 1 : progress,
                                                      barRadius: const Radius.circular(20),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 1.h),
                                    if (gameController != null) ChangeNotifierProvider(
                                      create: (context) => gameController,
                                      child: Consumer<ClassicGameController>(
                                        builder: (context, controller, child) {
                                          return Center(
                                            child: Container(
                                                height: gridSize,
                                                width: gridSize,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(20),
                                                  gradient: const LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [colorPurple, colorDeepOrange]
                                                  )
                                                ),
                                                child: Stack(
                                                  children: [
                                                    ...lines,
                                                    if (nineGames.isNotEmpty) GridView.builder(
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
                                                                    focusedGrid = gameController!.grid[index];
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
                                                                          if (gameController?.nineWins[index] == -1) nineGames[index],
                                                                          Positioned.fill(child:
                                                                          (gameController?.nineWins[index] != -1) ? Padding(
                                                                              padding: EdgeInsets.all(2.w),
                                                                          child: (gameController?.nineWins[index] == 1) ?
                                                                          myCharacter : opponentCharacter,) : Container())
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
                                                                                  if (gameController?.isMyTurn && gameController?.state == GameState.started){
                                                                                    if (nextGridPlay == -1 || (gameController?.nineWins[nextGridPlay] == -1 && selectedIndex == nextGridPlay)
                                                                                    || (gameController?.nineWins[selectedIndex] == -1 && gameController?.nineWins[nextGridPlay] != -1)){
                                                                                      if (selectedIndex != -1){
                                                                                        final resp = gameController?.setManualMove((selectedIndex, index), myPlay: true);

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
                                                  ],
                                                )
                                            ),
                                          );
                                        }
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ValueListenableBuilder(
                                              valueListenable: _progress,
                                              builder: (context, progress, child) {
                                                return gameController?.myConnection == GameConn.offline ?
                                                Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: LinearProgressIndicator(
                                                    color: Colors.purple,
                                                    backgroundColor: Colors.black,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                )
                                                    : AnimatedOpacity(
                                                  duration: const Duration(milliseconds: 300),
                                                  opacity: (gameController?.isMyTurn && gameController?.winner == GameWinner.none)
                                                      ? progress > 0 ? 1 : 0 : 0,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: LinearPercentIndicator(
                                                      animation: true,
                                                      animateFromLastPercent: true,
                                                      animationDuration: 600,
                                                      progressColor: Colors.purple,
                                                      backgroundColor: Colors.black,
                                                      percent: (!gameController?.isMyTurn) ? 1 : progress,
                                                      barRadius: const Radius.circular(20),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 300),
                                              height: 6.h,
                                              padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 3.w),
                                              decoration: BoxDecoration(
                                                  border: gameController?.isMyTurn ? Border.all(color: colorLightYellow, width: 0.5.w): null,
                                                  borderRadius: BorderRadius.circular(25.sp),
                                                  gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                      colors: gameController?.isMyTurn ?
                                                      [Colors.deepOrange, colorPurple]
                                                          : [Colors.deepOrange.shade900, Colors.deepOrange.shade900]
                                                  )
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  AspectRatio(aspectRatio: 1, child: opponentCharacter),
                                                  SizedBox(width: 10.w),
                                                  Text('YOU', style: TextStyle(
                                                      fontSize: 11.sp,
                                                      fontWeight: FontWeight.w800,
                                                      color: !gameController?.isMyTurn ? Colors.grey : Colors.black),),
                                                ],
                                              )),
                                        ),
                                      ],
                                    ),
                                  ],
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
                    ))
                  ,
                ),
                SafeArea(
                  child: IconButton(
                      onPressed: () {
                        nineGames.clear();
                        Navigator.of(context).pop();
                      },
                      icon: Icon(CupertinoIcons.left_chevron)
                  ),
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
      print('connection: $data');
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
            gameController!.hasListeners) {
          print('runn success');
          gameController!.gotOffline();
        }
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
    return endTime.subtract(Const.nineGameDuration);
  }

  gameInitAction(Map<String, dynamic> data){

    setState(() {
      canLeave = false;
    });

    roomInfo = GameRoom.fromResponse(data['roomInfo']);

    gameStartTime = calculateGameStartTime(roomInfo!.sessionEnd);


    gameStartsIn = gameStartTime!.difference(DateTime.now()).inSeconds;


    currentState.value = GameState.starting;


    Timer.periodic(gameStartTime!.difference(DateTime.now()), (timer){
      gameController = ClassicGameController(
          roomInfo: roomInfo!,
          currentState: currentState,
          uid: uid,
          gridLength: 9);
      nineGames = List<ClassicGameModule>
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
      'token': 'nine.1.$uid.24'
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
          gameController?.addExtraTime(500);
          return;
        }
        if (gameController!.timeout == null && _progress.value != 0) {
          setState(() {
            _progress.value = 0;
          });
        }else{
          final now = DateTime.now();
          if (gameController!.timeout!.isAfter(now)){
            setState(() {

              final perc = gameController!.timeout!.difference(now).inSeconds / Const.nineRoundDuration;
              _progress.value = perc > 1 ? 1 : perc < 0 ? 0 : perc;
            });
          }else{
            if (gameController!.isMyTurn && mounted){
              final req = gameController!.playRandom(nextGrid: nextGridPlay);
              if (req != null){
                print('played Random');
                socket.emitWithAck('gameListener', req, ack: (data){
                });
              }
            }
            setState(() {
              _progress.value = 0;
            });
          }
        }
      }

    });
  }

  Widget viewMiddleWidget(GameState value){
    switch (value){
      case GameState.starting:
      case GameState.waiting:
      case GameState.connecting:
        return Column(
        key: UniqueKey(),
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          value == GameState.connecting ? const Text("Connecting...")
              : value == GameState.starting ? Text("Starting in $gameStartsIn..")
              : const Text("Searching for an opponent.."),
          SizedBox(height: 30),
          SizedBox(
              width: 50.w,
              child: LoadingWidget(circular: true, scaleFactor: 12))
        ],
      );
      case GameState.ended:
        return gameEndDialog();

      default: return Text('1Should not appear');
    }

  }
  Widget StartingSpeedMatch(){
    return Container(
      width: 80.w,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
            colors: [
              Colors.purple,
              colorPurple
            ]
        ),
        boxShadow: [
          BoxShadow(
              color: colorDarkBlue.withOpacity(0.5),
              offset: Offset(3, 3),
              spreadRadius: 1,
              blurRadius: 3)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text(
            "The Match Ended With Draw!",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Starting Speed Match!",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.w700
            ),
          ),
          Text(
            "$gameStartsIn...",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
          LinearPercentIndicator(
            animationDuration: 1000,
            animation: true,
            animateFromLastPercent: true,
            percent: gameStartsIn/3,
            backgroundColor: colorPurple,
            progressColor: colorDeepOrange,
            barRadius: Radius.circular(20),
          )
        ],
      ),
    );
  }

  Widget gameEndDialog(){
    return Container(
      width: 80.w,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
            colors: [
              Colors.purple,
              colorPurple
            ]
        ),
        boxShadow: [
          BoxShadow(
              color: colorDarkBlue.withOpacity(0.5),
              offset: Offset(3, 3),
              spreadRadius: 1,
              blurRadius: 3)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Game Ended",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            gameController?.iWon ? "You Won !" : "You Lost !",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 35.0,
                fontWeight: FontWeight.w700
            ),
          ),
          SizedBox(height: 3.h),
          GameButton(
            height: 6.h,
            baseDecoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gameController?.iWon ?
                [colorDeepOrange, colorDeepOrange] :
                [Colors.red, colorDeepOrange],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            topDecoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors:  !gameController?.iWon ?
                [colorDeepOrange, colorDeepOrange] :
                [colorLightYellow, colorDeepOrange],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            onPressed: (){},
            aspectRatio: 3/1,
            enableShimmer: false,
            borderRadius: BorderRadius.circular(10),
            child: Center(
                child: Text(gameController?.iWon ? 'Claim Reward' : 'Back To Home',
                  style: TextStyle(color: Colors.black),)),
          )
        ],
      ),
    );
  }

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
}


