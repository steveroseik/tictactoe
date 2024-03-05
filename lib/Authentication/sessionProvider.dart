import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/Authentication/authentication.dart';
import 'package:tictactoe/BackendMethods/apiLibrary.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/objects/userObject.dart';


final sessionProvider = ChangeNotifierProvider<SessionProvider>(
        (ref) => SessionProvider(ref));

class SessionProvider extends ChangeNotifier{

  bool _hasData = false;
  bool _isGuest = false;
  bool _isLoading = false;
  UserSession? lastSession;
  UserObject? currentUser;
  ChangeNotifierProviderRef<SessionProvider> ref;


  late StreamController<UserSession> authController;

  get isSignedIn => (_isGuest || _hasData);
  get isLoading => _isLoading;

  Authentication get auth => ref.read(authProvider);
  ApiLibrary get apiLib => ref.read(apiLibrary);


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

        final user = await apiLib.user();
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
      updateSession(UserSession.noUser);
    }
  }

}

