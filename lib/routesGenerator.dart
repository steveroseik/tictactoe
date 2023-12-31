import 'package:flutter/material.dart';
import 'package:tictactoe/SignUp/signup.dart';
import 'package:tictactoe/Tournaments/classicTRoom.dart';
import 'package:tictactoe/Tournaments/classicTournamentSelection.dart';
import 'package:tictactoe/Tournaments/tournamentHome.dart';
import 'package:tictactoe/UIUX/customWidgets.dart';
import 'package:tictactoe/charactersPage.dart';
import 'package:tictactoe/ClassicGame/classicGameMain.dart';
import 'package:tictactoe/difficultySelect.dart';
import 'package:tictactoe/nineGame/nineGameMain.dart';
import 'package:tictactoe/ClassicGame/classicGameModule.dart';
import 'package:tictactoe/gameSelect.dart';
import 'package:tictactoe/LogIn/loginPage.dart';

import 'cubeGame.dart';
import 'PowersGame/powerGameModule.dart';
import 'homePage.dart';


class GamePageRoute<T> extends MaterialPageRoute<T> {
  late bool scale;
  GamePageRoute({ required WidgetBuilder builder, RouteSettings? settings , this.scale = false})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {

    // if (settings.name == '/') return child;
    // Fades between routes. (If you don't want any animation,
    // just return child.)
    if (scale) {
      return FadeTransition(opacity: animation, child: ScaleTransition(
        scale: animation,
        child: child));
    }
    return FadeTransition(opacity: animation, child: child);
  }
}

class Routes{
  static const gameRoot = '/';
  static const  mainRoot= '/';
  static const classicGameModeSelect = '/classicGameMain';
  static const classicGameDifficultySelect = '/diff';
  static const classicGameMain = '/game';
  static const tournamentsHome = '/tournaments';
  static const classicTournamentRoom = '/classicTournamentRoom';
  static const classicTournamentSelection = '/classicTournaments';
  static const experimentalGameMain = '/experimentalGameMain';
  static const experimentalGameMain2 = '/experimentalGameMain2';
  static const experimentalGameMain3 = '/experimentalGameMain3';


}

class RoutesGen{

  static Route loginNavigation(RouteSettings settings){
    final args = settings.arguments;

    switch(settings.name){

      case Routes.gameRoot: return GamePageRoute(builder: (_) => LoginPage());
      case '/signup': return GamePageRoute(builder: (_) => SignupPage());

      default: return GamePageRoute(builder: (_) => Scaffold(body: Text('ERROR')));
    }
  }

  static Route gameNavigation(RouteSettings settings){
    final args = settings.arguments;

    switch(settings.name){

      case Routes.gameRoot : return GamePageRoute(builder: (_) => HomePage());
      case Routes.classicGameModeSelect : return GamePageRoute(builder: (_) => ClassicGameSelectPage());
      case Routes.experimentalGameMain : return GamePageRoute(builder: (_) => NineGameMain());
      // case Routes.experimentalGameMain2 : return GamePageRoute(builder: (_) => PowersGameModule());
      case Routes.experimentalGameMain3 : return GamePageRoute(builder: (_) => CubeGame3());
      case Routes.classicGameDifficultySelect : return GamePageRoute(builder: (_) => DifficultySelectPage());
      case Routes.classicGameMain: return GamePageRoute(builder: (_) => ClassicGamePage());
      case Routes.tournamentsHome: return GamePageRoute(builder: (_) => TournamentsHomePage());
      case Routes.classicTournamentSelection: return GamePageRoute(builder: (_) => ClassicTournamentSelection());
      case Routes.classicTournamentRoom: return GamePageRoute(builder: (_) => ClassicTournamentRoom());
      case '/characters': return GamePageRoute(builder: (_) => CharactersPage());

      default: return GamePageRoute(builder: (_) => Scaffold(body: Text('ERROR')));
    }
  }
  static Route<dynamic> _errorRoute() {
    return GamePageRoute(builder: (_) {
      return const Scaffold( // AppBar
        body: Center(
          child: Text('ERROR'),
        ), // Center
      ); // Scaffold
    }); // Material PageRoute
  }
}