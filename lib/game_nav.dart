import 'package:flutter/material.dart';
import 'package:tictactoe/routesGenerator.dart';


class GameNav extends StatelessWidget {
  const GameNav({super.key});

  @override
  Widget build(BuildContext context) {
    return const Navigator(
      initialRoute: '/',
      onGenerateRoute: RoutesGen.gameNavigation,
    );
  }
}
