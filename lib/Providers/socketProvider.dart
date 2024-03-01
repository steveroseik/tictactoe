

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../Configurations/constants.dart';

class SocketProvider extends ChangeNotifier{

  Socket? socket;


  StreamController<Map<String, dynamic>> onGameListener = StreamController.broadcast();
  StreamController<Map<String, dynamic>> onTournamentListener = StreamController.broadcast();
  StreamController<Map<String, dynamic>> onGameConnection = StreamController.broadcast();
  StreamController<dynamic> onConnect = StreamController.broadcast();
  StreamController<dynamic> onDisconnect = StreamController.broadcast();
  StreamController<dynamic> onConnectionError = StreamController.broadcast();
  StreamController<dynamic> onError = StreamController.broadcast();


  connect(){
    socket = io(Const.gameServerUrl,
        OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableForceNewConnection()
            .build());

    socket!.connect();

    socket!.onConnect((data) => onConnect.add(data));
    socket!.onDisconnect((data) => onDisconnect.add(data));
    socket!.onConnectError((data) => onConnectionError.add(data));
    socket!.onError((data) => onError.add(data));
    socket!.on('gameListener', (data) => onGameListener.add(data));
    socket!.on('gameConnection', (data) => onGameConnection.add(data));
    socket!.on('tournamentListener', (data) => onTournamentListener.add(data));

    return socket;
  }

  disconnect(){
    socket?.disconnect();
    socket = null;
  }

  @override
  void dispose() {
    onGameListener.close();
    onError.close();
    onConnectionError.close();
    onGameConnection.close();
    onTournamentListener.close();
    onDisconnect.close();
    super.dispose();
  }

}
final getIt = GetIt.instance;

void initSocketSingleton(){

  getIt.registerSingleton<SocketProvider>(SocketProvider());
}
