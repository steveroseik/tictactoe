import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/ClassicGame/classicGameModule.dart';
import 'package:tictactoe/UIUX/themesAndStyles.dart';
import 'package:tictactoe/objects/tournamentObject.dart';

import '../Configurations/constants.dart';
import '../objects/classicObjects.dart';
import '../Controllers/classicGameController.dart';
import '../UIUX/customWidgets.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ClassicTournamentRoom extends StatefulWidget {
  const ClassicTournamentRoom({super.key});

  @override
  State<ClassicTournamentRoom> createState() => _ClassicTournamentRoomState();
}

class _ClassicTournamentRoomState extends State<ClassicTournamentRoom> {


  late Socket socket;

  ValueNotifier<GameState> currentState = ValueNotifier(GameState.connecting);

  ValueNotifier<GameState> tourState = ValueNotifier(GameState.connecting);

  ClassicRoom? roomInfo;

  TournamentRoom? tournamentInfo;

  int gameStartsIn = 0;

  DateTime? gameStartTime;

  String uid = '';

  late Timer gameTimer;

  ClassicGameController? gameController;

  bool oppConnected = true;
  bool gotDisconnected = false;
  bool canLeave = true;
  bool wonTournament = false;

  bool speedMatch = false;

  @override
  void initState() {
    initSocket();

    initGameTimer();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    socket.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<GameState>(
          valueListenable: tourState,
          builder: (context, tourValue, child) {
            return ValueListenableBuilder<GameState>(
                valueListenable: currentState,
                builder: (context, gameValue, child) {
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
                            (gameController?.state == GameState.started || gameController?.state == GameState.paused)) ? 0 : 1,
                        duration: const Duration(milliseconds: 300),
                        child: const BackgroundScroller(),),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child,),
                        child:(speedMatch &&
                            (gameController?.state == GameState.started || gameController?.state == GameState.paused)) ? SafeArea(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Image.asset('assets/speed_match.png', width: 80.w,),
                          ),
                        ) : Container(),
                      ),
                      if (gameValue != GameState.starting && gameValue != GameState.started) SafeArea(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: ElevatedButton(
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                            child: Text('Leave \n $uid'),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black)
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: tourValue == GameState.started || tourValue == GameState.ended ?
                                  mainMiddleWidget(gameValue, tourValue)
                                      : tourValue == GameState.starting &&
                                      tournamentInfo?.users != null ?
                                  participantsWidget() : Column(
                                    key: Key('Classdj2!###kjds'),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      tourValue == GameState.connecting ? const Text("Connecting...")
                                          : tourValue == GameState.waiting ? const Text("Finding a tournament...")
                                          : Text("Game Startingz in $gameStartsIn..."),
                                      SizedBox(height: 30),
                                      SizedBox(
                                          width: 50.w,
                                          child: LoadingWidget(circular: true, scaleFactor: 12))
                                    ],
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
            );
          }
      ),
    );
  }

  initSocket(){
    socket = io(Const.gameServerUrl,
        OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableForceNewConnection()
            .build());

    socket.connect();

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
          requestJoin();
        }
      }else{
        requestJoin();
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
        gameController!.setOppConnection(GameConn.online);
      }

    });

    socket.on('gameListener', (data) {

      print(jsonEncode(data));
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

    socket.on('tournamentListener', (data){
      print('tournament: $data');
      if (data['type'] == 'participantsUpdate'){
        if (tournamentInfo == null){
          tournamentInfo = TournamentRoom.fromJson(data);
          tourState.value = GameState.starting;
        }else{
          tournamentInfo!.updateUsers(data['users']);
          setState(() {});
        }
      }else if (data['type'] == 'tournamentEnded'){
        if (data['code'] == 'you_won'){
          wonTournament = true;
          gameController?.setState(GameState.ended);
          tourState.value = GameState.ended;
        }
      }
    });

    socket.onDisconnect((_){
      print("Disconnected");
      // currentState.value = GameState.paused;
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
        Navigator.of(context).pop();
      }else{
        errorCounter++;
      }
    });

    socket.onError((err)=>print('Socket Error: $err'));
  }

  calculateGameStartTime(DateTime endTime){
    return endTime.subtract(const Duration(minutes: 5));
  }

  startSpeedMatch(Map<String, dynamic> data){
    if (gameController?.winner != GameWinner.draw) return;
    final hash = data['hash'];
    if (hash != null && hash == gameController?.roomInfo.lastHash){
      gameInitAction(data, speedMatch: true);
    }else{
      print('error, wrong hash');
    }
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


    gameStartsIn = gameStartTime!.difference(DateTime.now()).inSeconds;


    tourState.value = GameState.started;
    currentState.value = GameState.starting;


    Timer.periodic(gameStartTime!.difference(DateTime.now()), (timer){
      gameController = ClassicGameController(
          roomInfo: roomInfo!,
          speedMatch: speedMatch,
          currentState: currentState, uid: uid);
      currentState.value = gameController!.setState(GameState.started);
      timer.cancel();});
    initGameTimer();
  }

  checkWin(){
    if (gameController?.state == GameState.ended){
      if (gameController?.winner == GameWinner.draw){
        if (gameController?.isMyTurn){
          socket.emitWithAck('gameListener', {
            'type': "switchToSpeed",
            'roomId': gameController?.roomInfo.id,
            'hash': gameController?.roomInfo.lastHash,
          }, ack: (response){
            if (response['success'] == true){
              startSpeedMatch({
                'hash': gameController?.roomInfo.lastHash
              });
            }
          });
        }
      }else{
        if (gameController?.winner != GameWinner.none){
          // cause if if winner might need to join next tournament
          if (!gameController?.iWon){
            tourState.value = GameState.ended;
          }

        }
      }
    }
  }

  gameClassicValidation(data){
    if (data['success'] != true){
      print('YOU ARE CHEATING!!');
      Navigator.of(context).pop();
    }else{
      final resp = gameController!.moveValidated(data: data, tournament: true);
      if (resp != null) {
        sendTournamentUpdate(resp);
      }
      checkWin();
      // if (gameController?.winner != GameWinner.none
      //     && gameController?.winner != GameWinner.draw){
      //   if (!gameController?.iWon){
      //     tourState.value = TState.ended;
      //   }
      // }else{
      //
      // }
    }
  }

  gameClassicAction(Map<String, dynamic> data){
    int? move = data['move'];
    String? hash = data['hash'];
    if (move != null && hash != null){
      final resp = gameController!.validateMove(move, hash);
      socket.emitWithAck('gameListener', resp, ack: (data){
        gameController!.moveValidated();
        checkWin();
        // if (gameController?.winner != GameWinner.none){
        //   if (!gameController?.iWon){
        //     tourState.value = TState.ended;
        //   }
        // }
      });

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

  gameEndedWithDisconnect(Map<String, dynamic> data ){

    final resp = gameController!.endGameDueConnection(data, tournament: true);
    if (resp.$1) {
      // gameController!.setState(GameState.waiting);
      sendTournamentUpdate(resp.$2);
    }else{
      print('Not the same');

    }

  }

  requestJoin(){
    uid = 'user${Random().nextInt(1000)}';
    socket.emitWithAck('joinTournament',  {
      'token': 'classicTournament.1.$uid'
    }, ack:  (response) {
      if (response['success'] == true){
        if(tourState.value == GameState.connecting) tourState.value = GameState.waiting;
      }else{
        print('failed');
        Navigator.of(context).pop();
      }
    });
  }


  sendTournamentUpdate(Map<String, dynamic> data){
    gameController?.setState(GameState.waiting);
    socket.emitWithAck('tournamentListener', data, ack: (response){
      print(response);
      print(gameController?.state);
      if (response['success'] == true){
        if (response['code'] == 'you_won'){
          wonTournament = true;
          gameController?.setState(GameState.ended);
          tourState.value = GameState.ended;
        }else if (response['code'] == 'waiting_for_next_round'){
          gameController?.setState(GameState.waiting);
        }

      }
      /// should handle when response['success'] == false
    });
  }

  Widget participantsWidget(){
    final usersInTour = tournamentInfo!.users;
    return Column(
      children: [
        Container(
          width: 70.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  width: 10, color: colorPurple.withOpacity(0.6),
                  strokeAlign: BorderSide.strokeAlignOutside),
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [colorDarkBlue, colorPurple]
              )
          ),
          padding: EdgeInsets.all(15),
          child: Text("Classic Tournament",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 30,
                color: colorOffWhite),textAlign: TextAlign.center,),
        ),
        SizedBox(height: 30,),
        Container(
          width: 70.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  width: 10, color: colorPurple.withOpacity(0.6),
                  strokeAlign: BorderSide.strokeAlignOutside),
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [colorDarkBlue, colorPurple]
              )
          ),
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Container(
                child: Text("Participants",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20,
                      color: colorOffWhite),),
              ),
              SizedBox(height: 20),
              ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: usersInTour.length,
                itemBuilder: (context, index){
                  final username = usersInTour[index];
                  return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: colorOffWhite
                    ),
                    padding: EdgeInsets.all(10),
                    child: Text(username),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 5,),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(
                      width: 10.w,
                      child: LoadingWidget(circular: true, scaleFactor: 60, color: colorDeepOrange)),
                  SizedBox(width: 10),
                  Text("( ${usersInTour.length} / $publicTournamentCapacity ) players..",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20,
                        color: colorOffWhite),),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget mainMiddleWidget(GameState gValue, GameState tValue){
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child,),
      child: gameWidget(gValue, tValue)
    );
  }

  Widget gameWidget(GameState gValue, GameState tValue){
    return gValue != GameState.started && gValue != GameState.paused ?
    viewMiddleWidget(gValue, tValue)
        : ClassicGameModule(
      key: const Key('classicGamePageKey'),
      controller: gameController!,
      speedMatch: speedMatch,
      socket: socket,
      gameStateChanged: (GameWinner , bool ) {  },);
  }

  Widget viewMiddleWidget(GameState value, GameState tValue){
    switch (value){
      case GameState.starting:
      case GameState.waiting:
      case GameState.connecting:
        if (value == GameState.starting && speedMatch){
          return StartingSpeedMatch();
        }else{
          return Column(
            key: const Key('Cl241!!dj2!###kjds'),
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              value == GameState.connecting ? const Text("Connecting...")
                  : value == GameState.starting ? Text("Starting in $gameStartsIn..")
                  : const Text("Waiting For Next Round.."),
              SizedBox(height: 30),
              SizedBox(
                  width: 50.w,
                  child: LoadingWidget(circular: true, scaleFactor: 12))
            ],
          );
        }
      case GameState.ended:
        return gameEndDialog(tValue);

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
        mainAxisSize: MainAxisSize.min,
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

  Widget gameEndDialog(GameState tValue){
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
          Text(
            tValue == GameState.ended ? 'Tournament Ended' : "Game Ended",
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            gameController?.iWon || wonTournament ? "You Won !" : "You Lost !",
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
                [Colors.red, Colors.red.shade900],
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
                child: Text(gameController?.iWon && wonTournament ? 'Claim Reward' : 'Back To Home',
                  style: TextStyle(color: Colors.black),)),
          )
        ],
      ),
    );
  }

  wonARound(){
    showCustomDialog(context: context, child: Container(
      child: Column(
        children: [
          Text('You Won!'),
          ElevatedButton(onPressed: (){}, child: Text('Next game'))
        ],
      ),
    ));
  }

  void showCustomDialog({required BuildContext context, required Widget child}) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (_, __, ___) {
        return Center(
          child: child,
        );
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: Offset(-1, 0), end: Offset.zero);
        } else {
          tween = Tween(begin: Offset(1, 0), end: Offset.zero);
        }

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }

}