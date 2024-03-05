import '../Configurations/constants.dart';

class GameBrain {

  int coinsOnHold;

  GameBrain({this.coinsOnHold = 0});

  holdCoins(GameType type){
    coinsOnHold = calculateGameCoins(type);
  }


}


class GameTransaction{

  GameType mode;
  bool iWon;

  GameTransaction({required this.mode, this.iWon = false});

}

class GameFees {
  int experienceFee;
  int scoreFee;
  int bronzeFee;
  int silverFee;
  int goldFee;
  int expFee;

  GameFees({this.experienceFee = 0,
    this.scoreFee = 0,
    this.bronzeFee = 0,
    this.silverFee = 0,
    this.goldFee = 0,
    this.expFee = 0
  });
}

GameFees calculateGameFees(GameTransaction transaction){

  switch(transaction.mode){
    case GameType.classicSingleTiered:
      {
        if (transaction.iWon) {
          return GameFees(
              bronzeFee: Const.classicSingleTieredEntranceFees * 2);
        }
        return GameFees(
            bronzeFee: -Const.classicSingleTieredEntranceFees);
      }
    case GameType.classicSingleRandom:
      {
        if (transaction.iWon) {
          return GameFees(
              bronzeFee: Const.classicSingleRandomEntranceFees * 2);
        }
        return GameFees(
            bronzeFee: -Const.classicSingleRandomEntranceFees);
      }
    case GameType.classicDailyTournament:
      {
        if (transaction.iWon) {
          return GameFees(
              bronzeFee: Const.classicTournamentDailyEntranceFees * 2);
        }
        return GameFees(
            bronzeFee: -Const.classicTournamentDailyEntranceFees);
      }
    case GameType.classicWeeklyTournament:
      {
        if (transaction.iWon) {
          return GameFees(
              bronzeFee: Const.classicTournamentWeeklyEntranceFees * 2);
        }
        return GameFees(
            bronzeFee: -Const.classicTournamentWeeklyEntranceFees);
      }
    case GameType.classicMonthlyTournament:
      {
        if (transaction.iWon) {
          return GameFees(
              bronzeFee: Const.classicTournamentMonthlyEntranceFees * 2);
        }
        return GameFees(
            bronzeFee: -Const.classicTournamentMonthlyEntranceFees);
      }
    case GameType.nineSingleTiered:
      {
        if (transaction.iWon) {
          return GameFees(
              bronzeFee: Const.nineSingleTieredEntranceFees * 2);
        }
        return GameFees(
            bronzeFee: -Const.nineSingleTieredEntranceFees);
      }
    case GameType.nineSingleRandom:
      {
        if (transaction.iWon) {
          return GameFees(
              bronzeFee: Const.nineSingleRandomEntranceFees * 2);
        }
        return GameFees(
            bronzeFee: -Const.nineSingleRandomEntranceFees);
      }
    case GameType.nineDailyTournament:
      {
        if (transaction.iWon) {
          return GameFees(
              bronzeFee: Const.nineTournamentDailyEntranceFees * 2);
        }
        return GameFees(
            bronzeFee: -Const.nineTournamentDailyEntranceFees);
      }
    case GameType.nineWeeklyTournament:
      {
        if (transaction.iWon) {
          return GameFees(
              bronzeFee: Const.nineTournamentWeeklyEntranceFees * 2);
        }
        return GameFees(
            bronzeFee: -Const.nineTournamentWeeklyEntranceFees);
      }
    case GameType.nineMonthlyTournament:
      {
        if (transaction.iWon) {
          return GameFees(
              bronzeFee: Const.nineTournamentMonthlyEntranceFees * 2);
        }
        return GameFees(
            bronzeFee: -Const.nineTournamentMonthlyEntranceFees);
      }
    case GameType.powersSingleTiered:
      {
        if (transaction.iWon) {
          return GameFees(
              bronzeFee: Const.powersSingleTieredEntranceFees * 2);
        }
        return GameFees(
            bronzeFee: -Const.powersSingleTieredEntranceFees);
      }
    case GameType.powersSingleRandom:
      {
        if (transaction.iWon) {
          return GameFees(
              bronzeFee: Const.powersSingleRandomEntranceFees * 2);
        }
        return GameFees(
            bronzeFee: -Const.powersSingleRandomEntranceFees);
      }
    case GameType.powersDailyTournament:
      {
        if (transaction.iWon) {
          return GameFees(
              bronzeFee: Const.powersTournamentDailyEntranceFees * 2);
        }
        return GameFees(
            bronzeFee: -Const.powersTournamentDailyEntranceFees);
      }
    case GameType.powersWeeklyTournament:
      {
        if (transaction.iWon) {
          return GameFees(
              bronzeFee: Const.powersTournamentWeeklyEntranceFees * 2);
        }
        return GameFees(
            bronzeFee: -Const.powersTournamentWeeklyEntranceFees);
      }
    case GameType.powersMonthlyTournament:
      {
        if (transaction.iWon) {
          return GameFees(
              bronzeFee: Const.powersTournamentMonthlyEntranceFees * 2);
        }
        return GameFees(
            bronzeFee: -Const.powersTournamentMonthlyEntranceFees);
      }
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
  }
}