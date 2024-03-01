import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Controllers/powersGameController.dart';
import 'package:tictactoe/PowersGame/powersGameModule.dart';
import 'package:tictactoe/UIUX/themesAndStyles.dart';
import 'package:tictactoe/objects/tournamentObject.dart';

import '../ClassicGame/classicGameMain.dart';
import '../Configurations/constants.dart';
import '../PowersGame/Characters/core.dart';
import '../PowersGame/core.dart';
import '../coinToss.dart';
import '../Controllers/classicGameController.dart';
import '../UIUX/customWidgets.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../objects/powerRoomObject.dart';

class PowersTournamentRoom extends StatefulWidget {
  final Character myCharacter;
  const PowersTournamentRoom({super.key, required this.myCharacter});

  @override
  State<PowersTournamentRoom> createState() => _PowersTournamentRoomState();
}

class _PowersTournamentRoomState extends State<PowersTournamentRoom> {


  late Socket socket;

  ValueNotifier<GameState> currentState = ValueNotifier(GameState.connecting);

  ValueNotifier<GameState> tourState = ValueNotifier(GameState.connecting);

  GameRoom? roomInfo;

  TournamentRoom? tournamentInfo;

  int gameStartsIn = 0;

  DateTime? gameStartTime;

  String uid = '';

  late Timer gameTimer;

  PowersGameController? gameController;
  ClassicGameController? extraController;

  late Character mySelectedCharacter;

  bool oppConnected = true;
  bool gotDisconnected = false;
  bool canLeave = true;
  bool wonTournament = false;

  int theLuckyWinner = -1;

  bool speedMatch = false;

  int speedCount = 0;

  @override
  void initState() {
    mySelectedCharacter = widget.myCharacter;
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child,),
      child: speedMatch ? ClassicGameMain(
        speedMatch: true,
        controller: extraController,
        inTournament: true,
        socket: socket,
      ) :  Scaffold(
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
                              (gameController?.state == GameState.started || gameController?.state == GameState.paused)) ?
                          SafeArea(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Image.asset('assets/speed_match.png', width: 80.w,),
                            ),
                          ) : Container(),
                        ),
                        Positioned.fill(
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
                                    key: UniqueKey(),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      tourValue == GameState.connecting ? const Text("Connecting...")
                                          : tourValue == GameState.waiting ? const Text("Finding a tournament...")
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
                        if (gameValue != GameState.starting) SafeArea(
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
              );
            }
        ),
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
        if (gameController?.hasListeners?? false) gameController!.setOppConnection(GameConn.offline);

      }else if(data['type'] == 'connect'){
        setState(() {
          oppConnected = true;
        });
        if (gameController?.hasListeners?? false) gameController!.setOppConnection(GameConn.online, clientId: data['clientId']);
      }
    });


    socket.on('gameListener', (data) {

      print('got data: ${jsonEncode(data)}');

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
        // if (!widget.inTournament) Navigator.of(context).pop();
      }else{
        errorCounter++;
      }
    });

    socket.onError((err)=>print('Socket Error: $err'));
  }

  calculateGameStartTime(DateTime endTime){
    return endTime.subtract(Const.powersGameDuration);
  }

  myRoundStarted(Map<String, dynamic> data){
    if (!gameController!.isMyTurn){
      final req = gameController!.setMyRound(data, tournament: true);
      if (req != null) sendTournamentUpdate(req);
      checkWin();
    }else{
      print('invalid request to end round');
    }
  }

  gameInitAction(Map<String, dynamic> data, {bool speedMatch = false}){

    setState(() {
      canLeave = false;
    });

    this.speedMatch = speedMatch;

    if (!speedMatch){
      roomInfo = GameRoom.fromResponse(data['roomInfo']);
      gameStartTime = calculateGameStartTime(roomInfo!.sessionEnd);
    }else{
      extraController = ClassicGameController(
          roomInfo: roomInfo!,
          speedMatch: true,
          currentState: currentState,
          uid: uid
      );
      roomInfo!.sessionEnd = DateTime.now().add(const Duration(seconds: 3 + (Const.speedRoundDuration * 9)));
      gameStartTime = DateTime.now().add(const Duration(seconds: 3));

    }

    gameStartsIn = gameStartTime!.difference(DateTime.now()).inSeconds;


    tourState.value = GameState.started;
    currentState.value = GameState.starting;

    print(roomInfo!.lastHash);
    setState(() {});
    Timer.periodic(gameStartTime!.difference(DateTime.now()), (timer){
      gameController = PowersGameController(
          roomInfo: roomInfo!,
          currentState: currentState, uid: uid);
      currentState.value = gameController!.setState(GameState.started);
      timer.cancel();});
    initGameTimer();
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

          checkWin();
          final req = gameController!.endMyRound(tournament: true);
          if (req != null) sendTournamentUpdate(req);
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
            checkWin();
            final req = gameController!.endMyRound(tournament: true);
            if (req != null) sendTournamentUpdate(req);
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
          checkWin();
          final req = gameController!.endMyRound(tournament: true);
          if (req != null) sendTournamentUpdate(req);
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

      });

    }
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
    final payload = {
      'token': 'powersTournament.1.$uid',
      'character': {
        'power1Level': mySelectedCharacter.power1Level,
        'power2Level': mySelectedCharacter.power2Level,
        'type': mySelectedCharacter.type.index
      }
    };
    print(jsonEncode(payload));
    socket.emitWithAck('joinTournament',  {
      'token': 'powersTournament.1.$uid',
      'character': {
        'power1Level': mySelectedCharacter.power1Level,
        'power2Level': mySelectedCharacter.power2Level,
        'type': mySelectedCharacter.type.index
      }
    }, ack:  (response) {
      if (response['success'] == true){
        if(tourState.value == GameState.connecting) tourState.value = GameState.waiting;
      }else{
        print('failed');
        Navigator.of(context).pop();
      }
    });
  }

  checkWin(){
    print('checkking WINNNN: ${gameController?.state} :: ${currentState.value}');
    if (gameController?.state == GameState.ended){
      if (gameController?.winner == GameWinner.draw){
        if (!gameController?.isMyTurn?? false){
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
      }else{
        if (gameController?.winner != GameWinner.none){
          // cause if winner might need to join next tournament
          if (!gameController?.iWon){
            tourState.value = GameState.ended;
          }

        }
      }
    }
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
        : PowersGameModule(
      key: UniqueKey(),
      roomInfo: roomInfo!,
      gameController: gameController!,
      socket: socket,
      checkWin: checkWin,
      sendTournamentUpdate: sendTournamentUpdate,
      );
  }

  Widget viewMiddleWidget(GameState value, GameState tValue){
    switch (value){
      case GameState.starting:
      case GameState.waiting:
      case GameState.connecting:
        if (value == GameState.starting && speedMatch){
          return startingSpeedMatch();
        }else{
          return Column(
            key: UniqueKey(),
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

      case GameState.coinToss:
        return CoinToss(onEnd: onCoinTossEnd);

      default: return Text('1Should not appear');
    }

  }

  Widget startingSpeedMatch(){
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
          width: 80.w,
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
          child: Text("Powers Daily Tournament",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25,
                color: colorOffWhite),textAlign: TextAlign.center,),
        ),
        SizedBox(height: 30,),
        Container(
          width: 80.w,
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

  initCoinToss(){
    extraController?.setState(GameState.coinToss);
  }

  onCoinTossEnd(){
    extraController?.didIWin(theLuckyWinner, tournament: true);
  }

}