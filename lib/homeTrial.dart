import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PatternAnimationScreen(),
    );
  }
}

class PatternAnimationScreen extends StatefulWidget {
  @override
  _PatternAnimationScreenState createState() => _PatternAnimationScreenState();
}

class _PatternAnimationScreenState extends State<PatternAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Define two instances of your pattern image
  Widget leftPattern = Image.asset('assets/patternXO.png',
      scale: 4.46, repeat: ImageRepeat.repeat);
  Widget rightPattern = Image.asset('assets/patternXO.png',
      scale: 4.46, repeat: ImageRepeat.repeat, color: Colors.white, colorBlendMode: BlendMode.modulate,);

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
      backgroundColor: Colors.deepPurple,
      body: Transform.scale(
        scale: 1.3,
        child: Transform.rotate(
          angle: pi / -12.0,
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 3,
            child: ShaderMask(
              blendMode: BlendMode.xor,
              shaderCallback: (Rect bounds) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purpleAccent, Colors.deepPurple],
              ).createShader(bounds),
              child: Stack(
                children: [
                  // Left pattern initially on the left side of the screen
                  Positioned(
                    left: 0,
                    top: -_controller.value * MediaQuery.of(context).size.width,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 5,
                      height: MediaQuery.of(context).size.height / 2,
                      child: leftPattern,
                    ),
                  ),
                  // Right pattern initially just to the right of the left pattern
                  Positioned(
                    left: 0,
                    top:
                    (1 - _controller.value) * MediaQuery.of(context).size.width,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 5,
                      height: MediaQuery.of(context).size.height / 2,
                      child: rightPattern,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
