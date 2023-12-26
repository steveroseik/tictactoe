import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/Controllers/classicGameController.dart';
import 'package:tictactoe/objects/classicObjects.dart';
import 'package:tictactoe/ClassicGame/gamePage.dart';

import '../Controllers/constants.dart';
import '../UIUX/customWidgets.dart';

class ClassicGamePage extends StatefulWidget {
  const ClassicGamePage({super.key});

  @override
  State<ClassicGamePage> createState() => _ClassicGamePageState();
}

class _ClassicGamePageState extends State<ClassicGamePage> {


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

  @override
  void initState() {
    initSocket();

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
              const BackgroundScroller(),
              if (value != GameState.starting && value != GameState.started) SafeArea(
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
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: value != GameState.started && value != GameState.paused
                          && value != GameState.ended ? Column(
                        key: Key('Classdj2!###kjds'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          value == GameState.connecting ? const Text("Connecting...")
                              : value == GameState.starting ? Text("Starting in $gameStartsIn..") : const Text("Waiting for opponent..."),
                          SizedBox(height: 30),
                          SizedBox(
                              width: 50.w,
                              child: LoadingWidget(circular: true, scaleFactor: 12))
                        ],
                      ) : GamePage(
                          key: const Key('classicGamePageKey'),
                          controller: gameController!,
                          setMove: setMove,
                          confirmMove: confirmMove,
                          socket: socket),),
                  ],
                ),
              ),
            ],
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
      await Future.delayed(const Duration(milliseconds: 3000));
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

  confirmMove(Map<String, dynamic> response){

  }

  gameInitAction(Map<String, dynamic> data){

    setState(() {
      canLeave = false;
    });

    roomInfo = ClassicRoom.fromResponse(data['roomInfo']);

    gameStartTime = calculateGameStartTime(roomInfo!.sessionEnd);

    print(gameStartTime);
    gameStartsIn = gameStartTime!.difference(DateTime.now()).inSeconds;
    print(gameStartsIn);

    currentState.value = GameState.starting;

    print(roomInfo!.lastHash);
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
      gameController!.moveValidated(data: data);
    }
  }

  gameClassicAction(Map<String, dynamic> data){
    int? move = data['move'];
    String? hash = data['hash'];
    if (move != null && hash != null){
      final resp = gameController!.validateMove(move, hash);
      socket.emitWithAck('gameListener', resp, ack: (data){
        gameController!.moveValidated();
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
        currentState.value = GameState.waiting;
        print('waitingggg');
      }else{
        print('failed');
        Navigator.of(context).pop();
      }
    });
  }


}
