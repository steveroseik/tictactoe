

class Const{
  static const nullCell = -1;
  static const xCell = 1;
  static const oCell = 0;
  /// quantum state cell
  static const qCell = 2;

  static const baseUrl = 'http://192.168.1.12:3002';

  static const graphqlUrl = '$baseUrl/graphql';

  static const gameServerUrl = 'ws://192.168.1.10:3000';

  static const int speedRoundDuration = 3;

  static const int classicRoundDuration = 7;

  static const int nineRoundDuration = 10;

  static const int powersRoundDuration = 8;

  static const Duration classicGameDuration = Duration(seconds: classicRoundDuration * (9));

  static const Duration nineGameDuration = Duration(seconds: nineRoundDuration * (81));

  static const Duration powersGameDuration = Duration(seconds: powersRoundDuration * (49));


  static const int classicSingleTieredEntranceFees = 100;
  static const int classicSingleRandomEntranceFees = 100;

  static const int classicTournamentDailyEntranceFees = 100;
  static const int classicTournamentWeeklyEntranceFees = 100;
  static const int classicTournamentMonthlyEntranceFees = 100;



  static const int nineSingleTieredEntranceFees = 100;
  static const int nineSingleRandomEntranceFees = 100;

  static const int nineTournamentDailyEntranceFees = 100;
  static const int nineTournamentWeeklyEntranceFees = 100;
  static const int nineTournamentMonthlyEntranceFees = 100;



  static const int powersSingleTieredEntranceFees = 100;
  static const int powersSingleRandomEntranceFees = 100;

  static const int powersTournamentDailyEntranceFees = 100;
  static const int powersTournamentWeeklyEntranceFees = 100;
  static const int powersTournamentMonthlyEntranceFees = 100;
}



//SHARED PREFS

const hasGuest = 'hasGuest';

/// Game State enum
enum GameState { connecting, waiting, starting, started, coinToss, paused, ended }

/// Game Winner enum
enum GameWinner {o, x, draw, none}

/// Game Connection enum
enum GameConn {online, offline}

enum GameMode {
  classicSingle,
  nineSingle,
  powersSingle,
  classicTournament,
  nineTournament,
  powersTournament
}

enum GameType {
  classicSingleTiered,
  classicSingleRandom,
  classicDailyTournament,
  classicWeeklyTournament,
  classicMonthlyTournament,
  nineSingleTiered,
  nineSingleRandom,
  nineDailyTournament,
  nineWeeklyTournament,
  nineMonthlyTournament,
  powersSingleTiered,
  powersSingleRandom,
  powersDailyTournament,
  powersWeeklyTournament,
  powersMonthlyTournament
}

enum Game{
  classic,
  nine,
  powers
}

/// User Session enum
enum UserSession {guest, completeUser, unverifiedUser, incompleteUser, noUser, loading, restrictedUser}

const publicTournamentCapacity = 4;


enum RequestStatus {
 pending,
 accepted,
 rejected
}



