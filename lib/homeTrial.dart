import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import 'package:sizer/sizer.dart';

import 'UIUX/themesAndStyles.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
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
    print('HEREE');
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
    return Scaffold(
      backgroundColor: colorBlue,
      body: SingleChildScrollView(
        child: Stack(
          children: [

            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                children: [
                  SizedBox(height: 40.h),
                  TextFormField(
                    controller: emailField,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: colorLightYellow, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: colorBlue.withBlue(180),
                      hintStyle: TextStyle(color: colorLightGrey),
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(Icons.person, color: colorLightYellow,),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.w),
                        borderSide: BorderSide.none
                      ),
                      focusedBorder:  OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.w),
                          borderSide: BorderSide.none
                      ),

                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: passField,
                    style: const TextStyle(color: colorLightYellow, fontWeight: FontWeight.w600),
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: colorBlue.withBlue(180),
                      hintStyle: TextStyle(color: colorLightGrey),
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(Icons.person, color: colorLightYellow,),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.w),
                          borderSide: BorderSide.none
                      ),
                      focusedBorder:  OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.w),
                          borderSide: BorderSide.none
                      ),

                    ),
                  ),
                  SizedBox(height: 3.h),
                  Container(
                    width: 80.w,
                    height: 6.h,
                    child: ElevatedButton(onPressed: (){
                      emailSignIn();
                    },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorDarkBlue,
                          foregroundColor: colorLightYellow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.w)
                          )
                        ),
                        child: Text('Login')),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  emailSignIn() async{
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailField.text, password: passField.text);
    }on FirebaseAuthException catch (e){
      print(e.message);
    }
  }
}
