

import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/Controllers/classicGameController.dart';

import '../Configurations/constants.dart';

class GameSocket{

  late Socket _socket;
  late GameMode _mode;
  bool _initialized = false;

  GameSocket(){
    _socket = io(Const.gameServerUrl,
        OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableForceNewConnection()
            .build());
  }

  init(GameMode mode, {Function(dynamic)? onConnect}) async{

    _mode = mode;
    if(onConnect != null) _socket.onConnect(onConnect);

    switch(mode){

      case GameMode.classicSingle:
        // TODO: Handle this case.
      case GameMode.nineSingle:
        // TODO: Handle this case.
      case GameMode.powersSingle:
        // TODO: Handle this case.
      case GameMode.classicTournament:
        // TODO: Handle this case.
      case GameMode.nineTournament:
        // TODO: Handle this case.
      case GameMode.powersTournament:
        // TODO: Handle this case.
    }
  }
}