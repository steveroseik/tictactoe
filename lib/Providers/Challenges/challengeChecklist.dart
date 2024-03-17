import 'dart:math';
import '../../Configurations/constants.dart';
import '../../Game Statistics/statistics.dart';
import '../../objects/challengeObject.dart';
import '../../spritesConfigurations.dart';
import 'challengesBase.dart';

class ChallengeChecklist extends ChallengeBase {
  late Map<GameType, int> checkList;

  ChallengeChecklist({
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
    CharacterType? characterType,
    CoinType? coinType,
    int? coinReward,
    int? expReward,
    bool? inSequence,
    Map<String, dynamic>? checkList,
  }) : super(
    challenge: challenge,
    childChallenge: childChallenge,
    id: id,
    description: description,
    gameTypes: gameTypes,
    countType: countType,
    count: count,
    startDate: startDate,
    endDate: endDate,
    isCounter: isCounter,
    characterType: characterType,
    coinType: coinType,
    coinReward: coinReward,
    expReward: expReward,
    inSequence: inSequence?? false,
  ) {
    if (challenge != null){
      this.checkList = Map<GameType, int>
          .fromEntries(challenge.gameTypes.map((e) => MapEntry(e, 0)));
    }else{
      this.checkList = Map<GameType, int>
          .fromEntries(checkList!.entries.map((e) => MapEntry(getGameType(e.key)!, e.value)));
    }
  }

  factory ChallengeChecklist.fromJson(Map<String, dynamic> json) => ChallengeChecklist(
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
    checkList: json['checklist'],
  );

  @override
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
      'checklist': checkList.map((key, value) => MapEntry(key.toString().split('.').last, value))
    };
  }

  @override
  updateFromStatistic(GameStatistics statistics) {
    if (!gameTypes.contains(statistics.type)) return;
    if (endDate.isBefore(DateTime.now())) return;
    int? currentVal = checkList[statistics.type];
    if (currentVal == null) return;
    switch(countType){
      case CountType.play:
        if (currentVal < count){
          currentVal = currentVal + 1;
        }
        break;
      case CountType.win:
        if (currentVal < count && statistics.result == GameResult.win){
          currentVal = currentVal + 1;
        }
        break;
      case CountType.score:
        if (currentVal < count && statistics.score > 0){
          currentVal = currentVal + min(statistics.score, (count - currentVal));
        }
        break;
      case CountType.experience:
        if (currentVal < count && statistics.experience > 0){
          currentVal = currentVal + min(statistics.experience, (count - currentVal));
        }
        break;
      case CountType.powerPlay:
        if (currentVal < count && statistics.powersCount > 0){
          currentVal = currentVal + 1;
        }
        break;
      case CountType.noPowers:
        if (currentVal < count && statistics.powersCount == 0){
          currentVal = currentVal + 1;
        }
        break;
      case CountType.tournamentSemi:
        if (currentVal < count && statistics.tournamentRound >= 2){
          currentVal = currentVal + 1;
        }
        break;
      case CountType.tournamentFinal:
        if (currentVal < count && statistics.tournamentRound >= 3){
          currentVal = currentVal + 1;
        }
        break;

      case CountType.counter:
      case CountType.dailyChallenge:
      case CountType.invitation:
      /// unimplemented here
        print('shouldn\'t reach here');
        break;
    }
    checkList[statistics.type] = currentVal;
  }

  @override
  bool get isComplete {

    for (var entry in checkList.entries){
      if (entry.value < count) return false;
    }
    if (DateTime.now().isBefore(endDate)) return true;
    return false;
  }

  @override
  reset() {
    checkList.forEach((key, value) {value = 0;});
  }
}