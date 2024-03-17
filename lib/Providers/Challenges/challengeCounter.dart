import 'dart:math';

import 'package:tictactoe/spritesConfigurations.dart';

import '../../Configurations/constants.dart';
import '../../Game Statistics/statistics.dart';
import '../../objects/challengeObject.dart';
import 'challengesBase.dart';


class ChallengeCounter extends ChallengeBase {
  ResetType? resetType;
  DateTime? lastCount;
  late int currentCount;
  ChallengeCounter? counter;

  ChallengeCounter({
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
    ResetType? resetType,
    this.lastCount,
    int? currentCount,
    Map<String, dynamic>? counter,
  }) : super(
    id: id ?? challenge?.id ?? 0,
    description: description ?? challenge?.description ?? "",
    gameTypes: gameTypes ?? challenge?.gameTypes ?? [],
    countType: countType ?? challenge?.countType ?? CountType.play,
    count: count ?? challenge?.count ?? 0,
    startDate: startDate ?? challenge?.startDate ?? DateTime.now(),
    endDate: endDate ?? challenge?.endDate ?? DateTime.now(),
    isCounter: isCounter ?? (challenge != null && !challenge.checklist),
    characterType: characterType ?? challenge?.characterType,
    coinType: coinType ?? challenge?.coinType,
    coinReward: coinReward ?? challenge?.coinReward,
    expReward: expReward ?? challenge?.expReward,
    inSequence: inSequence ?? (challenge != null && challenge.sequenceId != null),
  ) {
    this.currentCount = currentCount?? 0;
    this.resetType = resetType ?? challenge?.resetType;
    if (childChallenge != null) {
      this.counter = ChallengeCounter(challenge: childChallenge);
    }else if (counter != null){
      ChallengeCounter.fromJson(counter);
    }
  }


  factory ChallengeCounter.fromJson(Map<String, dynamic> json) => ChallengeCounter(
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
    currentCount: json['currentCount'],
    resetType: getResetType(json['resetType']),
    counter: json['counter'],
    lastCount: json['lastCount'],
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
      "currentCount": currentCount,
      "resetType": resetType.toString().split('.').last,
      "counter": counter?.toJson(),
      "lastCount": lastCount?.toIso8601String(),
    };
  }

  @override
  bool get isComplete {
    if (currentCount == count
        && DateTime.now().isBefore(endDate)) return true;

    return false;
  }

  resetDailyStreak(){
    if (resetType == ResetType.daily){
      if (currentCount > 0 && lastCount != null){
        final now = DateTime.now();
        if (now.difference(lastCount!).inDays > 1){
          reset();
        }
      }
    }
  }

  @override
  updateFromGameInvitation(GameType gameType) {
    if (countType != CountType.invitation) return;
    if (currentCount < count){
      currentCount += 1;
      lastCount = DateTime.now();
    }
  }

  @override
  updateFromStatistic(GameStatistics statistics) {
    if (!gameTypes.contains(statistics.type)) return;
    if (endDate.isBefore(DateTime.now())) return;
    resetDailyStreak();

    switch(countType){
      case CountType.play:
        if (currentCount < count){
          currentCount = currentCount + 1;
          lastCount = DateTime.now();
        }else{
          if (resetType != null && resetType == ResetType.match){
            reset();
          }
        }
        break;
      case CountType.win:
        if (currentCount < count){
          if (statistics.result == GameResult.win){
            currentCount = currentCount + 1;
            lastCount = DateTime.now();
          }else{
            if (resetType != null && resetType == ResetType.match){
              reset();
            }
          }
        }
        break;
      case CountType.score:
        if (currentCount < count){
          if (statistics.score > 0){
            currentCount += min(statistics.score, (count - currentCount));
            lastCount = DateTime.now();
          }else{
            if (resetType != null && resetType == ResetType.match){
              reset();
            }
          }
        }
        break;
      case CountType.experience:
        if (currentCount < count){
          if (statistics.experience > 0){
            currentCount += min(statistics.experience, (count - currentCount));
            lastCount = DateTime.now();
          }else{
            if (resetType != null && resetType == ResetType.match){
              reset();
            }
          }
        }
        break;
      case CountType.powerPlay:
        if (currentCount < count){
          if (statistics.powersCount > 0){
            currentCount += 1;
            lastCount = DateTime.now();
          }else{
            if (resetType != null && resetType == ResetType.match){
              reset();
            }
          }
        }
        break;
      case CountType.noPowers:
        if (currentCount < count){
          if (statistics.powersCount == 0){
            currentCount += 1;
            lastCount = DateTime.now();
          }else{
            if (resetType != null && resetType == ResetType.match){
              reset();
            }
          }
        }
        break;
      case CountType.tournamentSemi:
        if (currentCount < count){
          if (statistics.tournamentRound >= 2){
            currentCount += 1;
            lastCount = DateTime.now();
          }else{
            if (resetType != null && resetType == ResetType.match){
              reset();
            }
          }
        }
        break;
      case CountType.tournamentFinal:
        if (currentCount < count){
          if (statistics.tournamentRound >= 3){
            currentCount += 1;
            lastCount = DateTime.now();
          }else{
            if (resetType != null && resetType == ResetType.match){
              reset();
            }
          }
        }
        break;
      case CountType.counter:
        if (currentCount < count &&
            (lastCount == null ||
                lastCount!.day < DateTime.now().day)){
          if (counter != null){
            counter!.updateFromStatistic(statistics);
            if (counter!.isComplete){
              currentCount += 1;
              lastCount = DateTime.now();
              counter!.reset();
            }
          }
        }

      case CountType.dailyChallenge:
      case CountType.invitation:
      /// unimplemented here
        print('shouldn\'t reach here');
        break;
    }
  }

  @override
  reset() {
    currentCount = 0;
    lastCount = null;
  }
}