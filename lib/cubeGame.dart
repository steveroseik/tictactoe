import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Controllers/classicGameController.dart';
import 'package:tictactoe/spritesConfigurations.dart';
import 'PowersGame/core.dart';
import 'UIUX/customWidgets.dart';



enum faces {top, bottom, right, left, front, back, none}

class CubeGame3 extends StatefulWidget {
  const CubeGame3({super.key});

  @override
  State<CubeGame3> createState() => _CubeGame3State();
}

class _CubeGame3State extends State<CubeGame3> with TickerProviderStateMixin{

  Offset offset = Offset.zero;

  double _rx = 0.0;
  double _ry = 0.0;
  double _rz = 0.0;
  List<Widget> children = [];

  late AnimationController _animationController;
  late AnimationController _smoothController;
  late AnimationController _spinController;

  late TabController tabController;


  late Animation _spinAnimation;
  late Animation _animation;


  List<faces> removedFaces = [];
  late Widget right;
  late Widget front;
  late Widget back ;
  late Widget left;
  late Widget top;
  late Widget bottom;

  bool spin = false;
  bool endFace = false;
  bool spinGame = true;

  double cubeSize = 70.w;


  get rX => _rx;
  get rY => _ry;

  static double halfPi = pi/2;
  static double piAndHalf = pi * (1.5);
  static double twoPie = pi*2;

  (double, double)? lastSwipe;
  bool tapping = false;

