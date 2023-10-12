import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/UIUX/themesAndStyles.dart';


class BackgroundScroller extends StatefulWidget {
  final double? height;
  const BackgroundScroller({super.key, this.height});

  @override
  State<BackgroundScroller> createState() => _BackgroundScrollerState();
}

class _BackgroundScrollerState extends State<BackgroundScroller> with SingleTickerProviderStateMixin{

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
    return Transform.scale(
      scale: 1.3,
      child: Transform.rotate(
        angle: pi / -12.0,
        child: SizedBox(
          height: widget.height?? MediaQuery.of(context).size.height / 3,
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
    );
  }
}

class BackgroundAnimation extends StatefulWidget {
  const BackgroundAnimation({super.key});

  @override
  State<BackgroundAnimation> createState() => _BackgroundAnimationState();
}

class _BackgroundAnimationState extends State<BackgroundAnimation> with SingleTickerProviderStateMixin{

  late AnimationController _controller;

  // Define two instances of your pattern image
  Widget leftPattern = Image.asset('assets/images/greenSpace1.png',
      scale: 0.5,
      repeat: ImageRepeat.repeat);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _controller.addListener(() {
      setState(() {
        if (_controller.value == 1) {
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
    leftPattern = Image.asset('assets/images/greenSpace1.png',
        scale: 100.h / 101,
        repeat: ImageRepeat.repeat);
    return Transform.scale(
      scale: 1.5,
      child: Transform.rotate(
        angle: pi / -12.0,
        child: SizedBox(
          height: 100.h,
          width: 100.w,
          child: Stack(
            children: [
              // Left pattern initially on the left side of the screen
              Positioned(
                left: 0,
                top: ((-_controller.value) * 100.h),
                child: Container(
                  height: 100.h,
                  width: 100.w,
                  child: leftPattern,
                ),
              ),
              // Right pattern initially just to the right of the left pattern
              Positioned(
                left: 0,
                top:
                ((1 - _controller.value) * 100.h),
                child: Container(
                  height: 100.h,
                  width: 100.w,
                  child: leftPattern,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class LinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final double axisWidth;
  final double maxWidth;
  final Color color;
  final AnimationController controller;
  LinePainter(this.start, this.end, this.axisWidth, this.maxWidth, this.color, this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    final newEnd = end.dx == maxWidth-2 ? Offset(end.dx - (end.dx * (1 - controller.value)), end.dy) :
        Offset(end.dx, end.dy - (end.dy * (1 - controller.value)));
    createPath(canvas, start, newEnd);
  }

  void createPath(final Canvas canvas, final Offset start, final Offset end) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = axisWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}



class WinningLinePainter extends CustomPainter {
  final List<int> winningPath;
  double _progress;

  WinningLinePainter(this.winningPath, this._progress);

  // Animates the line
  void animate() {
    _progress += 0.01;
    if (_progress > 1.0) {
      _progress = 1.0;
    }
  }

  // Undraws the line
  void erase() {
    _progress -= 0.01;
    if (_progress < 0.0) {
      _progress = 0.0;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (winningPath.length != 3) {
      return; // Invalid winning path
    }

    final Paint paint = Paint()
      ..color = Colors.red // Color of the line
      ..strokeWidth = 5.0; // Width of the line

    // Calculate the positions of the winning line based on the winning cells
    final startCellX = winningPath[0] % 3;
    final startCellY = winningPath[0] ~/ 3;
    final endCellX = winningPath[2] % 3;
    final endCellY = winningPath[2] ~/ 3;

    final startPoint = Offset(
      (startCellX + 0.5) * size.width / 3,
      (startCellY + 0.8) * size.width / 3,
    );

    final endPoint = Offset(
      ((endCellX + 0.5) * size.width / 3 * _progress) - _progress,
      ((endCellY + 0.8) * size.width / 3 * _progress) - _progress,
    );

    // Draw the partial line
    canvas.drawLine(startPoint, endPoint, paint);
  }

  @override
  bool shouldRepaint(WinningLinePainter oldDelegate) => true;

}


double axisWidth = 1;

void createGridLines(
    double width, double height,
    int rows, int columns,
    List<Widget> widgets, Color color,
    AnimationController controller,
    {double? thickness}) {
  double rowHeight = height / rows;
  double columnWidth = width / columns;

  // Draw horizontal lines
  for (int i = 1; i < rows; i++) {
    double y = (i * rowHeight);
    addLine(Offset(0, y), Offset(width-2, y), width, widgets, controller, color, thickness);
  }

  // Draw vertical lines
  for (int i = 1; i < columns; i++) {
    double x = (i * columnWidth);
    addLine(Offset(x, 0), Offset(x, height-2), height, widgets, controller, color, thickness);
  }

  controller.forward();
}

void addLine(Offset p1, Offset p2, double size, List<Widget> widgets, AnimationController controller, Color color, double? thickness) {
  widgets.add(
    CustomPaint(
      size: Size(size, size),
      painter: LinePainter(p1, p2, thickness?? axisWidth, size, color, controller),
    ),
  );
}



class LoadingWidget extends StatefulWidget {
  final bool circular;
  final bool? single;
  const LoadingWidget({super.key, required this.circular, this.single});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> with SingleTickerProviderStateMixin{

  late AnimationController _controller;

  // Define two instances of your pattern image
  Widget leftPattern = Image.asset('assets/patternXO.png',
      scale: 6, repeat: ImageRepeat.repeat, color: colorLightYellow);
  Widget rightPattern = Image.asset('assets/patternXO.png',
      scale: 6, repeat: ImageRepeat.repeat, color: colorLightYellow);


  double value = 0;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    widget.circular ? null : _controller.addListener(() {
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
      body: Center(
        child: SizedBox(
          child: widget.circular ? ShaderMask(
            blendMode: BlendMode.xor,
            shaderCallback: (Rect bounds) => RadialGradient(
              center: Alignment.center,
              colors: [colorBlue.withOpacity(0.3), colorBlue.withOpacity(0.97), colorBlue],
            ).createShader(bounds),
            child: Stack(
              children: [
                Center(
                  child: RotationTransition(
                    turns: Tween<double>(begin: 0, end: 1).animate(_controller),
                    child: Container(
                      width: widget.single?? false ? null : 600,
                      child: leftPattern
                    ),
                  ),
                ),
              ],
            ),
          ) : ShaderMask(
            blendMode: BlendMode.xor,
            shaderCallback: (Rect bounds) => RadialGradient(
              center: Alignment.center,
              colors: [colorBlue.withOpacity(0.5), colorBlue],
            ).createShader(bounds),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: -_controller.value * 600,
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
                  (1 - _controller.value) * 600,
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
    );
  }
}

class ScaleRoute extends PageRouteBuilder {
  final Widget page;
  ScaleRoute({required this.page})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
          ),
          child: child,
        ),
  );
}


