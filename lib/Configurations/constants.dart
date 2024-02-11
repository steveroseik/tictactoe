

class Const{
  static const nullCell = -1;
  static const xCell = 1;
  static const oCell = 0;
  /// quantum state cell
  static const qCell = 2;

  static const gameServerUrl = 'ws://192.168.1.5:3000';

  static const int speedRoundDuration = 3;

  static const int classicRoundDuration = 7;

  static const int nineRoundDuration = 10;

  static const int powersRoundDuration = 8;

  static const Duration classicGameDuration = Duration(seconds: classicRoundDuration * (9));

  static const Duration nineGameDuration = Duration(seconds: nineRoundDuration * (81));

  static const Duration powersGameDuration = Duration(seconds: powersRoundDuration * (49));
}



//SHARED PREFS

const hasGuest = 'hasGuest';

/// Game State enum
enum GameState { connecting, waiting, starting, started, coinToss, paused, ended }

/// Game Winner enum
enum GameWinner {o, x, draw, none}

/// Game Connection enum
enum GameConn {online, offline}

enum GameMode { classicSingle, nineSingle, powersSingle, classicTournament, nineTournament, powersTournament}

/// User Session enum
enum UserSession {guest, completeUser, unverifiedUser, incompleteUser, noUser, loading, restrictedUser}

const publicTournamentCapacity = 4;


