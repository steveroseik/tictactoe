

class Const{
  static const nullCell = -1;
  static const xCell = 1;
  static const oCell = 0;
  /// quantum state cell
  static const qCell = 2;

  static const gameServerUrl = 'ws://192.168.1.47:3000';

  static const double classicGameDurationInSeconds = 5 * 60;

  static const double ninesGameDurationInSeconds = 27 * 60;

  static const double powersGameDurationInSeconds = 16 * 60;
}



//SHARED PREFS

const hasGuest = 'hasGuest';

/// Game State enum
enum GameState { connecting, waiting, starting, started, paused, ended }

/// Tournament State enum
enum TState { connecting, waiting, starting, started, ended }

/// Game Winner enum
enum GameWinner {o, x, draw, none}

/// Game Connection enum
enum GameConn {online, offline}

/// User Session enum
enum UserSession {guest, completeUser, unverifiedUser, incompleteUser, noUser, loading, restrictedUser}

const publicTournamentCapacity = 4;


