import 'package:collection/collection.dart';
import 'package:tictactoe/Game%20Statistics/statistics.dart';

import '../../objects/challengeObject.dart';
import 'challengeChecklist.dart';
import 'challengeCounter.dart';
import 'challengesBase.dart';



/// create collection of single or tree challenges
dynamic createChallenges(List<Challenge> challenges){
  List<dynamic> resultChallenges = [];
  // find all challenges and their sub challenges (tree challenges), if any
  List<Challenge> treeChallenges = challenges.where((e) => e.childChallengeId != null).toList();
  final List<int> treeIds = treeChallenges.map((e) => e.childChallengeId!).toList();
  treeIds.removeWhere((id) => treeChallenges.firstWhereOrNull((e) => e.id == id) != null);
  treeChallenges.addAll(challenges.where((e) => treeIds.contains(e.id)));
  // create tree challenges
  if (treeChallenges.isNotEmpty){
    challenges.removeWhere((element) => treeChallenges.contains(element));
    List<ChallengeCounter> resultTrees = [];
    resultChallenges.addAll(createTreeChallenges(treeChallenges, resultTrees));
  }
  // create single challenges
  if (challenges.isNotEmpty){
    resultChallenges.addAll(List<dynamic>.from(challenges.map((e) => createSingleChallenge(challenge: e))));
  }

}

List<ChallengeBase> createTreeChallenges(List<Challenge> challenges,
    List<ChallengeBase> resultChallenges){

  if (challenges.isEmpty) return resultChallenges;

  final parentChallenge = challenges.firstWhereOrNull((e) => e.childChallengeId != null);

  if (parentChallenge == null) {
    print('parentChild is null');
    return resultChallenges;
  }

  final childChallenge = challenges.firstWhereOrNull((e) => e.id == parentChallenge.childChallengeId!);

  if (childChallenge == null) {
    print('childChallenge is null');
    return resultChallenges;
  }

  challenges.removeWhere((e) => e.id == parentChallenge.id || e.id == childChallenge.id);

  resultChallenges
      .add(createSingleChallenge(
      challenge: parentChallenge,
      childChallenge: childChallenge));

  return createTreeChallenges(challenges, resultChallenges);


}


/// create single game challenge
ChallengeBase createSingleChallenge({required Challenge challenge, Challenge? childChallenge}){
  if (challenge.checklist){
    return ChallengeChecklist(challenge: challenge);
  }else{
    return ChallengeCounter(
        challenge: challenge,
        childChallenge: childChallenge
    );
  }
}

