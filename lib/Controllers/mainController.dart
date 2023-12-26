import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/Controllers/constants.dart';

class MainController extends ChangeNotifier{

  bool _hasData = false;
  bool _isGuest = false;
  bool _isLoading = true;

  get isSignedIn => (_isGuest || _hasData);
  get isLoading => _isLoading;

  MainController();


  setGuest() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(hasGuest, true);
    _isGuest = true;
    notifyListeners();
  }

  signOut() async{
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(hasGuest)){
      prefs.remove(hasGuest);
    }
    _isGuest = false;
    notifyListeners();
    FirebaseAuth.instance.signOut();
  }



  modifyLoginState({
    required ConnectionState state,
    required User? userData}) async{

    switch(state){

      case ConnectionState.none:
        _isLoading = false;
        break;
      case ConnectionState.waiting:
        _isLoading = true;
        break;
      case ConnectionState.active:
        _isLoading = false;
        break;
      case ConnectionState.done:
        {
          _isLoading = false;
          if (userData != null){
            _hasData = true;
          }else{
            _hasData = false;
            final prefs = await SharedPreferences.getInstance();
            if (prefs.containsKey(hasGuest)){
              _isGuest = true;
            }else{
              _isGuest = false;
            }
          }
        }
        break;
    }

    // Future.microtask(() => notifyListeners());
    notifyListeners();

  }

}
