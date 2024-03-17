import 'dart:convert';

import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/coinToss.dart';
import 'package:tictactoe/objects/challengeObject.dart';
import 'package:tictactoe/spritesConfigurations.dart';

List<SequenceChallenge> sequenceChallengesFromJson(List<dynamic> list) => List<SequenceChallenge>.from(list.map((x) => SequenceChallenge.fromJson(x)));

String sequenceChallengesToJson(List<SequenceChallenge> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SequenceChallenge {
  int id;
  DateTime startDate;
  DateTime endDate;
  CharacterType? characterType;
  CoinType? coinType;
  int? coinReward;
  int? expReward;
  DateTime createdAt;
  DateTime lastModified;
  List<Challenge> challenges;

  SequenceChallenge({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.characterType,
    required this.coinType,
    required this.coinReward,
    required this.expReward,
    required this.createdAt,
    required this.lastModified,
    required this.challenges
  });

  factory SequenceChallenge.fromJson(Map<String, dynamic> json) => SequenceChallenge(
    id: json["id"],
    startDate: DateTime.fromMillisecondsSinceEpoch(json["startDate"]),
    endDate: DateTime.fromMillisecondsSinceEpoch(json["endDate"]),
    characterType: getCharacterType(json["characterType"]),
    coinType: getCoinType(json["coinType"]),
    coinReward: json["coinReward"],
    expReward: json["expReward"],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json["createdAt"]),
    lastModified: DateTime.fromMillisecondsSinceEpoch(json["lastModified"]),
    challenges: challengesFromJson(json['challenges'])
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "startDate": startDate.millisecondsSinceEpoch,
    "endDate": endDate.millisecondsSinceEpoch,
    "characterType": characterType,
    "coinType": coinType,
    "coinReward": coinReward,
    "expReward": expReward,
    "createdAt": createdAt.millisecondsSinceEpoch,
    "lastModified": lastModified.millisecondsSinceEpoch,
    "challenges": challengesToJson(challenges)
  };
}