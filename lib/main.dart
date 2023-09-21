import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/Controllers/dataEngine.dart';
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
                      dataEng.modifyLoginState(state: snapshot.connectionState, userData: snapshot.data);

                      return dataEngine.isLoading ? const Scaffold(body: Center(child: CircularProgressIndicator(),),)
                          : dataEng.isSignedIn ? GamePage() :
                      HomeScreen();

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