import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/ClassicGame/classicGameMain.dart';
import 'package:tictactoe/ClassicGame/classicGameModule.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/Controllers/classicGameController.dart';
import 'package:tictactoe/PowersGame/core.dart';
import 'package:tictactoe/PowersGame/powersGameModule.dart';
import 'package:tictactoe/Providers/socketProvider.dart';
import 'package:tictactoe/objects/classicObjects.dart';
import 'package:tictactoe/objects/powerRoomObject.dart';
import '../Controllers/powersGameController.dart';
import '../UIUX/customWidgets.dart';
import '../UIUX/themesAndStyles.dart';
import '../coinToss.dart';
import 'Characters/core.dart';

class PowersGameMain extends StatefulWidget {
  final Function(GameWinner, bool)? gameStateChange;
  final bool inTournament;
  final GameRoom? roomInfo;
  final String? uid;
  final Character character;


  const PowersGameMain({super.key,
    this.roomInfo,
    this.uid,
    this.gameStateChange,
    required this.character,
    this.inTournament = false
  });

  @override
  State<PowersGameMain> createState() => _PowersGameMainState();
}

class _PowersGameMainState extends State<PowersGameMain> {


  late Socket socket;

  ValueNotifier<GameState> currentState = ValueNotifier(GameState.connecting);

  GameRoom? roomInfo;

  int gameStartsIn = 0;

  DateTime? gameStartTime;

  String uid = '';

  late Timer gameTimer;

  PowersGameController? gameController;
  ClassicGameController? extraController;

  bool oppConnected = true;
  bool gotDisconnected = false;
  bool canLeave = true;

  late Character mySelectedCharacter;

  List<StreamSubscription> subscriptions = [];

  bool speedMatch = false;

  int speedCount = 0;

  int theLuckyWinner = -1;



