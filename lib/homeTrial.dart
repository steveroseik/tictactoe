import 'dart:math';

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBlue,
      body: Stack(
        children: [
          Transform.scale(
            scale: 1.3,
            child: Transform.rotate(
              angle: pi / -12.0,
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 3,
                child: ShaderMask(
                  blendMode: BlendMode.xor,
                  shaderCallback: (Rect bounds) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [colorBlue.withOpacity(0.5), colorBlue],
                  ).createShader(bounds),
                  child: Stack(
                    children: [
                      // Left pattern initially on the left side of the screen
                      Positioned(
                        left: 0,
                        top: -_controller.value * 300,
                        child: Container(
                          width: 600,
                          height: 600,
                          child: leftPattern,
                        ),
                      ),
                      // Right pattern initially just to the right of the left pattern
                      Positioned(
                        left: 0,
                        top:
                        (1 - _controller.value) * 300,
                        child: Container(
                          width: 600,
                          height: 600,
                          child: rightPattern,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              children: [
                SizedBox(height: 40.h),
                TextFormField(
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
                  style: const TextStyle(color: colorLightYellow, fontWeight: FontWeight.w600),
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
                  child: ElevatedButton(onPressed: (){},
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
    );
  }
}
