import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Controllers/mainController.dart';
import 'package:tictactoe/UIUX/customWidgets.dart';

import '../BackendMethods/backend.dart';
import '../UIUX/themesAndStyles.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Backend backend = Backend();

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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Consumer<MainController>(
          builder:
              (BuildContext context, MainController engine, Widget? child) {
            return Stack(
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
                              signIn();
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
                            engine.setGuest();
                          },
                          child: Text(
                            'Continue as a guest',
                            style: TextStyle(color: colorLightYellow),
                          ))
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  // emailSignIn() async {
  //   try {

  //     await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: emailField.text, password: passField.text);
  //   } on FirebaseAuthException catch (e) {
  //     print(e.message);
  //   }
  // }

  signIn() async {
  // Validate email format
  final input = emailField.text.trim();
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  try {
    String finalEmail;
    if (!emailRegex.hasMatch(input)) {
      // Input is not in email format, fetch email from backend
     
      finalEmail = await backend.getEmail(username: input);
      print("hena "+finalEmail);
    } else {
      finalEmail = input;
      print("hena2 "+finalEmail);
    }

    // Attempt sign in
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: finalEmail,
      password: passField.text,
    );

  } on FirebaseAuthException catch (e) {
    print(e.message);
  }
}

}
