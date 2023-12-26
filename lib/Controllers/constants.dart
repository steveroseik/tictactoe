

//SHARED PREFS

const hasGuest = 'hasGuest';

enum GameState { connecting, waiting, starting, started, paused, ended }

enum TState { connecting, waiting, starting, started, ended}

enum GameConn {online, offline}


enum UserSession {guest, completeUser, unverifiedUser, incompleteUser, noUser, loading, restrictedUser}

const publicTournamentCapacity = 4;