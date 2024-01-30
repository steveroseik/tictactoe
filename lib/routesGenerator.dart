import 'package:flutter/material.dart';
import 'package:tictactoe/ClassicGame/classicGameMain.dart';
import 'package:tictactoe/LogIn/loginPage.dart';
import 'package:tictactoe/Main%20Screens/multiplayerSingleSelectPage.dart';
import 'package:tictactoe/PowersGame/Characters/core.dart';
import 'package:tictactoe/PowersGame/Pages/characterSelectPage.dart';
import 'package:tictactoe/PowersGame/powersGameMain.dart';
import 'package:tictactoe/SignUp/signup.dart';
import 'package:tictactoe/Store/storeHome.dart';
import 'package:tictactoe/Tournaments/classicTRoom.dart';
import 'package:tictactoe/Tournaments/classicTournamentSelection.dart';
import 'package:tictactoe/Tournaments/tournamentHome.dart';
import 'package:tictactoe/charactersPage.dart';
import 'package:tictactoe/coinToss.dart';
import 'package:tictactoe/difficultySelect.dart';
import 'package:tictactoe/nineGame/nineGameMain.dart';

import 'Main Screens/homePage.dart';
import 'cubeGame.dart';

class GamePageRoute<T> extends MaterialPageRoute<T> {
  late bool scale;
  GamePageRoute(
      {required WidgetBuilder builder,
      RouteSettings? settings,
      this.scale = false})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // if (settings.name == '/') return child;
    // Fades between routes. (If you don't want any animation,
    // just return child.)
    if (scale) {
      return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child));
    }
    return FadeTransition(opacity: animation, child: child);
  }
}

class Routes {
  static const gameRoot = '/';
  static const mainRoot = '/';
  static const classicGameModeSelect = '/classicGameMain';
  static const classicGameDifficultySelect = '/diff';
  static const classicGameMain = '/game';
  static const tournamentsHome = '/tournaments';
  static const classicTournamentRoom = '/classicTournamentRoom';
  static const classicTournamentSelection = '/classicTournaments';
  static const ninesGameMain = '/nineGameMain';
  static const powersGameMain = '/powersGameMain';
  static const experimentalGameMain2 = '/experimentalGameMain2';
  static const experimentalGameMain3 = '/experimentalGameMain3';
  static const gameModeSelection = '/gameModeSelection';
  static const powersCharacterSelect = '/powersCharacterSelect';
  static const coinToss = '/coinToss';
  static const storeHome = '/storeHome';
}

class RoutesGen {
  static Route loginNavigation(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case Routes.gameRoot:
        return GamePageRoute(builder: (_) => LoginPage());
      case '/signup':
        return GamePageRoute(builder: (_) => SignupPage());

      default:
        return GamePageRoute(builder: (_) => Scaffold(body: Text('ERROR')));
    }
  }

  static Route gameNavigation(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case Routes.gameRoot:
        return GamePageRoute(builder: (_) => HomePage());
      case Routes.gameModeSelection:
        return GamePageRoute(builder: (_) => MultiplayerSingleSelectPage());
      case Routes.classicGameModeSelect:
        return GamePageRoute(builder: (_) => MultiplayerSingleSelectPage());
      case Routes.ninesGameMain:
        return GamePageRoute(builder: (_) => NineGameMain());
      case Routes.powersGameMain:
        if (args is Character)
          return GamePageRoute(builder: (_) => PowersGameMain(character: args));
        return _errorRoute();
      // case Routes.experimentalGameMain2 : return GamePageRoute(builder: (_) => PowersGameModule());
      case Routes.experimentalGameMain3:
        return GamePageRoute(builder: (_) => CubeGame3());
      case Routes.classicGameDifficultySelect:
        return GamePageRoute(builder: (_) => DifficultySelectPage());
      case Routes.classicGameMain:
        return GamePageRoute(builder: (_) => ClassicGameMain());
      case Routes.tournamentsHome:
        return GamePageRoute(builder: (_) => TournamentsHomePage());
      case Routes.classicTournamentSelection:
        return GamePageRoute(builder: (_) => ClassicTournamentSelection());
      case Routes.classicTournamentRoom:
        return GamePageRoute(builder: (_) => ClassicTournamentRoom());
      case Routes.powersCharacterSelect:
        return GamePageRoute(builder: (_) => CharacterSelectPage());
      case '/characters':
        return GamePageRoute(builder: (_) => CharactersPage());
      case Routes.coinToss:
        return GamePageRoute(
            builder: (_) => CoinToss(
                  onEnd: () {},
                ));
      case Routes.storeHome:
        return GamePageRoute(builder: (_) => storeHome());
      default:
        return GamePageRoute(builder: (_) => Scaffold(body: Text('ERROR')));
    }
  }

  static Route<dynamic> _errorRoute() {
    return GamePageRoute(builder: (context) {
      return Scaffold(
        // AppBar
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ERROR'),
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Go Back"))
            ],
          ),
        ), // Center
      ); // Scaffold
    }); // Material PageRoute
  }
}
