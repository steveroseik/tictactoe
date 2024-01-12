import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/PowersGame/core.dart';
import 'package:tictactoe/PowersGame/powersGameModule.dart';
import 'package:tictactoe/objects/powerRoomObject.dart';
import '../Controllers/powersGameController.dart';
import '../UIUX/customWidgets.dart';
import 'Characters/core.dart';

class PowersGameMain extends StatefulWidget {
  final Socket? socket;
  final Function(GameWinner, bool)? gameStateChange;
  final bool inTournament;
  final Character character;


  const PowersGameMain({super.key,
    this.socket,
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

  PowersRoom? roomInfo;

  int gameStartsIn = 0;

  DateTime? gameStartTime;

  String uid = '';

  late Timer gameTimer;

  PowersGameController? gameController;

  bool oppConnected = true;
  bool gotDisconnected = false;
  bool canLeave = true;

  late Character mySelectedCharacter;

  @override
  void initState() {

    mySelectedCharacter = widget.character;
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
                Positioned.fill(
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
                        ) :
                       PowersGameModule(gameController: gameController!,
                           roomInfo: roomInfo!, socket: socket),
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
    return endTime.subtract( const Duration(minutes: Const.powersGameDurationInSeconds ~/ 60));
  }

  myRoundStarted(Map<String, dynamic> data){
    if (!gameController!.isMyTurn){
      if (gameController!.setMyRound(data)){
        print('my turn now');
      }else{
        print('incorrect user');
      }
    }else{
      print('invalid request to end round');
    }
  }

  gameInitAction(Map<String, dynamic> data){

    setState(() {
      canLeave = false;
    });
    print(data);
    roomInfo = PowersRoom.fromResponse(data['roomInfo']);

    gameStartTime = calculateGameStartTime(roomInfo!.sessionEnd);


    gameStartsIn = gameStartTime!.difference(DateTime.now()).inSeconds;


    currentState.value = GameState.starting;

    print(roomInfo!.lastHash);
    Timer.periodic(gameStartTime!.difference(DateTime.now()), (timer){
      gameController = PowersGameController(
          roomInfo: roomInfo!,
          currentState: currentState, uid: uid);
      currentState.value = gameController!.setState(GameState.started);
      timer.cancel();});
  }

  gameMoveValidation(data){
    if (data['success'] != true){
      print('YOU ARE CHEATING!!');
      Navigator.of(context).pop();
    }else{
      final resp = gameController!.moveValidated(data: data);
      if (resp != null ) notifyIfRoundEnded(resp);
    }
  }


  notifyIfRoundEnded(Map<String, dynamic> data){
    print('sent ending');
    socket.emitWithAck('gameListener', data, ack:  (data){

    });
  }


  gameMoveAction(Map<String, dynamic> data){
    int? move = data['move'];
    String? hash = data['hash'];

    if (move != null && hash != null){
      final resp = gameController!.validateMove(move, hash);
      socket.emitWithAck('gameListener', resp, ack: (data){
        gameController!.moveValidated();
      });

    }
  }

  gameSpellValidation(Map<String, dynamic> data){
    if (data['success'] != true){
      print('YOU ARE CHEATING!!');
      Navigator.of(context).pop();
    }else{
      final resp = gameController!.moveValidated(data: data);
      if (resp != null ) notifyIfRoundEnded(resp);
    }
  }

  gameSpellAction(Map<String, dynamic> data){

    Map<String, dynamic>? spells = data['spells'];
    bool? firstPower = data['firstPower'];
    String? hash = data['hash'];

    if (spells != null && hash != null && firstPower != null){
      final map = spells.map((key, value) => MapEntry(int.parse(key), Spell.fromJson(value)));
      print(map);
      final resp = gameController!.validateSpell(map, firstPower, hash);
      print('validation: ${resp['hash']}');
      socket.emitWithAck('gameListener', resp, ack: (data){
        // gameController!.spellValidated();
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
    socket.emitWithAck('joinPowers',  {
      'token': 'powers.2.$uid',
      'character': {
        'power1Level': mySelectedCharacter.power1Level,
        'power2Level': mySelectedCharacter.power2Level,
        'type': mySelectedCharacter.type.index
      }
    }, ack:  (response) {
      print(response);
      if (response['success'] == true){
        if (currentState.value == GameState.connecting) currentState.value = GameState.waiting;
      }else{
        print('failed');
        Navigator.of(context).pop();
      }
    });
  }


}
