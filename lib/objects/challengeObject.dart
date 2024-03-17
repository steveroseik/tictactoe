import 'dart:convert';
import 'package:tictactoe/Configurations/constants.dart';

import '../spritesConfigurations.dart';

List<Challenge> challengesFromJson(List<dynamic> list) => List<Challenge>.from(list.map((x) => Challenge.fromJson(x)));

String challengesToJson(List<Challenge> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Challenge {
  int id;
  int? sequenceId;
  int? challengeAtDay;
  String description;
  DateTime startDate;
  DateTime endDate;
  int? childChallengeId;
  List<GameType> gameTypes;
  ResetType? resetType;
  CountType countType;
  int count;
  bool checklist;
  CharacterType? characterType;
  CoinType? coinType;
  int? coinReward;
  int? expReward;
  DateTime createdAt;
  DateTime lastModified;

  Challenge({
    required this.id,
    this.sequenceId,
    this.challengeAtDay,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.childChallengeId,
    required this.gameTypes,
    this.resetType,
    required this.countType,
    required this.count,
    required this.checklist,
    this.characterType,
    this.coinType,
    this.coinReward,
    this.expReward,
    required this.createdAt,
    required this.lastModified,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
    id: json["id"],
    sequenceId: json["sequenceId"],
    challengeAtDay: json["challengeAtDay"],
    description: json["description"],
    startDate: DateTime.fromMillisecondsSinceEpoch(json["startDate"]),
    endDate: DateTime.fromMillisecondsSinceEpoch(json["endDate"]),
    childChallengeId: json["childChallengeId"],
    gameTypes: List<GameType>.from(json["gameTypes"].map((x) => getGameType(x))),
    resetType: getResetType(json["resetType"]),
    countType: getCountType(json["countType"])!,
    count: json["count"],
    checklist: json["checklist"],
    characterType: getCharacterType(json["characterType"]),
    coinType: getCoinType(json["coinType"]),
    coinReward: json["coinReward"],
    expReward: json["expReward"],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json["createdAt"]),
    lastModified: DateTime.fromMillisecondsSinceEpoch(json["lastModified"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "sequenceId": sequenceId,
    "challengeAtDay": challengeAtDay,
    "description": description,
    "startDate": startDate.millisecondsSinceEpoch,
    "endDate": endDate.millisecondsSinceEpoch,
    "childChallengeId": childChallengeId,
    "gameTypes": List<dynamic>.from(gameTypes.map((x) => x)),
    "resetType": resetType,
    "countType": countType,
    "count": count,
    "checklist": checklist,
    "characterType": characterType,
    "coinType": coinType,
    "coinReward": coinReward,
    "expReward": expReward,
    "createdAt": createdAt.millisecondsSinceEpoch,
    "lastModified": lastModified.millisecondsSinceEpoch,
  };
}