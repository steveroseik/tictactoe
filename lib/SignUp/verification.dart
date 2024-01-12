import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/Controllers/mainController.dart';
import 'package:tictactoe/SignUp/signupCompletion.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({Key? key}) : super(key: key);

  @override
  State<VerificationPage> createState() =>
      _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool isEmailVerified = false;
  Timer? timer;
  int elapsedTime = 0;

  late MainController mainController;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser?.sendEmailVerification();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        elapsedTime += 3;

        if (elapsedTime >= 60) {
          timer.cancel();
          showTimeoutMessage();
        } else {
          checkEmailVerified();
        }
      });
    });
  }

  checkEmailVerified() async {
   try{
     await FirebaseAuth.instance.currentUser?.reload();

     setState(() {
       isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
     });
     if (isEmailVerified) {
       timer?.cancel();
       mainController.updateSession(UserSession.incompleteUser);
     }
   }catch (e){
     print(e);
   }
  }

  showTimeoutMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Verification timeout. Request another email.")),
    );

    // You can add additional logic here, such as allowing the user to request another verification email.
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mainController = context.watch<MainController>();
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 35),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  'Check your \n Email',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Center(
                  child: Text(
                    'We have sent you an Email on ${FirebaseAuth.instance.currentUser?.email}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                child: Center(
                  child: Text(
                    'Verifying email....',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 57),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: ElevatedButton(
                  child: const Text('Resend'),
                  onPressed: () {
                    try {
                      FirebaseAuth.instance.currentUser
                          ?.sendEmailVerification();
                    } catch (e) {
                      debugPrint('$e');
                    }
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Create user b2a
                  FirebaseAuth.instance.signOut();
                },
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
