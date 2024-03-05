import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/Providers/getIt.dart';
import 'package:tictactoe/Providers/socketProvider.dart';
import 'package:tictactoe/SignUp/signupCompletion.dart';
import 'package:tictactoe/SignUp/verification.dart';
import 'package:tictactoe/Authentication/sessionProvider.dart';
import 'package:tictactoe/UIUX/customWidgets.dart';
import 'package:tictactoe/game_nav.dart';
import 'package:motion/motion.dart';
import 'package:tictactoe/login_nav.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initGetIt();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Motion.instance.initialize();

  /// Globally set the sensors sampling rate to 60 frames per second.
  Motion.instance.setUpdateInterval(60.fps);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  int pageState = 0;

  late StreamController<User?> firebaseStream;

  Future debounceConnection() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Widget loadingWidget = const LoadingPage(
      key: Key('loadingWDISSD'), circular: true, single: true);

  @override
  void initState() {
    firebaseStream = StreamController<User?>.broadcast();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initFirebaseStream();
    });

    initSocketSingleton();
    super.initState();
  }

  initFirebaseStream(){
    final sess = ref.read(sessionProvider);
    firebaseStream.addStream(FirebaseAuth.instance.authStateChanges());
    firebaseStream.stream.listen((userData) {
      sess.updateFirebaseAuth(userData: userData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
              fontFamily: 'coolvetica'
          ),
          home: Stack(
            children: [
              StreamBuilder<UserSession?>(
                stream: session.authController.stream,
                builder: (context, snapshot) {
                  if (snapshot.data == UserSession.noUser){
                    return LoginNav();
                  }else if (snapshot.data == UserSession.unverifiedUser){
                    return VerificationPage();
                  }else if (snapshot.data == UserSession.incompleteUser){
                    return SignupCompletionPage();
                  }else if (snapshot.data == UserSession.completeUser
                      || snapshot.data == UserSession.guest){

                    return GameNav();
                  }else{
                    return loadingWidget;
                  }
                },
              ),
            ],
          ),
        );
      }
    );
  }
}
