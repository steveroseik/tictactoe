import 'package:firebase_auth/firebase_auth.dart';
import 'package:tictactoe/objects/userObject.dart';

import '../Configurations/constants.dart';

class GameManager{

  GameState currentState = GameState.ended;
  GameType type = GameType.noType;
  int fees = 0;
  CoinType coinType = CoinType.bronze;
  int winFactor = 0;
  int loseFactor = 0;
  int expWin = 0;
  int scoreWin = 0;
  int scoreLose = 0;
  bool penalize = false;


  GameManager({this.type = GameType.noType,
    this.fees = 0, this.coinType = CoinType.bronze,
    this.winFactor = 0, this.loseFactor = 0,
    this.expWin = 0, this.scoreWin = 0,
    this.scoreLose = 0, this.penalize = true });

  clearGame(){
    type = GameType.noType;
    fees = 0;
    coinType = CoinType.bronze;
    winFactor = loseFactor = 0;
    scoreWin = 0;
    scoreLose = 0;
    expWin = 0;
    penalize = false;
    currentState = GameState.ended;
  }

  bool newGame({required GameType mode, required UserObject user}){
    type = mode;
    fees = calculateGameFees(mode);
    coinType = calculateCoinType(mode);
    if (true){
      winFactor = loseFactor = 1;
      final scores = calculateTransactionScores(mode);
      scoreWin = scores.$1;
      scoreLose = scores.$2;
      expWin = calculateTransactionExperience(mode);
      penalize = shouldPenalize(mode);
      currentState = GameState.waiting;
      return true;
    }
    type = GameType.noType;
    fees = 0;
    coinType = CoinType.bronze;
    return false;

  }

  GameTransaction exportTransaction(UserObject user, GameResult result){
    final invoice = GameTransaction(type: type, result: result);

    invoice.coinType = coinType;
    invoice.coinFee = result == GameResult.win ?
    (fees*winFactor) : -(fees*loseFactor);
    if (result == GameResult.win) invoice.expFee = expWin;
    if (result == GameResult.win) invoice.scoreFee = scoreWin;
    if (penalize && result == GameResult.lose) invoice.scoreFee = -scoreLose;
    invoice.tournamentWins = user.updateTournament(type);

    return invoice;
  }

  bool canUserEnter(UserObject user){
    switch(coinType){
      case CoinType.bronze:
        return user.bronzeCoins >= fees;
      case CoinType.silver:
        return user.silverCoins >= fees;
      case CoinType.gold:
        return user.goldCoins >= fees;
    }
  }

  factory GameManager.fromJson(Map<String, dynamic> json) {
    return GameManager(
      type: GameType.values.firstWhere((e) => e.toString() == json['mode']),
      fees: json['fees'] ?? 0,
      coinType: CoinType.values.firstWhere((e) => e.toString() == json['coinType']),
      winFactor: json['winFactor'] ?? 0,
      loseFactor: json['loseFactor'] ?? 0,
      expWin: json['expWin'] ?? 0,
      scoreWin: json['scoreWin'] ?? 0,
      scoreLose: json['scoreLose'] ?? 0,
      penalize: json['penalize'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': type.toString(),
      'fees': fees,
      'coinType': coinType.toString(),
      'winFactor': winFactor,
      'loseFactor': loseFactor,
      'expWin': expWin,
      'scoreWin': scoreWin,
      'scoreLose': scoreLose,
      'penalize': penalize,
    };
  }

}



class GameTransaction {
  int scoreFee;
  int coinFee;
  CoinType coinType;
  int expFee;
  GameType type;
  GameResult result;
  Map<String, dynamic>? tournamentWins;

  GameTransaction({
    required this.type,
    required this.result,
    this.scoreFee = 0,
    this.coinFee = 0,
    this.coinType = CoinType.bronze,
    this.expFee = 0
  });

  factory GameTransaction.fromJson(Map<String, dynamic> json) {
    return GameTransaction(
      type: GameType.values.firstWhere(
              (e) => e.toString().contains(json['type']),
          orElse: () => GameType.noType),
      result: GameResult.values.firstWhere(
              (e) => e.toString().contains(json['result']),
          orElse: () => GameResult.lose),
      scoreFee: json['scoreFee'] ?? 0,
      coinFee: json['coinFee'] ?? 0,
      coinType: CoinType.values.firstWhere(
              (e) => e.toString().contains(json['coinType']),
          orElse: () => CoinType.bronze),
      expFee: json['expFee'] ?? 0,
    );
  }

