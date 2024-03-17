

import 'package:collection/collection.dart';
import 'package:tictactoe/PowersGame/Characters/core.dart';
import 'package:tictactoe/spritesConfigurations.dart';

class Const{

  static const storage = 'tictac_data_storage';
  static const challengesStorage = 'challenges_storage';

  static const nullCell = -1;
  static const xCell = 1;
  static const oCell = 0;
  /// quantum state cell
  static const qCell = 2;

  static const baseUrl = 'http://172.20.10.4:3002';

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

  static const powersSingleTieredExperienceReward = 500;
  // static const powersSingleRandomExperienceReward = 200;

  static const int powersTournamentDailyExperienceReward = 1000;
  static const int powersTournamentWeeklyExperienceReward = 1500;
  static const int powersTournamentMonthlyExperienceReward = 3000;

  static const singleTieredScoreReward = 100;
  static const singleTieredScorePenalty = 50;

  static const tournamentDailyReward = 1000;
  // static const singleTournamentDailyPenalty = 100;

  static const tournamentWeeklyReward = 1000;
  // static const singleTournamentWeeklyPenalty = 100;

  static const tournamentMonthlyReward = 1000;
  // static const singleTournamentMonthlyPenalty = 200;



}



//SHARED PREFS

const hasGuest = 'hasGuest';

/// Game State enum
enum GameState { connecting, waiting, starting, started, coinToss, paused, ended }

/// Game Winner enum
enum GameWinner {o, x, draw, none}

/// Game Result
enum GameResult {win, lose, draw}

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
  noType,
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
  powersMonthlyTournament,
  friendlySingleMatch,
  friendlyTournament
}

/// Coin types
enum CoinType { bronze, silver, gold}

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

enum ResetType{
  daily,
  match,
}

enum CountType{
  play,
  win,
  score,
  experience,
  powerPlay,
  ///firstPower
  ///secondPower
  noPowers,
  dailyChallenge,
  tournamentSemi,
  tournamentFinal,
  invitation,
  counter,
}

enum ChallengePayloadType{
  game,
  challenge,
  invitation,
}

CoinType? getCoinType(dynamic value) {
  try {
    return CoinType.values.firstWhereOrNull(
          (e) => e.toString().contains(value),
    );
  } catch (e) {
    return null;
  }
}

GameType? getGameType(dynamic value) {
  try {
    return GameType.values.firstWhereOrNull(
          (e) => e.toString().contains(value),
    );
  } catch (e) {
    return null;
  }
}


CharacterType? getCharacterType(dynamic value) {
  try {
    return CharacterType.values.firstWhereOrNull(
          (e) => e.toString().contains(value),
    );
  } catch (e) {
    return null;
  }
}

CountType? getCountType(dynamic value) {
  try {
    return CountType.values.firstWhereOrNull(
          (e) => e.toString().contains(value),
    );
  } catch (e) {
    return null;
  }
}

ResetType? getResetType(dynamic value) {
  try {
    return ResetType.values.firstWhereOrNull(
          (e) => e.toString().contains(value),
    );
  } catch (e) {
    return null;
  }
}


