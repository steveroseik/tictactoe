import 'package:tictactoe/Game%20Statistics/statistics.dart';
import 'package:tictactoe/Providers/Challenges/challengeChecklist.dart';
import 'package:tictactoe/Providers/Challenges/challengeCounter.dart';

import '../../Configurations/constants.dart';
import '../../objects/SequenceChallengeObject.dart';
import '../../spritesConfigurations.dart';
import 'challengesBase.dart';
import 'helper.dart';

class ChallengeSequencer{

  late int id;

  List<ChallengeBase> challenges = [];

  DateTime? startedAt;

  int get dayIndex {
    if (startedAt == null) return 0;
    return DateTime.now().difference(startedAt!).inDays;
  }

  CoinType? coinType;

  int? coinReward;

  int? expReward;

  CharacterType? characterType;

  late DateTime startDate;
  late DateTime endDate;

  ChallengeSequencer({
    SequenceChallenge? sequenceChallenge,
    int? id,
    CoinType? coinType,
    int? coinReward,
    int? expReward,
    CharacterType? characterType,
    DateTime? startDate,
    DateTime? endDate,
    List<dynamic>? challenges,
    this.startedAt
    }){

    this.id = id?? sequenceChallenge!.id;
    this.coinType = coinType?? sequenceChallenge?.coinType;
    this.coinReward = coinReward?? sequenceChallenge?.coinReward;
    this.expReward = expReward ?? sequenceChallenge?.expReward;
    this.characterType = characterType?? sequenceChallenge?.characterType;
    this.startDate = startDate?? sequenceChallenge!.startDate;
    this.endDate = endDate?? sequenceChallenge!.endDate;
    this.challenges = challenges != null ? challenges.map((e)  {
      if (e['isCounter'] == true){
        return ChallengeCounter.fromJson(e);
      }else{
        return ChallengeChecklist.fromJson(e);
      }
    }).toList()
    : sequenceChallenge!.challenges.map((e) => createSingleChallenge(challenge: e)).toList();
  }

  factory ChallengeSequencer.fromJson(Map<String, dynamic> json) =>
      ChallengeSequencer(
          id: json['id'],
          coinType: getCoinType(json['coinType']),
          coinReward: json['coinReward'],
          expReward: json['expReward'],
          characterType: getCharacterType(json['characterType']),
          startDate: DateTime.tryParse(json['startDate']),
          endDate: DateTime.tryParse(json['endDate']),
          challenges: json['challenges'],
          startedAt: DateTime.tryParse(json['startedAt'])
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'coinType': coinType.toString().split('.').last,
    'characterType': characterType.toString().split('.').last,
    'coinReward': coinReward,
    'expReward': expReward,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'challenges': List<dynamic>.from(challenges.map((e) => e.toJson())),
    'startedAt': startedAt?.toIso8601String()
  };

  bool get isComplete {
    for (var challenge in challenges){
      if (!challenge.isComplete) return false;
    }
    return true;
  }

  bool get isOnStreak {
    for ( int i = 0 ; i <= dayIndex; i++){
      if (!challenges[i].isComplete) return false;
    }
    if (endDate.isAfter(DateTime.now())) return true;
    return false;
  }


  updateFromStatistic(GameStatistics statistics){
    final challengeDay = dayIndex;
    if (challenges[challengeDay].gameTypes.contains(statistics.type)){
      startedAt ??= DateTime.now();
      if (!challenges[challengeDay].isComplete){
        challenges[challengeDay].updateFromStatistic(statistics);
      }
    }
  }

}