  @override
  void initState() {
    _animationController = AnimationController(duration: const Duration(milliseconds: 3000), vsync: this)..repeat();
    _smoothController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this)..repeat();
    _spinController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this)..repeat();

    tabController = TabController(length: 2, vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    _smoothController.addListener(() {
      if (!tapping){
        if (lastSwipe != null){
          lastSwipe = (lastSwipe!.$1 * 0.95, lastSwipe!.$2 * 0.95);
          if (_rx > pi/2 && _rx < pi*1.5){
            _rx += (lastSwipe!.$1 * 0.1);
            _ry += (lastSwipe!.$2 * 0.1);
          }else{
            _rx += (lastSwipe!.$1 * 0.1);
            _ry -= (lastSwipe!.$2 * 0.1);
          }
          setState(() {
            _rx %= pi *2;
            _ry %= pi *2;
          });
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _spinAnimation = Tween(begin: 0.0, end: 1.0).animate(_spinController)..addListener(() {
        if(spinGame){
          if (spin){
            endFace = false;
            setState(() {
              _rx += 0.1;
              _rx %= pi * 2;
            });
          }else{
           if (!endFace){
             _rx += 0.02;
             _rx %= pi * 2;

             if ((_rx).abs() < 0.025 || (_rx - halfPi).abs() < 0.025  ||
                 (_rx - pi).abs() < 0.025 || (_rx - piAndHalf).abs() < 0.025  || (_rx - twoPie).abs() < 0.025 ){
               _rx += 0.025;
               _rx %= pi * 2;
               endFace = true;
             }
             setState(() {});
           }
          }
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _spinController.dispose();
    _smoothController.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate:(u) {
        if (!spinGame){
          setState(() {
            tapping = true;
          });
          if (_rx > pi/2 && _rx < pi*1.5){
            _rx += u.delta.dy * 0.01;
            _ry += u.delta.dx * 0.01;
          }else{
            _rx += u.delta.dy * 0.01;
            _ry -= u.delta.dx * 0.01;
          }
          lastSwipe = (u.delta.dy * 0.01,
          u.delta.dx * 0.01);
          setState(() {
            _rx %= pi *2;
            _ry %= pi *2;
            tapping = false;
            _smoothController.reset();
          });
          _smoothController.forward();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: 100.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.deepOrange, Colors.orange]
                )
              ),
            ),
            Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: 15.h,
                      width: 60.w,
                      child: TabBar(
                          controller: tabController,
                          onTap: (index){
                            if (index == 0) {
                              spinGame = true;
                            } else {
                              spinGame = false;
                            }
                            setState(() {
                              _ry = 0;
                            });
                          },
                          tabs: [
                        Container(
                          decoration: BoxDecoration(
                          ),
                          child: Text('Spin Game'),
                        ),
                        Container(
                          decoration: BoxDecoration(

                          ),
                          child: Text('4D Game'),
                        )
                      ]),
                    ),
                    Cube(x: _rx, y: _ry, z: _rz,
                      color: Colors.black,
                      size: cubeSize,
                      animationController: _animationController,
                      removedFaces: spinGame ? [faces.left, faces.right]: removedFaces,),
                    SizedBox(height: 20.h),
                    ElevatedButton(onPressed: (){
                      if (spinGame){
                        setState(() {
                          spin = !spin;
                        });
                      }
                    }, child: Text(spin ? 'STOP' : 'SPIN')),
                    Slider(value: _ry,
                        min: 0,
                        max: pi * 2,
                        onChanged: (value){
                          _ry = value;
                          setState(() {
                            // updateFaces(0, ry);
                          });
                        }),
                    Text(_ry.toString()),
                    Slider(value: _rz,
                        min: 0,
                        max: pi * 2,
                        onChanged: (value){
                          _rz = value;
                          setState(() {
                          });
                        }),
                    Text(_rz.toString())
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}


class Cube extends StatefulWidget {
  Cube(
      {super.key,
        required this.x,
        required this.y,
        required this.z,
        required this.color,
        required this.size,
        this.removedFaces,
        required this.animationController});

  final double x, y, z, size;
  final Color color;
  List<faces>? removedFaces;
  final AnimationController animationController;

  @override
  State<Cube> createState() => _CubeState();
}

class _CubeState extends State<Cube> with SingleTickerProviderStateMixin {



  late AnimationController animationController;
  late Animation animation;

  List<Widget> children = [];

  double _rx = 0.0;
  double _ry = 0.0;
  double _rz = 0.0;



  @override
  void initState() {
    animationController = AnimationController(duration: Duration(milliseconds: 3000), vsync: this);

    animation = Tween(begin: 0.0, end: 1.0).animate(animationController);

    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _rx = widget.x;
    _ry = widget.y;
    _rz = widget.z;
    updateFaces();
    return Container(
      height: widget.size,
      width: widget.size,
      child: Transform(
        transform: Matrix4.identity()
          ..rotateX(_rx)
          ..rotateY(_ry),
        alignment: Alignment.center,
        child: Stack(children: <Widget>[
          ...children
        ]),
      ),
    );
  }

  updateFaces(){

    if ((_rx <= (pi/2) && _rx >= 0) || _rx >= (pi*1.5)){
      if (_ry < pi / 4) {
        children = [buildBoardFace(face: faces.right, size: widget.size),
          buildBoardFace(face: faces.front, size: widget.size)];
      } else if (_ry < pi / 2) {
        children = [buildBoardFace(face: faces.front, size: widget.size),
          buildBoardFace(face: faces.right, size: widget.size)];
      } else if (_ry < 3 * pi / 4) {
        children = [buildBoardFace(face: faces.back, size: widget.size),
          buildBoardFace(face: faces.right, size: widget.size)];
      } else if (_ry < pi) {
        children = [buildBoardFace(face: faces.right, size: widget.size),
          buildBoardFace(face: faces.back, size: widget.size)];
      } else if (_ry < 5 * pi / 4) {
        children = [buildBoardFace(face: faces.left, size: widget.size),
          buildBoardFace(face: faces.back, size: widget.size)];
      } else if (_ry < 3 * pi / 2) {
        children = [buildBoardFace(face: faces.back, size: widget.size),
          buildBoardFace(face: faces.left, size: widget.size)];
      } else if (_ry < 7 * pi / 4) {
        children = [buildBoardFace(face: faces.front, size: widget.size),
          buildBoardFace(face: faces.left, size: widget.size)];
      } else {
        children = [buildBoardFace(face: faces.left, size: widget.size),
          buildBoardFace(face: faces.front, size: widget.size)];
      }
    }else{
      if (_ry < pi / 4) {
        children = [buildBoardFace(face: faces.left, size: widget.size),
          buildBoardFace(face: faces.back, size: widget.size)];
      } else if (_ry < pi / 2) {
        children = [buildBoardFace(face: faces.back, size: widget.size),
          buildBoardFace(face: faces.left, size: widget.size)];
      } else if (_ry < 3 * pi / 4) {
        children = [buildBoardFace(face: faces.front, size: widget.size),
          buildBoardFace(face: faces.left, size: widget.size)];
      } else if (_ry < pi) {
        children = [buildBoardFace(face: faces.left, size: widget.size),
          buildBoardFace(face: faces.front, size: widget.size)];
      } else if (_ry < 5 * pi / 4) {
        children = [buildBoardFace(face: faces.right, size: widget.size),
          buildBoardFace(face: faces.front, size: widget.size)];
      } else if (_ry < 3 * pi / 2) {
        children = [buildBoardFace(face: faces.front, size: widget.size),
          buildBoardFace(face: faces.right, size: widget.size)];
      } else if (_ry < 7 * pi / 4) {
        children = [buildBoardFace(face: faces.back, size: widget.size),
          buildBoardFace(face: faces.right, size: widget.size)];
      } else {
        children = [buildBoardFace(face: faces.right, size: widget.size),
          buildBoardFace(face: faces.back, size: widget.size)];
      }
    }
    if (_rx  >= 0 && _rx <= pi) {
      // TODO: not perfect - does not consider perspective:
      // When `rotateX` is positive but very small, like 0.1, when taking
      // account of perspective, the "top" face should be drawn *behind* the
      // front face, not *in front* of it. But this works reasonably well for
      // larger values (like > 0.1) of `rotateX`.
      if (_rx >= 0 && _rx <= 0.1 || _rx > 3){
        children = [buildBoardFace(face: faces.top, size: widget.size),...children];
      }else{
        children = [...children, buildBoardFace(face: faces.top, size: widget.size)];
      }

    } else if(_rx >= pi && _rx <= pi*2) {
      children = [buildBoardFace(face: faces.bottom, size: widget.size), ...children];
      if (_rx <= pi + 0.1 || (_rx >= 6.18)){
        children = [buildBoardFace(face: faces.bottom, size: widget.size), ...children];
      }else{
        children = [...children, buildBoardFace(face: faces.bottom, size: widget.size)];
      }
    }
  }

  final reaper = Sprites.characterOf[characters.reaper1]!;
  final notReaper =  Sprites.characterOf[characters.virtualGuy]!;



  buildBoardFace({
    required faces face,
    required double size,
    ClassicGameController? customEngine}){


    late double rotateX;
    late double rotateY;
    late double trX;
    late double trY;
    late double trZ;
    switch (face){

      case faces.top:
        trX = 0.0;
        trY = -size/2;
        trZ = 0.0;
        rotateX = -pi / 2;
        rotateY = 0.0;
      case faces.bottom:
        trX = 0.0;
        trY = size/2;
        trZ = 0.0;
        rotateX = pi / 2;
        rotateY = 0.0;
      case faces.right:
        trX = size/2;
        trY = 0.0;
        trZ = 0.0;
        rotateX = 0.0;
        rotateY = -pi / 2;
      case faces.left:
        trX = -size/2;
        trY = 0.0;
        trZ = 0.0;
        rotateX = 0.0;
        rotateY = pi / 2;
      case faces.front:
        trX = 0.0;
        trY = 0.0;
        trZ = -size/2;
        rotateX = 0.0;
        rotateY = 0.0;
      case faces.back:
        trX = 0.0;
        trY = 0.0;
        trZ = size/2;
        rotateX = 0.0;
        rotateY = pi;
      default:
        break;
    }
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        final beam = sin((_rx) - pi);
        List<Widget> lines = [];
        // Draw box lines
        createGridLines(size, size, 3, 3, lines, Colors.lightBlueAccent.withOpacity(0.5), widget.animationController);
        final linearGrid = <int>[];
        if (customEngine != null) {
          for (var i in customEngine.grid){
            linearGrid.addAll(i);
          }
        }
        return Transform(
          transform: Matrix4.identity()
            ..translate(trX, trY, trZ)
            ..rotateX(rotateX)
            ..rotateY(rotateY),
          alignment: Alignment.center,
          child: (widget.removedFaces != null && widget.removedFaces!.contains(face)) ?
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.black,
                  Colors.deepPurple.shade700,
                  Colors.deepPurple.shade900,
                  Colors.deepPurple.shade700,
                  Colors.deepPurple.shade900,
                ],
                stops: [0.0, 0.0 + beam, 0.2 + beam, 0.4 + beam, 1.0],
              ),
            ),) :
          Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.black,
                  Colors.deepPurple.shade700,
                  Colors.deepPurple,
                  Colors.deepPurple.shade900,
                  Colors.black,
                ],
                stops: [0.0, 0.0 + beam, 0.2 + beam, 0.4 + beam, 1.0],
              ),
            ),
            child: Stack(
              children: lines..addAll([
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: reaper,
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              child: Icon(CupertinoIcons.xmark, color: Colors.blue,),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              child: Icon(CupertinoIcons.xmark, color: Colors.blue,),
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              child: Icon(CupertinoIcons.xmark, color: Colors.blue,),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              child: Icon(CupertinoIcons.xmark, color: Colors.blue,),
                            ),
                          ),
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: notReaper,
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              child: Icon(CupertinoIcons.xmark, color: Colors.blue,),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              child: Icon(CupertinoIcons.xmark, color: Colors.blue,),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              child: Icon(CupertinoIcons.xmark, color: Colors.blue,),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        );
      }
    );

  }
}
