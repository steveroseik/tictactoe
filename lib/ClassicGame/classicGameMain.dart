import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/Controllers/classicGameController.dart';
import 'package:tictactoe/objects/classicObjects.dart';
import 'package:tictactoe/ClassicGame/classicGameModule.dart';

import '../Configurations/constants.dart';
import '../UIUX/customWidgets.dart';

class ClassicGamePage extends StatefulWidget {
  final Socket? socket;
  final Function(GameWinner, bool)? gameStateChange;
  final bool inTournament;


  const ClassicGamePage({super.key,
    this.socket,
    this.gameStateChange,
    this.inTournament = false
  });

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
                      ) : ClassicGameModule(
                          key: const Key('classicGamePageKey'),
                          controller: gameController!,
                          gameStateChanged: (winner, iWon){

                          },
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
    int? grid = data['grid'];
    String? hash = data['hash'];

    if (move != null && hash != null && grid != null){
      final resp = gameController!.validateMove(move, hash, grid: grid);
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
        if (currentState.value == GameState.connecting) currentState.value = GameState.waiting;
      }else{
        print('failed');
        Navigator.of(context).pop();
      }
    });
  }


}
