

import 'dart:math';

import 'package:tictactoe/Game%20Statistics/statistics.dart';

import '../../Configurations/constants.dart';
import '../../objects/challengeObject.dart';
import '../../spritesConfigurations.dart';

class ChallengeBase {
  late int id;
  bool isCounter = false;
  bool inSequence = false;
  late String description;
  late DateTime startedAt;
  late List<GameType> gameTypes;
  late CountType countType;
  late int count;
  CoinType? coinType;
  int? coinReward;
  int? expReward;
  CharacterType? characterType;
  late DateTime startDate;
  late DateTime endDate;


  bool get isComplete => false;

  updateFromStatistic(GameStatistics statistics){}

  ChallengeBase({
    Challenge? challenge,
    Challenge? childChallenge,
    int? id,
    String? description,
    List<GameType>? gameTypes,
    CountType? countType,
    int? count,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCounter,
    this.characterType,
    this.coinType,
    this.coinReward,
    this.expReward,
    this.inSequence = false,
  }) {
    startedAt = DateTime.now();
    isCounter = !challenge!.checklist;
    id = challenge.id;
    description = challenge.description;
    gameTypes = challenge.gameTypes;
    countType = challenge.countType;
    count = challenge.count;
    characterType = challenge.characterType;
    coinType = challenge.coinType;
    coinReward = challenge.coinReward;
    expReward = challenge.expReward;
    inSequence = challenge.sequenceId != null;
    startDate = challenge.startDate;
    endDate = challenge.endDate;
  }
  reset(){}
  updateFromGameInvitation(GameType gameType){}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'gameTypes': gameTypes.map((type) => type.toString().split('.').last).toList(),
      'countType': countType.toString().split('.').last,
      'count': count,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isCounter': isCounter,
      'characterType': characterType?.toString().split('.').last,
      'coinType': coinType?.toString().split('.').last,
      'coinReward': coinReward,
      'expReward': expReward,
      'inSequence': inSequence,
    };
  }

  factory ChallengeBase.fromJson(Map<String, dynamic> json) => ChallengeBase(
    id: json['id'],
    description: json['description'],
    gameTypes: json['gameTypes'] != null ? (json['gameTypes'] as List<dynamic>).map((e) => getGameType(e)!).toList() : [],
    countType: json['countType'] != null ? getCountType(json['countType']) : null,
    count: json['count'],
    startDate: DateTime.tryParse(json['startDate']),
    endDate: DateTime.tryParse(json['endDate']),
    isCounter: json['isCounter'],
    characterType: json['characterType'] != null ? getCharacterType(json['characterType']) : null,
    coinType: getCoinType(json['coinType']),
    coinReward: json['coinReward'],
    expReward: json['expReward'],
    inSequence: json['inSequence']?? false,
  );
}

