import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tictactoe/Providers/Storage/storageProvider.dart';
import 'package:tictactoe/Providers/apiLibrary.dart';
import '../../Configurations/constants.dart';
import '../../Game Statistics/statistics.dart';
import '../../objects/SequenceChallengeObject.dart';
import '../../objects/challengeObject.dart';
import '../../spritesConfigurations.dart';
import 'challengeChecklist.dart';
import 'challengeCounter.dart';
import 'challengeSequencer.dart';
import 'challengesBase.dart';
import 'helper.dart';


final challengeProvider = Provider((ref) => ChallengeManager(ref));

class ChallengeManager extends ChangeNotifier{

  List<ChallengeSequencer> sequenceChallenges = [];
  List<ChallengeBase> singleChallenges = [];

  ProviderRef ref;


  ApiLibrary get _apiLibrary => ref.read(apiProvider);
  DataStorage get storage => ref.read(storageProvider);

  ChallengeManager(this.ref){
    initializeChallenges();
  }


  initializeChallenges() async{
    final challenges = await _apiLibrary.getChallengesOfTheDay();
    if (challenges == null) return;
    //TODO: needs to fetch cached challenges and compare before create
    createChallenges(
        seqChallenges: challenges.sequenceChallenges,
        challenges: challenges.singleChallenges);

  }

  storeChallenges() async{
    final singleChallengesJson = singleChallenges.map((e) => e.toJson()).toList();
    final sequenceChallengesJson = sequenceChallenges.map((e) => e.toJson()).toList();
    await storage.box.put(Const.challengesStorage, jsonEncode({
      'single': singleChallengesJson,
      'sequence': sequenceChallengesJson
    }));
  }

  loadChallenges() async{
    final data = await storage.box.get(Const.challengesStorage);
    if (data != null){
      final json = jsonDecode(data);
      singleChallenges = List<ChallengeBase>.from((json['single'] as List<dynamic>).map((e) {
        if (e['isCounter'] == true){
          return ChallengeCounter.fromJson(e);
        }else{
          return ChallengeChecklist.fromJson(e);
        }
      }));
      sequenceChallenges = List<ChallengeSequencer>.from((json['sequence'] as List<dynamic>)
          .map((e) => ChallengeSequencer.fromJson(e)));
    }
  }


  receiveUpdate(GameStatistics statistics){
    for (var c in singleChallenges){
      c.updateFromStatistic(statistics);
    }
    for (var seq in sequenceChallenges){
      seq.updateFromStatistic(statistics);
    }
    notifyListeners();
  }

  receiveUpdateFromGameInvitation(GameType gameType){
    for (var element in singleChallenges) {
      element.updateFromGameInvitation(gameType);
    }
  }

  /// create challenges fetched from api
  createChallenges({
    required List<SequenceChallenge> seqChallenges,
    required List<Challenge> challenges
}){
    if (seqChallenges.isNotEmpty){
      for (var e in seqChallenges) {
        try{
          sequenceChallenges.add(ChallengeSequencer(sequenceChallenge: e));
        }catch (exc){
          print('failed to process sequence challenge: ${e.id} \n $exc');
        }
      }
    }

    if (challenges.isNotEmpty){
      singleChallenges.addAll(challenges.map((e) => createSingleChallenge(challenge: e)));
    }
  }

  previewChallenges(){
    for (var seq in sequenceChallenges){
      print('sequence Challenge: ${seq.id} @ day: ${seq.dayIndex+1} finished: ${seq.isComplete}');
    }

    for (var ch in singleChallenges){
      print('single challenge: ${ch.description} finished: ${ch.isComplete}');
    }
  }

  clearExpiredChallenges() async{
    final now = DateTime.now();
    singleChallenges.removeWhere((e) => !e.isComplete && !e.endDate.isAfter(now));
    sequenceChallenges.removeWhere((e) => !e.isComplete && !e.endDate.isAfter(now));

    await storeChallenges();
  }




}


