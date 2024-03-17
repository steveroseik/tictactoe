import 'package:flutter/material.dart';
import 'package:tictactoe/ClassicGame/classicGameMain.dart';
import 'package:tictactoe/Friends/friendsPage.dart';
import 'package:tictactoe/Friends/hostTournamentPage.dart';
import 'package:tictactoe/Leaderboards/leaderboardPage.dart';
import 'package:tictactoe/Leaderboards/scoresPage.dart';
import 'package:tictactoe/Main%20Screens/multiplayerSingleSelectPage.dart';
import 'package:tictactoe/Notifications/notificationsPage.dart';
import 'package:tictactoe/PowersGame/Characters/core.dart';
import 'package:tictactoe/PowersGame/Pages/characterSelectPage.dart';
import 'package:tictactoe/PowersGame/powersGameMain.dart';
import 'package:tictactoe/SignIn/signInPage.dart';
import 'package:tictactoe/SignUp/signup.dart';
import 'package:tictactoe/Store/storeHome.dart';
import 'package:tictactoe/Tournaments/classicTRoom.dart';
import 'package:tictactoe/Tournaments/classicTournamentSelection.dart';
import 'package:tictactoe/Tournaments/nineTRoom.dart';
import 'package:tictactoe/Tournaments/nineTournamentSelection.dart';
import 'package:tictactoe/Tournaments/powersTRoom.dart';
import 'package:tictactoe/Tournaments/powersTournamentSelection.dart';
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
  static const nineTournamentRoom = '/nineTournamentRoom';
  static const powersTournamentRoom = '/powersTournamentRoom';
  static const classicTournamentSelection = '/classicTournaments';
  static const nineTournamentSelection = '/nineTournaments';
  static const powersTournamentSelection = '/powersTournaments';
  static const ninesGameMain = '/nineGameMain';
  static const powersGameMain = '/powersGameMain';
  static const experimentalGameMain2 = '/experimentalGameMain2';
  static const experimentalGameMain3 = '/experimentalGameMain3';
  static const gameModeSelection = '/gameModeSelection';
  static const powersCharacterSelect = '/powersCharacterSelect';
  static const coinToss = '/coinToss';
  static const storeHome = '/storeHome';
  static const friendsPage = '/friendsPage';
  static const hostTournamentPage = '/hostTournamentPage';
  static const notificationsPage = '/notifcationsPage';
  static const leaderboardPage = '/leaderboardPage';
  static const scoresPage = '/scoresPage';



}

class RoutesGen {
  static Route loginNavigation(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case Routes.gameRoot:
        return GamePageRoute(builder: (_) => SignInPage());
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
        if (args != null && args is Map<String, dynamic>) {
          return GamePageRoute(
              builder: (_) => NineGameMain(
                    inTournament: args['inTournament'] ?? false,
                    roomInfo: args['roomInfo']!,
                    uid: args['uid']!,
                  ));
        }
        return GamePageRoute(builder: (_) => NineGameMain());
      case Routes.powersGameMain:
        if (args is Character) {
          return GamePageRoute(builder: (_) => PowersGameMain(character: args));
        }
        if (args is Map<String, dynamic>) {
          return GamePageRoute(builder: (_) => PowersGameMain(
              uid: args['uid']!,
              roomInfo: args['roomInfo']!,
              inTournament: args['inTournament']!,
              character: args['character']!));
        }
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
      case Routes.nineTournamentSelection:
        return GamePageRoute(builder: (_) => NineTournamentSelection());
      case Routes.nineTournamentRoom:
        return GamePageRoute(builder: (_) => NineTournamentRoom());
      case Routes.powersTournamentSelection:
        return GamePageRoute(builder: (_) => PowersTournamentSelection());
      case Routes.powersTournamentRoom:
        if (args is Character)
          return GamePageRoute(
              builder: (_) => PowersTournamentRoom(myCharacter: args));
        return _errorRoute();
      case Routes.powersCharacterSelect:
        if (args is bool)
          return GamePageRoute(
              builder: (_) => PowersCharacterSelectPage(tournament: args));
        return GamePageRoute(builder: (_) => PowersCharacterSelectPage());
      case '/characters':
        return GamePageRoute(builder: (_) => CharactersPage());
      case Routes.coinToss:
        return GamePageRoute(
            builder: (_) => CoinToss(
                  onEnd: () {},
                ));
      case Routes.storeHome:
        return GamePageRoute(builder: (_) => storeHome());

      case Routes.friendsPage:
        return GamePageRoute(
            builder: (_) => FriendsPage(friendNames: ['shahd', 'steven']));

      case Routes.hostTournamentPage:
        if (args is String)
          return GamePageRoute(
              builder: (_) => HostTournamentPage(friendId: args));
        return _errorRoute();

      case Routes.notificationsPage:
        return GamePageRoute(builder: (_) => const NotificationsPage());
        
        case Routes.leaderboardPage:
        return GamePageRoute(builder: (_) => const LeaderboardPage());

        case Routes.scoresPage:
        return GamePageRoute(builder: (_) => const ScoresPage());

        
      default:
        return _errorRoute();
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
