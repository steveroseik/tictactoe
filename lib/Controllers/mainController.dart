import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/Authentication/authentication.dart';
import 'package:tictactoe/Controllers/constants.dart';



class MainController extends ChangeNotifier{

  bool _hasData = false;
  bool _isGuest = false;
  bool _isLoading = true;


  late StreamController<UserSession> authController;
  get isSignedIn => (_isGuest || _hasData);
  get isLoading => _isLoading;

  MainController() {

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
    notifyListeners();
  }


  updateSession(UserSession session){
    authController.add(session);
  }


  updateFirebaseAuth({
    required User? userData}) async{
    final lastSession = authController.stream.last;
    if (userData != null){
      if (Authentication.isEmailVerified(userData)){
        /// change to isUserinDb()
        authController.add(UserSession.loading);
        if (true){
          authController.add(UserSession.completeUser);
        }else{
          authController.add(UserSession.incompleteUser);
        }
      }else{
        authController.add(UserSession.unverifiedUser);
      }
    }else{
      authController.add(UserSession.noUser);
    }
    // notifyListeners();

  }


}

