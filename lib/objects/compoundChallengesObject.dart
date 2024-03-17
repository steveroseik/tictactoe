import 'SequenceChallengeObject.dart';
import 'challengeObject.dart';


class CompoundChallenges{

  List<SequenceChallenge> sequenceChallenges;
  List<Challenge> singleChallenges;

  CompoundChallenges({required this.sequenceChallenges, required this.singleChallenges});



  factory CompoundChallenges.fromJson(Map<String, dynamic> json) =>
  CompoundChallenges(
      sequenceChallenges: sequenceChallengesFromJson(json['sequenceChallenges']),
      singleChallenges: challengesFromJson(json['singleChallenges']));

  toJson() => {
    "sequenceChallenges": sequenceChallengesToJson(sequenceChallenges),
    "singleChallenges": challengesToJson(singleChallenges)
  };
}