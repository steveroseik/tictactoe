import 'package:flutter/material.dart';
import 'package:tictactoe/routesGenerator.dart';


class LoginNav extends StatelessWidget {
  const LoginNav({super.key});

  @override
  Widget build(BuildContext context) {
    return const Navigator(
      initialRoute: '/',
      onGenerateRoute: RoutesGen.loginNavigation,
    );
  }
}
