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
  int coinsFee;

  GameFees({this.experienceFee = 0,
    this.scoreFee = 0,
    this.coinsFee = 0
  });
}

GameFees calculateGameFees(GameTransaction transaction){

  switch(transaction.mode){
    case GameType.classicSingleTiered:
      {
        if (transaction.iWon) {
          return GameFees(
              coinsFee: Const.classicSingleTieredEntranceFees * 2);
        }
        return GameFees(
            coinsFee: -Const.classicSingleTieredEntranceFees);
      }
    case GameType.classicSingleRandom:
      {
        if (transaction.iWon) {
          return GameFees(
              coinsFee: Const.classicSingleRandomEntranceFees * 2);
        }
        return GameFees(
            coinsFee: -Const.classicSingleRandomEntranceFees);
      }
    case GameType.classicDailyTournament:
      {
        if (transaction.iWon) {
          return GameFees(
              coinsFee: Const.classicTournamentDailyEntranceFees * 2);
        }
        return GameFees(
            coinsFee: -Const.classicTournamentDailyEntranceFees);
      }
    case GameType.classicWeeklyTournament:
      {
        if (transaction.iWon) {
          return GameFees(
              coinsFee: Const.classicTournamentWeeklyEntranceFees * 2);
        }
        return GameFees(
            coinsFee: -Const.classicTournamentWeeklyEntranceFees);
      }
    case GameType.classicMonthlyTournament:
      {
        if (transaction.iWon) {
          return GameFees(
              coinsFee: Const.classicTournamentMonthlyEntranceFees * 2);
        }
        return GameFees(
            coinsFee: -Const.classicTournamentMonthlyEntranceFees);
      }
    case GameType.nineSingleTiered:
      {
        if (transaction.iWon) {
          return GameFees(
              coinsFee: Const.nineSingleTieredEntranceFees * 2);
        }
        return GameFees(
            coinsFee: -Const.nineSingleTieredEntranceFees);
      }
    case GameType.nineSingleRandom:
      {
        if (transaction.iWon) {
          return GameFees(
              coinsFee: Const.nineSingleRandomEntranceFees * 2);
        }
        return GameFees(
            coinsFee: -Const.nineSingleRandomEntranceFees);
      }
    case GameType.nineDailyTournament:
      {
        if (transaction.iWon) {
          return GameFees(
              coinsFee: Const.nineTournamentDailyEntranceFees * 2);
        }
        return GameFees(
            coinsFee: -Const.nineTournamentDailyEntranceFees);
      }
    case GameType.nineWeeklyTournament:
      {
        if (transaction.iWon) {
          return GameFees(
              coinsFee: Const.nineTournamentWeeklyEntranceFees * 2);
        }
        return GameFees(
            coinsFee: -Const.nineTournamentWeeklyEntranceFees);
      }
    case GameType.nineMonthlyTournament:
      {
        if (transaction.iWon) {
          return GameFees(
              coinsFee: Const.nineTournamentMonthlyEntranceFees * 2);
        }
        return GameFees(
            coinsFee: -Const.nineTournamentMonthlyEntranceFees);
      }
    case GameType.powersSingleTiered:
      {
        if (transaction.iWon) {
          return GameFees(
              coinsFee: Const.powersSingleTieredEntranceFees * 2);
        }
        return GameFees(
            coinsFee: -Const.powersSingleTieredEntranceFees);
      }
    case GameType.powersSingleRandom:
      {
        if (transaction.iWon) {
          return GameFees(
              coinsFee: Const.powersSingleRandomEntranceFees * 2);
        }
        return GameFees(
            coinsFee: -Const.powersSingleRandomEntranceFees);
      }
    case GameType.powersDailyTournament:
      {
        if (transaction.iWon) {
          return GameFees(
              coinsFee: Const.powersTournamentDailyEntranceFees * 2);
        }
        return GameFees(
            coinsFee: -Const.powersTournamentDailyEntranceFees);
      }
    case GameType.powersWeeklyTournament:
      {
        if (transaction.iWon) {
          return GameFees(
              coinsFee: Const.powersTournamentWeeklyEntranceFees * 2);
        }
        return GameFees(
            coinsFee: -Const.powersTournamentWeeklyEntranceFees);
      }
    case GameType.powersMonthlyTournament:
      {
        if (transaction.iWon) {
          return GameFees(
              coinsFee: Const.powersTournamentMonthlyEntranceFees * 2);
        }
        return GameFees(
            coinsFee: -Const.powersTournamentMonthlyEntranceFees);
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