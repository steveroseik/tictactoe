

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