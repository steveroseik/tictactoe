import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/UIUX/themesAndStyles.dart';
import 'package:tictactoe/objects/tournamentObject.dart';

import '../objects/classicObjects.dart';
import '../ClassicGame/gamePage.dart';
import '../Controllers/classicGameController.dart';
import '../Controllers/constants.dart';
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

  ValueNotifier<TState> tourState = ValueNotifier(TState.connecting);

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

  @override
  void initState() {
    initSocket();

    startCountDown();
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
    body: ValueListenableBuilder<TState>(
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
                    const BackgroundScroller(),
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
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: tourValue == TState.started ?
                                gameWidget(gameValue)
                                : tourValue == TState.starting &&
                                  tournamentInfo?.users != null ?
                                participantsWidget()
                                : tourValue == TState.ended ?
                                wonTournament ? Container(child: Text('You Won The Tournament'),) :
                                  Container(child: Text('You Lost The Tournament')) : Column(
                              key: Key('Classdj2!###kjds'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                tourValue == TState.connecting ? const Text("Connecting...")
                                    : tourValue == TState.waiting ? const Text("Finding a tournament...")
                                    : Text("Game Starting in $gameStartsIn..."),
                                SizedBox(height: 30),
                                SizedBox(
                                    width: 50.w,
                                    child: LoadingWidget(circular: true, scaleFactor: 12))
                              ],
                            )),
                        ],
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
    socket = io("ws://192.168.1.57:3000",
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
        default: print('lel asaf ${jsonEncode(data)}');
      }

    });

    socket.on('tournamentListener', (data){

      if (data['type'] == 'participantsUpdate'){
        if (tournamentInfo == null){
          tournamentInfo = TournamentRoom.fromJson(data);
          tourState.value = TState.starting;
        }else{
          tournamentInfo!.updateUsers(data['users']);
          setState(() {});
        }
      }else if (data['type'] == 'tournamentEnded'){
        if (data['code'] == 'you_won'){
          wonTournament = true;
          tourState.value = TState.ended;
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

  // send move request
  setMove(Map<String, dynamic> request){

    socket.emitWithAck('gameListener', request, ack: (data) {
      print(data);
    });
  }

  confirmMove(Map<String, dynamic> response){}

  gameInitAction(Map<String, dynamic> data){

    setState(() {
      canLeave = false;
    });

    roomInfo = ClassicRoom.fromResponse(data['roomInfo']);

    gameStartTime = calculateGameStartTime(roomInfo!.sessionEnd);


    gameStartsIn = gameStartTime!.difference(DateTime.now()).inSeconds;


    tourState.value = TState.started;
    currentState.value = GameState.starting;


    Timer.periodic(gameStartTime!.difference(DateTime.now()), (timer){
      gameController = ClassicGameController(
          roomInfo: roomInfo!,
          currentState: currentState, uid: uid);
      currentState.value = gameController!.setState(GameState.started);
      timer.cancel();});
  }

  gameClassicValidation(data){
    if (data['success'] != true){
      print('YOU ARE CHEATING!!');
      Navigator.of(context).pop();
    }else{
      final resp = gameController!.moveValidated(data: data, tournament: true);
      if (resp != null) {
        sendTournamentUpdate(resp);
      }else{
        if (gameController?.winner != GameWinner.none){
          if (!gameController?.iWon){
            tourState.value = TState.ended;
          }
        }
      }
    }
  }

  gameClassicAction(Map<String, dynamic> data){
    int? move = data['move'];
    String? hash = data['hash'];
    if (move != null && hash != null){
      final resp = gameController!.validateMove(move, hash);
      socket.emitWithAck('gameListener', resp, ack: (data){
        gameController!.moveValidated();
        if (gameController?.winner != GameWinner.none){
          if (!gameController?.iWon){
           tourState.value = TState.ended;
          }
        }
      });

    }
  }

  startCountDown(){
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
      gameController!.setState(GameState.waiting);
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
        if(tourState.value == TState.connecting) tourState.value = TState.waiting;
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
      if (response['success'] == true &&
          response['code'] == 'you_won'){

        wonTournament = true;
        tourState.value = TState.ended;
        // gameController?.setState(GameState.ended);

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

  Widget gameWidget(GameState gValue){
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child,),
      child: gValue != GameState.started && gValue != GameState.paused
              && gValue != GameState.ended ?
      Column(
        key: const Key('2ndSSClass23..ds'),
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          gValue == GameState.waiting ? const Text("Waiting for next round...") : Text("Game Starting in $gameStartsIn..."),
          const SizedBox(height: 30),
          SizedBox(
              width: 50.w,
              child: LoadingWidget(circular: true, scaleFactor: 12))
        ],
      )
        : gValue == GameState.ended ? gameController!.iWon ?
          Container(child: Text(' You won tournament'),)
          : Container(child: Text('${gameController!.winner}'),) : GamePage(
          key: const Key('classicGamePageKey'),
          controller: gameController!,
          setMove: setMove,
          confirmMove: confirmMove,
          socket: socket),);
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
