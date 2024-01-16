import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/UIUX/themesAndStyles.dart';
import 'package:tictactoe/spritesConfigurations.dart';

import 'UIUX/customWidgets.dart';

const double kCoinRadius = 50.0;

class CoinToss extends StatefulWidget {
  final Function() onEnd;
  const CoinToss({super.key, required this.onEnd});

  @override
  State<CoinToss> createState() => _CoinTossState();
}

class _CoinTossState extends State<CoinToss> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _toss;
  late Animation<Matrix4> _turn;

  bool faceOne = false;
  bool? winner;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    )..addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
      }
    });
    _controller.forward().then((value) {
      setState(() {
        widget.onEnd();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _toss = _TossTween(
      height: MediaQuery.of(context).size.height,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.slowMiddle,
      ),
    );

    _turn = _TurnTween().animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            if (_turn.value.getRotation().up[1].isNegative){
              faceOne = true;
            }else{
              faceOne = false;
            }
            return Transform.translate(
              offset: Offset(size.width / 2 - kCoinRadius, _toss.value),
              child: Transform(
                  transform: _turn.value,
                  alignment: Alignment.center,
                  child:  faceOne ?
                  Transform(
                    transform: Matrix4.identity()
                      ..rotateX(pi),
                    alignment: Alignment.center,
                    child: Container(
                      width: kCoinRadius * 2,
                      height: kCoinRadius * 2,
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 5,
                            color: Colors.black,
                          ),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorPurple,
                                colorDeepOrange
                              ]
                          )
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Sprites.characterOf[characters.chameleon]!,),
                    ),
                  ) :
                  Container(
                    width: kCoinRadius * 2,
                    height: kCoinRadius * 2,
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 5,
                          color: Colors.black,
                        ),
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorPurple,
                              colorDeepOrange
                            ]
                        )
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Sprites.characterOf[characters.pirate]!,),
                  )
              ),
            );
          },
        ),
        Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: winner != null ? 1 : 0,
            child: Container(
              width: kCoinRadius * 4,
              height: kCoinRadius * 4,
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 5,
                    color: Colors.black,
                  ),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorPurple,
                        colorDeepOrange
                      ]
                  )
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Sprites.characterOf[characters.chameleon]!,),
            ),
          ),
        ),
      ],
    );
  }
}

class _TossTween extends Tween<double> {
  _TossTween({required this.height})
      : super(begin: _lerp(height, 0.0), end: _lerp(height, 1.0));

  final double height;

  @override
  double lerp(double t) => _lerp(height, t);

  static double _lerp(double height, double t) {
    final double top = height / 6;
    final double rad = t * pi * 2 + pi / 2;
    return (height - top) / 2 + (height - top) / 2 * sin(rad) + top;
  }
}

class _TurnTween extends Tween<Matrix4> {
  _TurnTween() : super(begin: _lerp(0.0), end: _lerp(1.0));

  @override
  Matrix4 lerp(double t) => _lerp(t);

  static Matrix4 _lerp(double t) {
    final newChange = t * pi * 20;
    return Matrix4.rotationX(newChange);
  }
}