  Map<String, dynamic> toJson(String id) {
    return {
      'userId': id,
      'scoreFee': scoreFee,
      'coinFee': coinFee,
      'coinType': coinType.toString().split('.').last,
      'expFee': expFee,
      'type': type.toString().split('.').last,
      'result': result.toString().split('.').last,
      'tournamentWins': tournamentWins
    };
  }
}

int calculateGameFees(GameType mode){

  switch(mode) {
    case GameType.classicSingleTiered:
      return Const.classicSingleTieredEntranceFees;
    case GameType.classicSingleRandom:
      return Const.classicSingleRandomEntranceFees;
    case GameType.classicDailyTournament:
      return Const.classicTournamentDailyEntranceFees;
    case GameType.classicWeeklyTournament:
      return Const.classicTournamentWeeklyEntranceFees;
    case GameType.classicMonthlyTournament:
      return Const.classicTournamentMonthlyEntranceFees;
    case GameType.nineSingleTiered:
      return Const.nineSingleTieredEntranceFees;
    case GameType.nineSingleRandom:
      return Const.nineSingleRandomEntranceFees;
    case GameType.nineDailyTournament:
      return Const.nineTournamentDailyEntranceFees;
    case GameType.nineWeeklyTournament:
      return Const.nineTournamentWeeklyEntranceFees;
    case GameType.nineMonthlyTournament:
      return Const.nineTournamentMonthlyEntranceFees;
    case GameType.powersSingleTiered:
      return Const.powersSingleTieredEntranceFees;
    case GameType.powersSingleRandom:
      return Const.powersSingleRandomEntranceFees;
    case GameType.powersDailyTournament:
      return Const.powersTournamentDailyEntranceFees;
    case GameType.powersWeeklyTournament:
      return Const.powersTournamentWeeklyEntranceFees;
    case GameType.powersMonthlyTournament:
      return Const.powersTournamentMonthlyEntranceFees;

    default: return 0;
  }
}

// GameFees calculateGameFee(GameType mode){
//
//   switch(mode){
//     case GameType.classicSingleTiered:
//       {
//         if (transaction.iWon) {
//           return GameFees(
//               bronzeFee: Const.classicSingleTieredEntranceFees * 2);
//         }
//         return GameFees(
//             bronzeFee: -Const.classicSingleTieredEntranceFees);
//       }
//     case GameType.classicSingleRandom:
//       {
//         if (transaction.iWon) {
//           return GameFees(
//               bronzeFee: Const.classicSingleRandomEntranceFees * 2);
//         }
//         return GameFees(
//             bronzeFee: -Const.classicSingleRandomEntranceFees);
//       }
//     case GameType.classicDailyTournament:
//       {
//         if (transaction.iWon) {
//           return GameFees(
//               bronzeFee: Const.classicTournamentDailyEntranceFees * 2);
//         }
//         return GameFees(
//             bronzeFee: -Const.classicTournamentDailyEntranceFees);
//       }
//     case GameType.classicWeeklyTournament:
//       {
//         if (transaction.iWon) {
//           return GameFees(
//               bronzeFee: Const.classicTournamentWeeklyEntranceFees * 2);
//         }
//         return GameFees(
//             bronzeFee: -Const.classicTournamentWeeklyEntranceFees);
//       }
//     case GameType.classicMonthlyTournament:
//       {
//         if (transaction.iWon) {
//           return GameFees(
//               bronzeFee: Const.classicTournamentMonthlyEntranceFees * 2);
//         }
//         return GameFees(
//             bronzeFee: -Const.classicTournamentMonthlyEntranceFees);
//       }
//     case GameType.nineSingleTiered:
//       {
//         if (transaction.iWon) {
//           return GameFees(
//               bronzeFee: Const.nineSingleTieredEntranceFees * 2);
//         }
//         return GameFees(
//             bronzeFee: -Const.nineSingleTieredEntranceFees);
//       }
//     case GameType.nineSingleRandom:
//       {
//         if (transaction.iWon) {
//           return GameFees(
//               bronzeFee: Const.nineSingleRandomEntranceFees * 2);
//         }
//         return GameFees(
//             bronzeFee: -Const.nineSingleRandomEntranceFees);
//       }
//     case GameType.nineDailyTournament:
//       {
//         if (transaction.iWon) {
//           return GameFees(
//               bronzeFee: Const.nineTournamentDailyEntranceFees * 2);
//         }
//         return GameFees(
//             bronzeFee: -Const.nineTournamentDailyEntranceFees);
//       }
//     case GameType.nineWeeklyTournament:
//       {
//         if (transaction.iWon) {
//           return GameFees(
//               bronzeFee: Const.nineTournamentWeeklyEntranceFees * 2);
//         }
//         return GameFees(
//             bronzeFee: -Const.nineTournamentWeeklyEntranceFees);
//       }
//     case GameType.nineMonthlyTournament:
//       {
//         if (transaction.iWon) {
//           return GameFees(
//               bronzeFee: Const.nineTournamentMonthlyEntranceFees * 2);
//         }
//         return GameFees(
//             bronzeFee: -Const.nineTournamentMonthlyEntranceFees);
//       }
//     case GameType.powersSingleTiered:
//       {
//         if (transaction.iWon) {
//           return GameFees(
//               bronzeFee: Const.powersSingleTieredEntranceFees * 2);
//         }
//         return GameFees(
//             bronzeFee: -Const.powersSingleTieredEntranceFees);
//       }
//     case GameType.powersSingleRandom:
//       {
//         if (transaction.iWon) {
//           return GameFees(
//               bronzeFee: Const.powersSingleRandomEntranceFees * 2);
//         }
//         return GameFees(
//             bronzeFee: -Const.powersSingleRandomEntranceFees);
//       }
//     case GameType.powersDailyTournament:
//       {
//         if (transaction.iWon) {
//           return GameFees(
//               bronzeFee: Const.powersTournamentDailyEntranceFees * 2);
//         }
//         return GameFees(
//             bronzeFee: -Const.powersTournamentDailyEntranceFees);
//       }
//     case GameType.powersWeeklyTournament:
//       {
//         if (transaction.iWon) {
//           return GameFees(
//               bronzeFee: Const.powersTournamentWeeklyEntranceFees * 2);
//         }
//         return GameFees(
//             bronzeFee: -Const.powersTournamentWeeklyEntranceFees);
//       }
//     case GameType.powersMonthlyTournament:
//       {
//         if (transaction.iWon) {
//           return GameFees(
//               bronzeFee: Const.powersTournamentMonthlyEntranceFees * 2);
//         }
//         return GameFees(
//             bronzeFee: -Const.powersTournamentMonthlyEntranceFees);
//       }
//   }
// }

int calculateTransactionExperience(GameType type){

  switch(type){
    case GameType.powersSingleTiered:
      return Const.powersSingleTieredExperienceReward;
    case GameType.powersDailyTournament:
      return Const.powersTournamentDailyExperienceReward;
    case GameType.powersWeeklyTournament:
      return Const.powersTournamentWeeklyExperienceReward;
    case GameType.powersMonthlyTournament:
      return Const.powersTournamentMonthlyExperienceReward;
    default: return 0;
  }
}

bool shouldPenalize(GameType type){

  switch(type){
    case GameType.classicSingleTiered:
    case GameType.powersSingleTiered:
      return true;
    default: return false;
  }
}

(int, int) calculateTransactionScores(GameType type){

  switch(type){

    case GameType.nineSingleTiered:
    case GameType.classicSingleTiered:
      return (Const.singleTieredScoreReward, Const.singleTieredScorePenalty);

    case GameType.nineDailyTournament:
    case GameType.classicDailyTournament:
      return (Const.tournamentDailyReward, 0);

    case GameType.nineWeeklyTournament:
    case GameType.classicWeeklyTournament:
      return (Const.tournamentWeeklyReward, 0);

    case GameType.classicMonthlyTournament:
    case GameType.nineMonthlyTournament:
      return (Const.tournamentMonthlyReward, 0);

    default: return (0, 0);
  }
}

CoinType calculateCoinType(GameType type){

  switch(type){

    case GameType.classicSingleTiered:
    case GameType.classicSingleRandom:
    case GameType.classicDailyTournament:
      return CoinType.bronze;
    case GameType.classicWeeklyTournament:
      return CoinType.silver;
    case GameType.classicMonthlyTournament:
      return CoinType.gold;
    case GameType.nineSingleTiered:
    case GameType.nineSingleRandom:
    case GameType.nineDailyTournament:
      return CoinType.bronze;
    case GameType.nineWeeklyTournament:
      return CoinType.silver;
    case GameType.nineMonthlyTournament:
      return CoinType.gold;
    case GameType.powersSingleTiered:
    case GameType.powersSingleRandom:
    case GameType.powersDailyTournament:
      return CoinType.bronze;
    case GameType.powersWeeklyTournament:
      return CoinType.silver;
    case GameType.powersMonthlyTournament:
      return CoinType.gold;

    default: return CoinType.bronze;
  }
}

int calculateGameCoins(GameType type){

  switch(type){

    case GameType.classicSingleTiered:
      return Const.classicSingleTieredEntranceFees;
    case GameType.classicSingleRandom:
      return Const.classicSingleRandomEntranceFees;
    case GameType.classicDailyTournament:
      return Const.classicTournamentDailyEntranceFees;
    case GameType.classicWeeklyTournament:
      return Const.classicTournamentWeeklyEntranceFees;
    case GameType.classicMonthlyTournament:
      return Const.classicTournamentMonthlyEntranceFees;
    case GameType.nineSingleTiered:
      return Const.nineSingleTieredEntranceFees;
    case GameType.nineSingleRandom:
      return Const.nineSingleRandomEntranceFees;
    case GameType.nineDailyTournament:
      return Const.nineTournamentDailyEntranceFees;
    case GameType.nineWeeklyTournament:
      return Const.nineTournamentWeeklyEntranceFees;
    case GameType.nineMonthlyTournament:
      return Const.nineTournamentMonthlyEntranceFees;
    case GameType.powersSingleTiered:
      return Const.powersSingleTieredEntranceFees;
    case GameType.powersSingleRandom:
      return Const.powersSingleRandomEntranceFees;
    case GameType.powersDailyTournament:
      return Const.powersTournamentDailyEntranceFees;
    case GameType.powersWeeklyTournament:
      return Const.powersTournamentWeeklyEntranceFees;
    case GameType.powersMonthlyTournament:
      return Const.powersTournamentMonthlyEntranceFees;

    default: return 0;
  }
}