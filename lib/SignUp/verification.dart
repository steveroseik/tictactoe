import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/Providers/sessionProvider.dart';
import 'package:tictactoe/UIUX/customWidgets.dart';

class VerificationPage extends ConsumerStatefulWidget {
  const VerificationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends ConsumerState<VerificationPage> {
  bool isEmailVerified = false;
  Timer? timer;
  int elapsedTime = 0;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser?.sendEmailVerification();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
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

  Future<void> checkEmailVerified() async {
    try {
      await FirebaseAuth.instance.currentUser?.reload();

      setState(() {
        isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      });
      if (isEmailVerified) {
        timer?.cancel();
        ref.read(sessionProvider).updateSession(UserSession.incompleteUser);
      }
    } catch (e) {
      print(e);
    }
  }

  void showTimeoutMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Verification timeout. Request another email.")),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepOrange,
                    Colors.deepOrange,
                    Colors.deepPurple.shade800
                  ],
                ),
              ),
            ),
            const BackgroundScroller(),
            Center(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                          'We have sent you an Email on ${FirebaseAuth.instance.currentUser?.email ?? ""}',
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
                        onPressed: () {
                          try {
                            FirebaseAuth.instance.currentUser
                                ?.sendEmailVerification();
                          } catch (e) {
                            debugPrint('$e');
                          }
                        },
                        child: const Text('Resend'),
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
          ],
        ),
      ),
    );
  }
}
