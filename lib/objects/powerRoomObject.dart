import 'dart:convert';

import 'package:flutter/material.dart';

import '../PowersGame/Characters/core.dart';
import 'classicObjects.dart';

List<PowerClient> powerClientsFromJson(List<dynamic> data) => data.map((e) => PowerClient.fromJson(e)).toList();

class PowerClient{
  String userId;
  String clientId;
  Character character;

  PowerClient({required this.clientId, required this.userId, required this.character});

  factory PowerClient.fromJson(Map<String, dynamic> json) =>
      PowerClient(
        clientId: json['clientId'],
        userId: json['userId'],
        character: Character.fromJson(json['character'])
      );

  toJson() => {
    'clientId': clientId,
    'userId': userId,
    'character': character.toJson()
  };
}

class PowersRoom {
  String id;
  String lastHash;
  String userTurn;
  List<PowerClient> users;
  DateTime sessionEnd;
  DateTime? reconnectEnd;
  String? tournamentId;

  PowersRoom({required this.id,
    required this.users,
    required this.lastHash, required this.sessionEnd,
    required this.userTurn, this.tournamentId, this.reconnectEnd});

  /// TODO: Characters are not fully initialized
  factory PowersRoom.fromResponse(Map<String, dynamic> resp) => PowersRoom(
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