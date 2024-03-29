import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Providers/authentication.dart';
import 'package:tictactoe/Providers/sessionProvider.dart';
import 'package:tictactoe/UIUX/customWidgets.dart';

import '../UIUX/themesAndStyles.dart';


class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<SignInPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Define two instances of your pattern image
  Widget leftPattern = Image.asset('assets/patternXO.png',
      scale: 6, repeat: ImageRepeat.repeat, color: colorLightYellow);
  Widget rightPattern = Image.asset('assets/patternXO.png',
      scale: 6, repeat: ImageRepeat.repeat, color: colorLightYellow);

  final emailField = TextEditingController();
  final passField = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _controller.addListener(() {
      setState(() {
        if (_controller.value == 1) {
          // Swap the patterns when animation completes
          final temp = leftPattern;
          leftPattern = rightPattern;
          rightPattern = temp;
          _controller.reset();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    emailField.dispose();
    passField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                      ])),
            ),
            const BackgroundScroller(),
            AppBar(
                excludeHeaderSemantics: true,
                backgroundColor: Colors.transparent),
            Positioned(
              top: 12.h,
              left: 10.w,
              child: SizedBox(
                height: 17.h,
                width: 80.w,
                child: Image.asset('assets/LOGO.png'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                children: [
                  SizedBox(height: 30.h),
                  TextFormField(
                    controller: emailField,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                        color: colorLightYellow,
                        fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: colorDarkBlue,
                      hintStyle: TextStyle(color: colorLightGrey),
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(
                        Icons.person,
                        color: colorLightYellow,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.w),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.w),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: passField,
                    style: const TextStyle(
                        color: colorLightYellow,
                        fontWeight: FontWeight.w600),
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: colorDarkBlue,
                      hintStyle: TextStyle(color: colorLightGrey),
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(
                        Icons.key_rounded,
                        color: colorLightYellow,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.w),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.w),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Forgot password",
                        style: TextStyle(color: colorLightYellow),
                      )),
                  SizedBox(height: 2.h),
                  Container(
                    width: 80.w,
                    height: 6.h,
                    child: ElevatedButton(
                        onPressed: () {
                          emailSignIn();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple.shade900,
                            foregroundColor: colorLightYellow,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.w))),
                        child: Text('Login')),
                  ),
                  SizedBox(height: 2.h),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/signup');
                    },
                    child: Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(color: colorLightYellow),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Divider(
                            thickness: 2,
                            color: colorLightYellow,
                          )),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'OR',
                          style: TextStyle(
                              color: colorLightYellow, fontSize: 16),
                        ),
                      ),
                      Expanded(
                          child: Divider(
                            thickness: 2,
                            color: colorLightYellow,
                          )),
                    ],
                  ),

                  SizedBox(
                    height: 5.h,
                  ),
                  TextButton(
                      onPressed: () {
                        session.setGuest();
                      },
                      child: Text(
                        'Continue as a guest',
                        style: TextStyle(color: colorLightYellow),
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  emailSignIn() async {
    try {
      await ref.read(authProvider).signInWithEmailAndPassword(
          emailField.text, passField.text);

    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }
}
