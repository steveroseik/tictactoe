import '../Configurations/constants.dart';

class ChallengePayload{

  ChallengePayloadType type;
  GameStatistics? statistics;

  ChallengePayload({required this.type, this.statistics});
}

class GameStatistics{
  GameType type;
  GameResult result;
  int powersCount;
  int score;
  int experience;
  int tournamentRound;

  GameStatistics({required this.type, required this.result,
    this.powersCount = 0, this.score = 0,
    this.experience = 0, this.tournamentRound = 0});

}