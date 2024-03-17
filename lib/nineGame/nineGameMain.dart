import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/ClassicGame/classicGameMain.dart';
import 'package:tictactoe/ClassicGame/classicWidgets.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/Controllers/classicGameController.dart';
import 'package:tictactoe/Providers/socketProvider.dart';
import 'package:tictactoe/UIUX/themesAndStyles.dart';
import '../UIUX/customWidgets.dart';
import '../ClassicGame/classicGameModule.dart';
import '../objects/powerRoomObject.dart';
import '../spritesConfigurations.dart';



class NineGameMain extends StatefulWidget {
  final bool inTournament;
  final GameRoom? roomInfo;
  final String? uid;
  const NineGameMain({
    super.key,
    this.roomInfo,
    this.inTournament = false,
    this.uid});

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

  bool speedMatch = false;

  int theLuckyWinner = -1;

  int speedCount = 0;

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

  List<StreamSubscription> subscriptions = [];

  @override
  void initState() {

    print(widget.roomInfo?.toJson());
    print(widget.inTournament);
    print(widget.uid);

    animationController = AnimationController(duration: const Duration(milliseconds: 3000), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController);

    focusController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    focusAnimation = CurvedAnimation(parent: focusController, curve: Curves.easeInOut);

    if (widget.uid != null) uid = widget.uid!;

    initSocket();
    runTimeoutTimer();
    initGameTimer();
    super.initState();
  }

