import 'dart:async';
import 'dart:convert';
import 'dart:math';


import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Providers/socketProvider.dart';
import 'package:tictactoe/UIUX/themesAndStyles.dart';
import 'package:tictactoe/objects/tournamentObject.dart';
import 'package:tictactoe/routesGenerator.dart';
import '../Configurations/constants.dart';
import '../Controllers/classicGameController.dart';
import '../UIUX/customWidgets.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../objects/powerRoomObject.dart';

class NineTournamentRoom extends StatefulWidget {
  const NineTournamentRoom({super.key});

  @override
  State<NineTournamentRoom> createState() => _NineTournamentRoomState();
}

class _NineTournamentRoomState extends State<NineTournamentRoom> with TickerProviderStateMixin {


  late Socket socket;

  ValueNotifier<GameState> tourState = ValueNotifier(GameState.connecting);

  GameRoom? roomInfo;

  TournamentRoom? tournamentInfo;

  int gameStartsIn = 0;

  DateTime? gameStartTime;

  String uid = '';

  late Timer gameTimer;

  late Widget nineGamesWidget;

  bool oppConnected = true;
  bool gotDisconnected = false;
  bool canLeave = true;
  bool wonTournament = false;
  bool waitingForRound = true;

  int theLuckyWinner = -1;

  bool speedMatch = false;

  int nextGridPlay = -1;

  int speedCount = 0;

  List<StreamSubscription> subscriptions = [];


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

    for ( var sub in subscriptions){
      sub.cancel();
    }
    subscriptions.clear();

  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child,),
      child: Scaffold(
        body: ValueListenableBuilder<GameState>(
            valueListenable: tourState,
            builder: (context, tourValue, child) {
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
                  Positioned.fill(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: tourValue == GameState.ended ?
                            gameEndDialog(tourValue)
                                : tourValue == GameState.starting &&
                                tournamentInfo?.users != null ?
                            participantsWidget() : Column(
                              key: UniqueKey(),
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                tourValue == GameState.connecting ? const Text("Connecting...")
                                    : tourValue == GameState.waiting ?
                                waitingForRound ? const Text("Waiting for next round...")
                                : const Text("Finding a tournament...")
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
                  SafeArea(
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
      ),
    );
  }

  initSocket(){

   final socketProvider = getIt.get<SocketProvider>();

   socket = socketProvider.connect();

    subscriptions.add(socketProvider.onConnect.stream.listen((event) {
      print("Connection established : ${socket.id}");
      if (gotDisconnected){
        gotDisconnected = false;
        if (roomInfo == null){
          requestJoin();
        }
      }else{
        requestJoin();
      }
    }));

   subscriptions.add(socketProvider.onGameListener.stream.listen((data) {

     print('data from tournament listener: $data');
     switch(data['type']){

       case 'gameInit': gameInitAction(data);
       break;
       default: print('lel asaf ${jsonEncode(data)}');
     }

   }));

   subscriptions.add(socketProvider.onTournamentListener.stream.listen((data){
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
          tourState.value = GameState.ended;
        }
      }
    }));

    // subscriptions.add(socketProvider.onDisconnect.stream.listen((_){
    //   print("Disconnected");
    //   // currentState.value = GameState.paused;
    //   if (mounted){
    //     gotDisconnected = true;
    //     if (gameController != null &&
    //         gameController!.hasListeners) gameController!.gotOffline();
    //   }
    // }));

    int errorCounter = 0;
   subscriptions.add((socketProvider.onConnectionError.stream.listen((err) {
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
    })));

   subscriptions.add(socketProvider.onError.stream.listen((err)=>print('Socket Error: $err')));
  }


  calculateGameStartTime(DateTime endTime){
    return endTime.subtract(Const.nineGameDuration);
  }

  gameInitAction(Map<String, dynamic> data){


    roomInfo = GameRoom.fromResponse(data['roomInfo']);
    tourState.value = GameState.started;

    Navigator.of(context).pushNamed(Routes.ninesGameMain,
        arguments: {
          "inTournament": true,
          "roomInfo": roomInfo!,
          "uid": uid,
        }
    ).then((value) {
      print('POPPED: $value');
      if (value is Map<String, dynamic>){
        sendTournamentUpdate(value);
      }else{
        tourState.value = GameState.ended;
        getIt.get<SocketProvider>().disconnect();
      }
    });
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

  requestJoin(){
    uid = 'user${Random().nextInt(1000)}';
    final characterId = Random().nextInt(45);
    socket.emitWithAck('joinTournament',  {
      'token': 'nineTournament.1.$uid.$characterId'
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
    print('sending tournament update');


    socket.emitWithAck('tournamentListener', data, ack: (response){
      print(response);
      if (response['success'] == true){
        if (response['code'] == 'you_won'){
          wonTournament = true;
          tourState.value = GameState.ended;
        }else if (response['code'] == 'waiting_for_next_round'){
          waitingForRound = true;
          tourState.value = GameState.waiting;
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
          child: Text("Nine Tournament",
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
            wonTournament ? "You Won !" : "You Lost !",
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
                colors: wonTournament ?
                [colorDeepOrange, colorDeepOrange] :
                [Colors.red, Colors.red.shade900],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            topDecoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: wonTournament ?
                [colorLightYellow, colorDeepOrange] :
                [colorDeepOrange, colorDeepOrange],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            onPressed: (){},
            aspectRatio: 3/1,
            enableShimmer: false,
            borderRadius: BorderRadius.circular(10),
            child: Center(
                child: Text(wonTournament ? 'Claim Reward' : 'Back To Home',
                  style: TextStyle(color: Colors.black),)),
          )
        ],
      ),
    );
  }

}