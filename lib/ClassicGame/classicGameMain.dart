import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/Controllers/classicGameController.dart';
import 'package:tictactoe/Authentication/sessionProvider.dart';
import 'package:tictactoe/Providers/socketProvider.dart';
import 'package:tictactoe/coinToss.dart';
import 'package:tictactoe/objects/classicObjects.dart';
import 'package:tictactoe/ClassicGame/classicGameModule.dart';
import 'package:tictactoe/spritesConfigurations.dart';

import '../Configurations/constants.dart';
import '../UIUX/customWidgets.dart';
import '../UIUX/themesAndStyles.dart';
import '../objects/powerRoomObject.dart';

class ClassicGameMain extends ConsumerStatefulWidget {
  final ClassicGameController? controller;
  final Function(GameWinner, bool)? gameStateChange;
  final Function(Map<String, dynamic> data)? sendTournamentUpdate;
  final Function()? onTournamentRoundEnd;
  final bool inTournament;
  final bool speedMatch;
  final int gameStartsIn;


  const ClassicGameMain({super.key,
    this.gameStateChange,
    this.onTournamentRoundEnd,
    this.sendTournamentUpdate,
    this.speedMatch = false,
    this.controller,
    this.inTournament = false,
    this.gameStartsIn = 0
  });

  @override
  ConsumerState<ClassicGameMain> createState() => _ClassicGameMainState();
}

class _ClassicGameMainState extends ConsumerState<ClassicGameMain> {


  late Socket socket;

  ValueNotifier<GameState> currentState = ValueNotifier(GameState.connecting);

  GameRoom? roomInfo;

  int gameStartsIn = 0;

  DateTime? gameStartTime;

  late Timer gameTimer;

  ClassicGameController? gameController;

  bool oppConnected = true;
  bool gotDisconnected = false;
  bool canLeave = true;

  bool speedMatch = false;

  int theLuckyWinner = -1;

  int speedCount = 0;

  List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    print('speed data lehhhhhhh: ${widget.controller?.roomInfo.toJson()}');
    speedMatch = widget.speedMatch;
    if (widget.controller != null) {
      gameController = widget.controller;
      currentState = widget.controller!.currentState;
    }

    gameStartsIn = widget.gameStartsIn;

    initSocket();
    initGameTimer();

    super.initState();
  }

  @override
  void dispose() {
    print('getting off speed');
    gameTimer.cancel();
    if (!widget.inTournament) {
      getIt.get<SocketProvider>().disconnect();
    }

    for ( var sub in subscriptions){
      sub.cancel();
    }

    super.dispose();
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
                      viewMiddleWidget(
                          controller: gameController,
                          gameState: value,
                          speedMatch: speedMatch,
                          gameStartsIn: gameStartsIn,
                          onCoinTossEnd: onCoinTossEnd,
                          inTournament: widget.inTournament,
                          onWinButtonClick: (){},
                          tournamentRoundEnded: (){}
                      )
                          : ClassicGameModule(
                            key: UniqueKey(),
                            controller: gameController!,
                            gameStateChanged: (winner, iWon){},
                            socket: socket),),
                  ],
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: ElevatedButton(
                    onPressed: (){
                      print('POPPING BTN');
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
    final socketProvider = getIt.get<SocketProvider>();
    if (widget.inTournament || widget.controller != null) {
      socket = socketProvider.socket!;
    }else{
      socket = socketProvider.connect();
    }


    subscriptions.add(socketProvider.onGameListener.stream.listen((data) {

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

    }));
    subscriptions.add(socketProvider.onConnect.stream.listen((_) async{
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
    }));

    subscriptions.add(socketProvider.onGameConnection.stream.listen((data) {
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
    }));

    subscriptions.add(socketProvider.onDisconnect.stream.listen((_){
      print("Disconnected");
      currentState.value = GameState.connecting;
      if (mounted){
        gotDisconnected = true;
        if (gameController != null &&
            gameController!.hasListeners) gameController?.gotOffline();
      }
    }));

    int errorCounter = 0;
    subscriptions.add(socketProvider.onConnectionError.stream.listen((err) {
      if (errorCounter == 4){
        try{
          socket.disconnect();
        }catch (e){
          print(e);
        }
        print('POPPING CONNECTION ERROR');
        if (!widget.inTournament) Navigator.of(context).pop();
      }else{
        errorCounter++;
      }
    }));

    subscriptions.add(socketProvider.onError.stream.listen((err)=>print('Socket Error: $err')));

  }

  initGameListener(){
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
    final resp = gameController?.didIWin(theLuckyWinner, tournament: widget.inTournament);
    if (widget.inTournament){
      print('POPPING COIN TOSS END');
      Navigator.of(context).pop(resp);
    }
  }

  gameInitAction(Map<String, dynamic> data, {bool speedMatch = false}){

    setState(() {
      canLeave = false;
      this.speedMatch = speedMatch;
    });


    if (!speedMatch){
      roomInfo = GameRoom.fromResponse(data['roomInfo']);
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
          currentState: currentState,
          uid: ref.read(sessionProvider).currentUser!.id);
      currentState.value = gameController!.setState(GameState.started);
      timer.cancel();});
  }



  gameClassicValidation(data){
    if (data['success'] != true){
      print('YOU ARE CHEATING!!');
      Navigator.of(context).pop();
    }else{
      print('running from classic');
      gameController?.moveValidated(data: data);
      checkWin();
    }
  }

  checkWin(){
    print('CHECKIINGG WINNN!!: ${gameController?.state} :: ${gameController?.iWon}');
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
                'hash': gameController?.roomInfo.lastHash,
                'coinWinner': response['coinWinner']
              });
            }
          });
        }
      }else if (widget.inTournament){
        if (mounted) {
          Navigator.of(context)
            .pop(gameController?.winRequest);
          print('POPPING AFTER CHECK ${gameController?.iWon}');
        }
      }
    }
  }

  gameClassicAction(Map<String, dynamic> data){
    int? move = data['move'];
    String? hash = data['hash'];

    if (move != null && hash != null){
      final resp = gameController?.validateMove(move, hash);
      socket.emitWithAck('gameListener', resp, ack: (data){
        print('running from classic');
        final update = gameController?.moveValidated(tournament: widget.inTournament);
        if (update != null) {
          print('sending from classic!!!!: ${update}');
          if (widget.sendTournamentUpdate != null) widget.sendTournamentUpdate!(update);
        }
        checkWin();
      });

    }
  }

  gameEndedWithDisconnect(Map<String, dynamic> data){

    final resp = gameController!.endGameDueConnection(data, tournament: widget.inTournament);
    if (resp.$1) {
      if (resp.$2 != null){
        print('POPPING DISCONNECT');
        Navigator.of(context).pop(resp.$2);
        // if (widget.sendTournamentUpdate != null) widget.sendTournamentUpdate!(resp.$2);
      }
    }else{
      print('Not the same');
    }
  }

  requestJoin(){
    final uid = ref.read(sessionProvider).currentUser!.id;
    final characterId = Random().nextInt(45);
    socket.emitWithAck('joinClassic',  {
      'token': 'classic.1.$uid.$characterId'
    }, ack:  (response) {
      if (response['success'] == true){
        if (currentState.value == GameState.connecting) currentState.value = GameState.waiting;
      }else{
        print('failed');
        print('POPPING FAILED TO JOIN');
        Navigator.of(context).pop();
      }
    });
  }
}
