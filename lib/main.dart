import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/Controllers/dataEngine.dart';
import 'package:tictactoe/UIUX/customWidgets.dart';
import 'package:tictactoe/gamePage.dart';
import 'package:tictactoe/homeTrial.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DataEngine>(
      create: (context) => dataEngine,
      child: Sizer(
            builder: (context, orientation, deviceType) {
            return Consumer<DataEngine>(
              builder: (context, dataEng, child) {
                return MaterialApp(
                  title: 'Flutter Demo',
                  theme: ThemeData(
                    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                    useMaterial3: true,
                  ),
                  home: StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.userChanges(),
                    builder: (context, snapshot){
                      print('stream: ${snapshot.connectionState}');
                      return snapshot.connectionState == ConnectionState.waiting ?
                      const Scaffold(body: Center(child: CircularProgressIndicator())) : FutureBuilder(
                        future: Future.delayed(const Duration(milliseconds: 200)),
                        builder: (context, futureSnap){
                          print('future: ${futureSnap.connectionState}');

                          //TODO:: RETURN THE PAGE YOU ARE TESTING
                          return Container(child: Text('Check main.dart line 55'));
                          return LoadingWidget(circular: false);
                          return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                              child: futureSnap.connectionState == ConnectionState.done ? snapshot.hasData ? GamePage() : HomeScreen()
                              :const Scaffold(backgroundColor: Colors.blue, body: Center(child: CircularProgressIndicator())));
                        },
                      );
                    },
                  ),
                );
              }
            );
          }
        )
    );
  }
}