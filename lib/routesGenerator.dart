
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:tictactoe/SignUp/signup.dart';
import 'package:tictactoe/UIUX/customWidgets.dart';
import 'package:tictactoe/charactersPage.dart';
import 'package:tictactoe/difficultySelect.dart';
import 'package:tictactoe/experimentalGame.dart';
import 'package:tictactoe/gamePage.dart';
import 'package:tictactoe/gameSelect.dart';
import 'package:tictactoe/LogIn/loginPage.dart';

import 'cubeGame.dart';
import 'experimentalGame2.dart';
import 'game_mode_page.dart';


class Routes{
  static const gameRoot = '/';
  static const  mainRoot= '/';
  static const classicGameModeSelect = '/classicGameMain';
  static const classicGameDifficultySelect = '/diff';
  static const classicGameMain = '/game';
  static const experimentalGameMain = '/experimentalGameMain';
  static const experimentalGameMain2 = '/experimentalGameMain2';
  static const experimentalGameMain3 = '/experimentalGameMain3';

}

class RoutesGen{

  static Route loginNavigation(RouteSettings settings){
    final args = settings.arguments;

    switch(settings.name){

      case Routes.gameRoot: return MaterialPageRoute(builder: (_) => LoginPage());
      case '/signup': return MaterialPageRoute(builder: (_) => SignupPage());

      default: return MaterialPageRoute(builder: (_) => Scaffold(body: Text('ERROR')));
    }
  }

  static Route gameNavigation(RouteSettings settings){
    final args = settings.arguments;

    switch(settings.name){

      case Routes.gameRoot : return MaterialPageRoute(builder: (_) => GameModeSelectPage());
      case Routes.classicGameModeSelect : return MaterialPageRoute(builder: (_) => ClassicGameSelectPage());
      case Routes.experimentalGameMain : return MaterialPageRoute(builder: (_) => CubeGame());
      case Routes.experimentalGameMain2 : return MaterialPageRoute(builder: (_) => CubeGame2());
      case Routes.experimentalGameMain3 : return MaterialPageRoute(builder: (_) => CubeGame3());
      case Routes.classicGameDifficultySelect : return MaterialPageRoute(builder: (_) => DifficultySelectPage());
      case Routes.classicGameMain: return MaterialPageRoute(builder: (_) => GamePage());
      case '/characters': return MaterialPageRoute(builder: (_) => CharactersPage());
      case '/boardOfNine':
        if (args is List) return MaterialPageRoute(builder: (context) => NinesBoardPage(child: args[0], tag: args[1]));
        return _errorRoute();

      default: return MaterialPageRoute(builder: (_) => Scaffold(body: Text('ERROR')));
    }
  }
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return const Scaffold( // AppBar
        body: Center(
          child: Text('ERROR'),
        ), // Center
      ); // Scaffold
    }); // Material PageRoute
  }
}