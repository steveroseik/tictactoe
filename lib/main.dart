import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Controllers/dataEngine.dart';
import 'package:tictactoe/UIUX/customWidgets.dart';
import 'package:tictactoe/UIUX/themesAndStyles.dart';
import 'package:tictactoe/difficultySelect.dart';
import 'package:tictactoe/experimentalGame.dart';
import 'package:tictactoe/gamePage.dart';
import 'package:tictactoe/gameSelect.dart';
import 'package:tictactoe/game_nav.dart';
import 'package:tictactoe/homeTrial.dart';
import 'package:tictactoe/login_nav.dart';

import 'SignUp/signup.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DataEngine dataEngine = DataEngine();
  int pageState = 0;

  Future debounceConnection() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Widget loadingWidget = const LoadingWidget(
      key: Key('loadingWDISSD'), circular: true, single: true);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DataEngine>(
        create: (context) => dataEngine,
        child: Sizer(builder: (context, orientation, deviceType) {
          return Consumer<DataEngine>(builder: (context, dataEng, child) {
            return MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
                fontFamily: 'QUARTZO'
              ),
              home: Stack(
                children: [
                  StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.userChanges().distinct(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        pageState = 1;
                      } else {
                        pageState = 0;
                      }
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                        child: (pageState == 1 || dataEng.isSignedIn)
                            ? const GameNav(
                          key: Key('gameansds'),)
                            : Stack(
                                key: Key('STCKEY'),
                                children: [
                                  const LoginNav(),
                                  AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 500),
                                      transitionBuilder: (child, animation) =>
                                          FadeTransition(
                                              opacity: animation, child: child),
                                      child: (snapshot.connectionState ==
                                              ConnectionState.active)
                                          ? Container()
                                          : loadingWidget)
                                ],
                              ),
                      );
                    },
                  ),
                ],
              ),
            );
          });
        }));
  }
}