  @override
  void initState() {

    mySelectedCharacter = widget.character;
    uid = widget.uid?? '';

    initSocket();

    initGameTimer();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (!widget.inTournament){
      getIt.get<SocketProvider>().disconnect();
    }

    print('cancelling powers subscriptions');
    for (var sub in subscriptions){
      sub.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child,),
      child: speedMatch ? ClassicGameMain(
        speedMatch: true,
        controller: extraController,
        inTournament: widget.inTournament,
        gameStartsIn: gameStartsIn,
      ) : Scaffold(
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
                          print('POPPING BTN');
                          Navigator.of(context).pop();
                        },
                        child: Text('Leave'),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: value != GameState.started && value != GameState.paused ?
                          viewMiddleWidget(value) : PowersGameModule(
                              gameController: gameController!,
                             roomInfo: roomInfo!,
                              socket: socket,
                          checkWin: checkWin,),
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    child: ElevatedButton(onPressed: () => Navigator.of(context).pop(),
                        child: Text('back')),
                  )
                ],
              );
            }
        ),
      ),
    );
  }

  initSocket(){
    final socketProvider = getIt.get<SocketProvider>();
    if (widget.inTournament){
      socket = socketProvider.socket!;
      gameInitAction(null);
    }else{
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
      if (data['type'] == 'disconnect'){
        setState(() {
          oppConnected = false;
        });
        if (gameController?.hasListeners?? false) gameController!.setOppConnection(GameConn.offline);

      }else if(data['type'] == 'connect'){
        setState(() {
          oppConnected = true;
        });
        if (gameController?.hasListeners?? false) gameController!.setOppConnection(GameConn.online, clientId: data['clientId']);
      }
    }));


    subscriptions.add(socketProvider.onGameListener.stream.listen((data) {

      print('got from powers main: ${jsonEncode(data)}');

      switch(data['type']){

        case 'gameInit': gameInitAction(data);
        break;
        case 'powersMove': gameMoveAction(data);
        break;
        case 'powersMoveValidation': gameMoveValidation(data);
        break;
        case 'powersSpell': gameSpellAction(data);
        break;
        case 'powersSpellValidation': gameSpellValidation(data);
        break;
        case 'powersEndRound': myRoundStarted(data);
        break;
        case 'switchToSpeed': startSpeedMatch(data);
        break;
        case 'gameConnectionOff': gameEndedWithDisconnect(data);
        break;
        default: print('lel asaf ${jsonEncode(data)}');
      }

    }));

    subscriptions.add(socketProvider.onDisconnect.stream.listen((_){
      if (gameController?.iWon?? false) return;
      print("Disconnected");
      currentState.value = GameState.connecting;
      if (mounted){
        gotDisconnected = true;
        if (gameController != null &&
            (gameController?.hasListeners??false)) gameController!.gotOffline();
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
        if (!widget.inTournament) Navigator.of(context).pop();
      }else{
        errorCounter++;
      }
    }));

    subscriptions.add(socketProvider.onError.stream.listen((err)=>print('Socket Error: $err')));
  }

  calculateGameStartTime(DateTime endTime){
    return endTime.subtract(Const.powersGameDuration);
  }

  myRoundStarted(Map<String, dynamic> data){
    if (!gameController!.isMyTurn){
      gameController!.setMyRound(data);
      checkWin();
    }else{
      print('invalid request to end round');
    }
  }

  gameInitAction(Map<String, dynamic>? data, {bool speedMatch = false}){

    setState(() {
      canLeave = false;
    });

    this.speedMatch = speedMatch;

    print('SPEED MATCH:: ${this.speedMatch}');

    if (!speedMatch){
      if (data != null){
        roomInfo = GameRoom.fromResponse(data['roomInfo']);
      }else{
        roomInfo = widget.roomInfo!;
      }
      gameStartTime = calculateGameStartTime(roomInfo!.sessionEnd);
    }else{
      roomInfo!.sessionEnd = DateTime.now().add(const Duration(seconds: 3 + (Const.speedRoundDuration * 9)));
      gameStartTime = DateTime.now().add(const Duration(seconds: 3));

      extraController = ClassicGameController(
          roomInfo: roomInfo!,
          speedMatch: true,
          currentState: currentState,
          uid: uid
      );
    }

    gameStartsIn = gameStartTime!.difference(DateTime.now()).inSeconds;


    currentState.value = GameState.starting;

    print(roomInfo!.lastHash);
    setState(() {});

    Timer.periodic(gameStartTime!.difference(DateTime.now()), (timer){

      if (!this.speedMatch) {
        gameController = PowersGameController(
            roomInfo: roomInfo!,
            currentState: currentState,
            uid: uid
        );
      }
      currentState.value = gameController!.setState(GameState.started);
      timer.cancel();
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

  gameMoveValidation(data){
    if (data['success'] != true){
      print('YOU ARE CHEATING!!');
      Navigator.of(context).pop();
    }else{
      final resp = gameController!.moveValidated(data: data);
      if (resp != null){
        socket.emitWithAck('gameListener', resp, ack: (data){
          gameController!.endMyRound();
          checkWin();
        });
      }
    }
  }

  gameMoveAction(Map<String, dynamic> data){
    int? move = data['move'];
    String? hash = data['hash'];

    if (move != null && hash != null){
      dynamic resp = gameController!.validateMove(move, hash);
      socket.emitWithAck('gameListener', resp, ack: (d){
        resp = gameController!.moveValidated(data: data);
        if (resp != null){
          socket.emitWithAck('gameListener', resp, ack: (data){
            gameController!.endMyRound();
            checkWin();
          });
        }
      });

    }
  }

  gameSpellValidation(Map<String, dynamic> data){
    if (data['success'] != true){
      print('YOU ARE CHEATING!!');
      Navigator.of(context).pop();
    }else{
      final resp = gameController!.moveValidated(data: data);
      if (resp != null){
        socket.emitWithAck('gameListener', resp, ack: (data){
          gameController!.endMyRound();
          checkWin();
        });
      }

    }
  }

  gameSpellAction(Map<String, dynamic> data){

    Map<String, dynamic>? spells = data['spells'];
    bool? firstPower = data['firstPower'];
    String? hash = data['hash'];
    if (spells != null && hash != null && firstPower != null){
      final map = spells.map((key, value) => MapEntry(int.parse(key), Spell.fromJson(value)));
      final resp = gameController!.validateSpell(map, firstPower, hash);
      print('validation: ${resp['hash']}');
      socket.emitWithAck('gameListener', resp, ack: (data){

        //TODO:: eshme3na hena mafish checkWin();
      });

    }
  }

  gameEndedWithDisconnect(Map<String, dynamic> data ){
    final resp = gameController?.endGameDueConnection(data,
        tournament: widget.inTournament);
    print('connection end: ${resp?.$2}');
    if (resp?.$1?? false) {
      if (resp?.$2 != null){
        print('POPPING DISCONNECT');
        Navigator.of(context).pop(resp!.$2);
      }
    }else{
      print('Not the same');
    }
  }

  requestJoin(){
    uid = 'user${Random().nextInt(1000)}';
    final payload = {
      'token': 'powers.2.$uid',
      'character': {
        'power1Level': mySelectedCharacter.power1Level,
        'power2Level': mySelectedCharacter.power2Level,
        'type': mySelectedCharacter.type.index
      }
    };
    print(payload);
    socket.emitWithAck('joinPowers',  payload , ack:  (response) {
      print(response);
      if (response['success'] == true){
        if (currentState.value == GameState.connecting) currentState.value = GameState.waiting;
      }else{
        print('failed');
        print('POPPING FAILED TO JOIN');
        Navigator.of(context).pop();
      }
    });
  }

  checkWin(){
    print('checkking WINNNN: ${gameController?.state} :: ${currentState.value}');
    if (gameController?.state == GameState.ended){
      if (gameController?.winner == GameWinner.draw){
        if (!gameController?.isMyTurn){
          print('BA3ATOO');
          socket.emitWithAck('gameListener', {
            'type': "switchToSpeed",
            'roomId': gameController?.roomInfo.id,
            'hash': gameController?.roomInfo.lastHash,
          }, ack: (response){
            if (response['success'] == true){
              print('STARTING SPEED');
              startSpeedMatch({
                'hash': gameController?.roomInfo.lastHash,
                'coinWinner': response['coinWinner']
              });
            }
          });
        }
      }else if (widget.inTournament){
        print('POPPING AFTER WIN CHECK: ${gameController?.iWon}');
        Navigator.of(context).pop(gameController?.winRequest);
      }
    }
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
        }
      case GameState.ended:
        return gameEndDialog();

      default: return Text('1Should not appear');
    }

  }
  Widget StartingSpeedMatch(){
    return Container(
      key: Key('$speedMatch${roomInfo?.id}'),
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
      key: UniqueKey(),
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
          print('LEHH? ${speedCount}');
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
    extraController?.setState(GameState.coinToss);
  }

}