 @override
 void dispose() {
   timeoutTimer?.cancel();
   if (!widget.inTournament) {
     animationController.dispose();
     focusController.dispose();
     getIt.get<SocketProvider>().disconnect();
   }
   for (var sub in subscriptions){
     sub.cancel();
   }

   print('leh amlt dispose?????');

  super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child,),
      child: speedMatch ? ClassicGameMain(
        speedMatch: true,
        controller: gameController,
        inTournament: widget.inTournament,
        gameStartsIn: gameStartsIn,
      ) : GestureDetector(
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          viewMiddleWidget(
                              controller: gameController,
                              gameState: state,
                              inTournament: widget.inTournament,
                              speedMatch: speedMatch,
                              gameStartsIn: gameStartsIn,
                              onCoinTossEnd: onCoinTossEnd,
                              onWinButtonClick: (){},
                              tournamentRoundEnded: () {}
                              ),
                        ],
                      )
                          : AnimatedBuilder(
                          animation: Listenable.merge([animationController, focusController]),
                          builder: (context, child) {
                            List<Widget> lines = [];
                            createGridLines(
                                gridSize, gridSize, 3, 3, lines,
                                colorDarkBlue, animationController,
                                thickness: 4);
                            return Padding(
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
                                              AspectRatio(aspectRatio: 1, child: classicOppViewAvatar(opponentCharacter, gameController!.sameAvatar)),
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
                                                                        child: (gameController?.nineWins[index] == gameController!.myIndex) ?
                                                                        myCharacter :
                                                                        (gameController?.nineWins[index] == 1-gameController!.myIndex) ?
                                                                        classicOppViewAvatar(opponentCharacter, gameController!.sameAvatar) : Container()
                                                                        ) : Container())
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
                                                                                child: focusedGrid[index] == gameController!.myIndex ? myCharacter :
                                                                                focusedGrid[index] == 1-gameController!.myIndex ? classicOppViewAvatar(opponentCharacter, gameController!.sameAvatar) : Container(),
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
                                                AspectRatio(aspectRatio: 1, child: myCharacter),
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
      ),
    );
  }

  initSocket(){
    print('INITIALIZING SOCKETTT!!!');
    final socketProvider = getIt.get<SocketProvider>();

    if (widget.inTournament){
      print('wlahe ehna f tournament');
      socket = socketProvider.socket!;
      gameInitAction(null);
    }else{
      print('wlahe ehna MESHHH F tournament');
      socket = socketProvider.connect();
    }


    subscriptions.add(socketProvider.onConnect.stream.listen((_) async{
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
    }));

    subscriptions.add(socketProvider.onGameConnection.stream.listen((data) {
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
    }));


    print('Weselna ablo w hwa magash!!');
    subscriptions.add(socketProvider.onGameListener.stream.listen((data) {

      print('got data from nine games: ${jsonEncode(data)}');

      switch(data['type']){

        case 'gameInit': gameInitAction(data);
        break;
        case 'nineAction': gameClassicAction(data);
        break;
        case 'nineValidation': gameClassicValidation(data);
        break;
        case 'switchToSpeed': startSpeedMatch(data);
        break;
        case 'gameConnectionOff': gameEndedWithDisconnect(data);
        break;
        default: print('lel asaf ${jsonEncode(data)}');
      }

    }));

    subscriptions.add((socketProvider.onDisconnect.stream.listen((_){
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
    })));

    int errorCounter = 0;
    subscriptions.add(socketProvider.onConnectionError.stream.listen((err) {
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
    }));

    subscriptions.add(socketProvider.onError.stream.listen((err)=>print('Socket Error: $err')));
  }

  calculateGameStartTime(DateTime endTime){
    return endTime.subtract(Const.nineGameDuration);
  }

  gameInitAction(Map<String, dynamic>? data, {bool speedMatch = false}){

    setState(() {
      canLeave = false;
    });

    nineGames.clear();
    this.speedMatch = speedMatch;

    if (!speedMatch){
      if(data != null) {
        roomInfo = GameRoom.fromResponse(data['roomInfo']);
      } else {
        roomInfo = widget.roomInfo;
      }
      gameStartTime = calculateGameStartTime(roomInfo!.sessionEnd);
    }else{
      roomInfo!.sessionEnd = DateTime.now().add(const Duration(seconds: 3 + (Const.speedRoundDuration * 9)));
      gameStartTime = DateTime.now().add(const Duration(seconds: 3));

      gameController = ClassicGameController(
          roomInfo: roomInfo!,
          currentState: currentState,
          speedMatch: speedMatch,
          gridLength: speedMatch ? 3 : 9,
          uid: uid
      );
    }


    setCharacter();

    gameStartsIn = gameStartTime!.difference(DateTime.now()).inSeconds;


    currentState.value = GameState.starting;
    setState(() {});
    Timer.periodic(gameStartTime!.difference(DateTime.now()), (timer){
      if (!speedMatch){
        gameController = ClassicGameController(
            roomInfo: roomInfo!,
            currentState: currentState,
            speedMatch: speedMatch,
            gridLength: speedMatch ? 3 : 9,
            uid: uid);
        nineGames = List<ClassicGameModule>
            .generate(9, (index) => ClassicGameModule(
            controller: gameController!, socket: socket,
            isNine: true,
            smallIndex: index,
            gameStateChanged: (s, t){}));
      }
      currentState.value = gameController!.setState(GameState.started);
      timer.cancel();
    });
  }

  setCharacter(){
    print('length:: ${roomInfo?.users.length}');
    final oppChId = roomInfo!.users.firstWhere((element) => element.userId != uid).characterId!;
    final myChId = roomInfo!.users.firstWhere((element) => element.userId == uid).characterId!;
    opponentCharacter = Sprites.characterOf[CharacterType.values[oppChId]]!;
    myCharacter = Sprites.characterOf[CharacterType.values[myChId]]!;
  }

  startSpeedMatch(Map<String, dynamic> data){
    if (gameController?.winner != GameWinner.draw) return;
    final hash = data['hash'];
    final coinWinner = data['coinWinner'];
    if (hash != null
        && hash == gameController?.roomInfo.lastHash
        && coinWinner != null){
      theLuckyWinner = coinWinner ? 1 : 0;
      if (speedMatch){
        /// control speedMatch count
        if (speedCount > 0){
          speedCount++;
          gameInitAction(data, speedMatch: true);
          initGameTimer();
        }else{
          initCoinToss();
        }
      }else{
        gameInitAction(data, speedMatch: true);
        initGameTimer();
      }

    }else{
      print('error, wrong hash');
    }
  }

  initCoinToss(){
    gameController?.setState(GameState.coinToss);
  }

  onCoinTossEnd(){
    final resp = gameController?.didIWin(theLuckyWinner, tournament: widget.inTournament);
    if (resp != null && widget.inTournament){
      Navigator.of(context).pop(resp);
    }
  }

  initGameTimer(){
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
  }

  gameClassicValidation(data){
    if (data['success'] != true){
      print('YOU ARE CHEATING!!');
      Navigator.of(context).pop();
    }else{
      gameController!.moveValidated(data: data);
      checkWin();
    }
  }

  checkWin() async{
    print('CHECKKINNGG WINNN::: ${gameController?.state} :: ${gameController?.winner} ::: ${gameController?.iWon}');
    if (gameController?.state == GameState.ended){
      if (gameController?.winner == GameWinner.draw){
        if (gameController?.isMyTurn){
          await Future.delayed(const Duration(seconds: 3));
          socket.emitWithAck('gameListener', {
            'type': "switchToSpeed",
            'roomId': gameController?.roomInfo.id,
            'hash': gameController?.roomInfo.lastHash,
          }, ack: (response){

            if (response['success'] == true){
              startSpeedMatch({
                'hash': gameController?.roomInfo.lastHash,
                'coinWinner': response['coinWinner']
              });
            }
          });
        }
      }else if (widget.inTournament){
        Navigator.of(context).pop((gameController?.iWon??false) ?
        gameController?.winRequest : null);
      }
    }
  }

  gameClassicAction(Map<String, dynamic> data){
    int? move = data['move'];
    int? grid = data['grid'];
    String? hash = data['hash'];
    if (move != null && hash != null && grid != null){
      final resp = gameController!.validateMove(move, hash, grid: grid);
      print("respValidation: $resp");
      socket.emitWithAck('gameListener', resp, ack: (data){
        print(data);
        gameController!.moveValidated();
        nextGridPlay = move;
        checkWin();
      });
    }
  }

  gameEndedWithDisconnect(Map<String, dynamic> data ){
    final resp = gameController!.endGameDueConnection(data, tournament: widget.inTournament);
    if (resp.$1) {
      if (resp.$2 != null){
        Navigator.of(context).pop(resp.$2);
      }
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
        if (gameController!.timeout == null) {
          if (_progress.value != 0){
            setState(() {
              _progress.value = 0;
            });
          }

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
                print(req);
                print(socket.id);
                socket.emitWithAck('gameListener', req, ack: (data){
                  print(data);
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


