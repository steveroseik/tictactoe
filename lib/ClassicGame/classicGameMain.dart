import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:sizer/sizer.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/Controllers/classicGameController.dart';
import 'package:tictactoe/coinToss.dart';
import 'package:tictactoe/objects/classicObjects.dart';
import 'package:tictactoe/ClassicGame/classicGameModule.dart';

import '../Configurations/constants.dart';
import '../UIUX/customWidgets.dart';
import '../UIUX/themesAndStyles.dart';

class ClassicGameMain extends StatefulWidget {
  final Socket? socket;
  final Function(GameWinner, bool)? gameStateChange;
  final bool inTournament;
  final bool speedMatch;


  const ClassicGameMain({super.key,
    this.socket,
    this.gameStateChange,
    this.speedMatch = false,
    this.inTournament = false
  });

  @override
  State<ClassicGameMain> createState() => _ClassicGameMainState();
}

class _ClassicGameMainState extends State<ClassicGameMain> {


  late Socket socket;

  ValueNotifier<GameState> currentState = ValueNotifier(GameState.connecting);

  ClassicRoom? roomInfo;

  int gameStartsIn = 0;

  DateTime? gameStartTime;

  String uid = '';

  late Timer gameTimer;

  ClassicGameController? gameController;

  bool oppConnected = true;
  bool gotDisconnected = false;
  bool canLeave = true;

  bool speedMatch = false;

  int theLuckyWinner = -1;

  int speedCount = 0;

  @override
  void initState() {
    speedMatch = widget.speedMatch;
    initSocket();
    initGameTimer();

    super.initState();
  }

  @override
  void dispose() {
    print('canceled');
    super.dispose();
    socket.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<GameState>(
        valueListenable: currentState,
        builder: (context, value, child) {
          return Stack(
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
              AnimatedOpacity(
                  opacity: (speedMatch &&
                      (value == GameState.started || value == GameState.paused)) ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
              child: const BackgroundScroller(),),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child,),
                child:(speedMatch &&
                    (value == GameState.started || value == GameState.paused)) ? SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset('assets/speed_match.png', width: 80.w,),
                  ),
                ) : Container(),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: value != GameState.started && value != GameState.paused ?
                      viewMiddleWidget(value) : ClassicGameModule(
                          key: const Key('classicGamePageKey'),
                          controller: gameController!,
                          gameStateChanged: (winner, iWon){

                          },
                          socket: socket),),
                  ],
                ),
              ),
              if (value != GameState.starting) SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    child: Text('Leave'),
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
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

  initSocket(){
    if (widget.socket != null){
      socket = widget.socket!;

    }else{
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
          socket.emitWithAck('reJoin', gameController?.rejoin(), ack: (data){
            print(data);
            if (data['success'] == true){
              setState(() {
                if (data['other'] == true) oppConnected = true;
              });
              gameController?.getBackOnline(data['other']);
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
        gameController?.setOppConnection(GameConn.offline);

      }else if(data['type'] == 'connect'){
        setState(() {
          oppConnected = true;
        });
        gameController?.setOppConnection(GameConn.online, clientId: data['clientId']);
      }
    });


    socket.on('gameListener', (data) {

      print('got data: ${jsonEncode(data)}');

      switch(data['type']){

        case 'gameInit': gameInitAction(data);
        break;
        case 'classicAction': gameClassicAction(data);
        break;
        case 'classicValidation': gameClassicValidation(data);
        break;
        case 'gameConnectionOff': gameEndedWithDisconnect(data);
        break;
        case 'switchToSpeed': startSpeedMatch(data);
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
            gameController!.hasListeners) gameController?.gotOffline();
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
    return endTime.subtract(Const.classicGameDuration);
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
    gameController?.didIWin(theLuckyWinner);
  }

  gameInitAction(Map<String, dynamic> data, {bool speedMatch = false}){

    setState(() {
      canLeave = false;
      this.speedMatch = speedMatch;
    });


    if (!speedMatch){
      roomInfo = ClassicRoom.fromResponse(data['roomInfo']);
      gameStartTime = calculateGameStartTime(roomInfo!.sessionEnd);
    }else{
      roomInfo!.sessionEnd = DateTime.now().add(const Duration(seconds: 3 + (Const.speedRoundDuration * 9)));
      gameStartTime = DateTime.now().add(const Duration(seconds: 3));
    }



    print(gameStartTime);
    gameStartsIn = gameStartTime!.difference(DateTime.now()).inSeconds;

    print(gameStartsIn);

    currentState.value = GameState.starting;

    print(roomInfo!.lastHash);
    Timer.periodic(gameStartTime!.difference(DateTime.now()), (timer){
      gameController = ClassicGameController(
          roomInfo: roomInfo!,
          speedMatch: speedMatch,
          currentState: currentState, uid: uid);
      currentState.value = gameController!.setState(GameState.started);
      timer.cancel();});
  }

  gameClassicValidation(data){
    if (data['success'] != true){
      print('YOU ARE CHEATING!!');
      Navigator.of(context).pop();
    }else{
      gameController?.moveValidated(data: data);
      checkWin();
    }
  }

  checkWin(){
    if (gameController?.state == GameState.ended){
      if (gameController?.winner == GameWinner.draw
          && gameController?.isMyTurn){
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
    }
  }

  gameClassicAction(Map<String, dynamic> data){
    int? move = data['move'];
    String? hash = data['hash'];

    if (move != null && hash != null){
      final resp = gameController?.validateMove(move, hash);
      socket.emitWithAck('gameListener', resp, ack: (data){
        gameController?.moveValidated();
        checkWin();
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
    socket.emitWithAck('joinClassic',  {
      'token': 'classic.1.$uid'
    }, ack:  (response) {
      if (response['success'] == true){
        if (currentState.value == GameState.connecting) currentState.value = GameState.waiting;
      }else{
        print('failed');
        Navigator.of(context).pop();
      }
    });
  }


  Widget viewMiddleWidget(GameState value){
    switch (value){
      case GameState.starting:
      case GameState.waiting:
      case GameState.connecting:
        if (value == GameState.starting && speedMatch){
          return StartingSpeedMatch();
        }else{
          return Column(
            key: Key('Classdj2!###kjds'),
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
        }
      case GameState.coinToss:
        return CoinToss(onEnd: onCoinTossEnd);
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
}
