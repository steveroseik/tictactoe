import 'dart:async';

import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/Providers/authentication.dart';
import 'package:tictactoe/Providers/apiLibrary.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/Providers/gameBrain.dart';
import 'package:tictactoe/objects/powerRoomObject.dart';
import 'package:tictactoe/objects/userObject.dart';

import 'Challenges/challengeManager.dart';


final sessionProvider = ChangeNotifierProvider<SessionProvider>(
        (ref) => SessionProvider(ref));

class SessionProvider extends ChangeNotifier{

  bool _hasData = false;
  bool _isGuest = false;
  bool _isLoading = false;
  UserSession? lastSession;
  UserObject? currentUser;
  GameManager gameManager = GameManager();
  ChangeNotifierProviderRef<SessionProvider> ref;


  late StreamController<UserSession> authController;

  get isSignedIn => (_isGuest || _hasData);
  get isLoading => _isLoading;

  Authentication get auth => ref.read(authProvider);
  ApiLibrary get apiLib => ref.read(apiProvider);
  ChallengeManager get challengeManager => ref.read(challengeProvider);


  SessionProvider(this.ref) {
    authController = StreamController<UserSession>.broadcast();

  }


  setGuest() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(hasGuest, true);
    _isGuest = true;
    authController.add(UserSession.guest);
    notifyListeners();
  }

  signOut() async{
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(hasGuest)){
      prefs.remove(hasGuest);
    }
    _isGuest = false;
    FirebaseAuth.instance.signOut();
    authController.add(UserSession.noUser);
    currentUser = null;
    notifyListeners();
  }


  updateSession(UserSession session) async{
    if (lastSession == null || lastSession != session){
      lastSession = session;
      authController.add(session);
      print('updated');
    }
  }


  updateFirebaseAuth({
    required User? userData}) async{

    if (userData != null){
      if (Authentication.isEmailVerified(userData)){
        updateSession(UserSession.loading);
        final user = await apiLib.getUser();
        if (user != null){
          currentUser = user;
          updateSession(UserSession.completeUser);
        }else{
          updateSession(UserSession.incompleteUser);
        }
      }else{
        updateSession(UserSession.unverifiedUser);
      }
    }else{
      currentUser = null;
      updateSession(UserSession.noUser);
    }
  }

  Future<UserObject?> fetchOpponent(GameRoom roomInfo) async{
    final opponent = roomInfo.users
        .firstWhereOrNull((e) => e.userId != currentUser?.id);
    if (opponent == null) return null;

    return apiLib.getUser(id: opponent.userId);
  }


  ///TODO: FIX METFAGARAAA
  UserObject? getOppData(String id){
    return null;
    // return await apiLib.getUser(id: id);
  }

  bool initiateNewGame({required GameType mode}){

    if (currentUser == null) return false;
    return gameManager.newGame(mode: mode, user: currentUser!);

  }

  bool startGame(){
    if (gameManager.currentState != GameState.waiting) return false;
    gameManager.currentState = GameState.started;
    return true;
  }

  Future<bool> endGame(GameResult result) async{

    if (gameManager.currentState != GameState.started
    || currentUser == null) return false;
    final transaction = gameManager.exportTransaction(currentUser!, result);
    apiLib.updateUserGameTransaction(transaction);
    //TODO:: continue
    return false;
  }

}

