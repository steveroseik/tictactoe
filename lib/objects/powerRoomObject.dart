import 'dart:convert';

import 'package:flutter/material.dart';

import '../PowersGame/Characters/core.dart';
import 'classicObjects.dart';

List<ClientObject> powerClientsFromJson(List<dynamic> data) => data.map((e) => ClientObject.fromJson(e)).toList();

class ClientObject{
  String userId;
  String clientId;
  Character? character;
  int? characterId;

  ClientObject({required this.clientId,
    required this.userId, this.character,
  this.characterId});

  factory ClientObject.fromJson(Map<String, dynamic> json) =>
      ClientObject(
        clientId: json['clientId'],
        userId: json['userId'],
        character: json['character'] != null ?
        Character.fromJson(json['character']) : null,
        characterId: json['characterId']
      );

  toJson() => {
    'clientId': clientId,
    'userId': userId,
    'character': character?.toJson(),
    'characterId': characterId
  };
}

class GameRoom {
  String id;
  String lastHash;
  String userTurn;
  List<ClientObject> users;
  DateTime sessionEnd;
  DateTime? reconnectEnd;
  String? tournamentId;

  GameRoom({required this.id,
    required this.users,
    required this.lastHash, required this.sessionEnd,
    required this.userTurn, this.tournamentId, this.reconnectEnd});

  /// TODO: Characters are not fully initialized
  factory GameRoom.fromResponse(Map<String, dynamic> resp) => GameRoom(
      id: resp['id'],
      users: powerClientsFromJson(resp['users']),
      lastHash: resp['lastHash'],
      sessionEnd: DateTime.fromMillisecondsSinceEpoch(resp['sessionEnd']),
      userTurn: resp['turn'],
      tournamentId: resp['tournamentId'],
      reconnectEnd: resp['reconnectEnd'] != null ? DateTime.fromMillisecondsSinceEpoch(resp['reconnectEnd']) : null);

  Map<String, dynamic> toJson() => {
    "id": id,
    "users": List<dynamic>.from(users.map((e) => e.toJson())),
    "lastHash": lastHash,
    "sessionEnd": sessionEnd.millisecondsSinceEpoch,
    "turn": userTurn,
    "tournamentId": tournamentId,
    "reconnectEnd": reconnectEnd?.millisecondsSinceEpoch
  };
}