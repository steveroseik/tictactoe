import 'package:flutter/material.dart';



List<ClientObject> clientsFromJson(List<dynamic> data) => data.map((e) => ClientObject.fromJson(e)).toList();

class ClientObject{
  String userId;
  String clientId;

  ClientObject({required this.clientId, required this.userId});

  factory ClientObject.fromJson(Map<String, dynamic> json) =>
      ClientObject(
          clientId: json['clientId'], userId: json['userId']);
}

class ClassicRoom {
  String id;
  String lastHash;
  String userTurn;
  List<ClientObject> users;
  DateTime sessionEnd;
  DateTime? reconnectEnd;
  String? tournamentId;

  ClassicRoom({required this.id,
    required this.users,
    required this.lastHash, required this.sessionEnd,
    required this.userTurn, this.tournamentId, this.reconnectEnd});

  factory ClassicRoom.fromResponse(Map<String, dynamic> resp) => ClassicRoom(
      id: resp['id'],
      users: clientsFromJson(resp['users']),
      lastHash: resp['lastHash'],
      sessionEnd: DateTime.fromMillisecondsSinceEpoch(resp['sessionEnd']),
      userTurn: resp['turn'],
      tournamentId: resp['tournamentId'],
      reconnectEnd: resp['reconnectEnd'] != null ? DateTime.fromMillisecondsSinceEpoch(resp['reconnectEnd']) : null);

  Map<String, dynamic> toJson() => {
    "id": id,
    "users": List<dynamic>.from(users.map((e) => e)),
    "lastHash": lastHash,
    "sessionEnd": sessionEnd.millisecondsSinceEpoch,
    "turn": userTurn,
    "tournamentId": tournamentId,
    "reconnectEnd": reconnectEnd?.millisecondsSinceEpoch
  };
}