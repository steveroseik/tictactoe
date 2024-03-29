import 'dart:math';

import 'package:animated_button/animated_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:neopop/widgets/shimmer/neopop_shimmer.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:simple_animated_button/elevated_layer_button.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Controllers/classicGameController.dart';
import 'package:tictactoe/UIUX/themesAndStyles.dart';

import '../Configurations/constants.dart';
import '../coinToss.dart';

class BackgroundScroller extends StatefulWidget {
  final double? height;
  const BackgroundScroller({super.key, this.height});

  @override
  State<BackgroundScroller> createState() => _BackgroundScrollerState();
}

class _BackgroundScrollerState extends State<BackgroundScroller>
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
    leftPattern = Image.asset('assets/patternXO.png',
        scale: 6, repeat: ImageRepeat.repeat, color: Colors.black);
    rightPattern = Image.asset('assets/patternXO.png',
        scale: 6, repeat: ImageRepeat.repeat, color: colorBlue);
    return Transform.scale(
      scale: 1.3,
      child: Transform.rotate(
        angle: pi / -12.0,
        child: SizedBox(
          height: widget.height ?? MediaQuery.of(context).size.height / 3,
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (Rect bounds) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.deepOrange.shade200, Colors.deepOrange],
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
                  top: (1 - _controller.value) * 300,
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

class _BackgroundAnimationState extends State<BackgroundAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Define two instances of your pattern image
  Widget leftPattern = Image.asset('assets/images/greenSpace1.png',
      scale: 0.5, repeat: ImageRepeat.repeat);

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
        scale: 100.h / 101, repeat: ImageRepeat.repeat);
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
                top: ((1 - _controller.value) * 100.h),
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
  LinePainter(this.start, this.end, this.axisWidth, this.maxWidth, this.color,
      this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    final newEnd = end.dx == maxWidth - 2
        ? Offset(end.dx - (end.dx * (1 - controller.value)), end.dy)
        : Offset(end.dx, end.dy - (end.dy * (1 - controller.value)));
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

void createGridLines(double width, double height, int rows, int columns,
    List<Widget> widgets, Color color, AnimationController controller,
    {double? thickness}) {
  double rowHeight = height / rows;
  double columnWidth = width / columns;

  // Draw horizontal lines
  for (int i = 1; i < rows; i++) {
    double y = (i * rowHeight);
    addLine(Offset(0, y), Offset(width - 2, y), width, widgets, controller,
        color, thickness);
  }

  // Draw vertical lines
  for (int i = 1; i < columns; i++) {
    double x = (i * columnWidth);
    addLine(Offset(x, 0), Offset(x, height - 2), height, widgets, controller,
        color, thickness);
  }

  controller.forward();
}

void addLine(Offset p1, Offset p2, double size, List<Widget> widgets,
    AnimationController controller, Color color, double? thickness) {
  widgets.add(
    CustomPaint(
      size: Size(size, size),
      painter:
          LinePainter(p1, p2, thickness ?? axisWidth, size, color, controller),
    ),
  );
}

class LoadingPage extends StatefulWidget {
  final bool circular;
  final bool? single;
  const LoadingPage({super.key, required this.circular, this.single});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
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

    widget.circular
        ? null
        : _controller.addListener(() {
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
          child: widget.circular
              ? ShaderMask(
                  blendMode: BlendMode.xor,
                  shaderCallback: (Rect bounds) => RadialGradient(
                    center: Alignment.center,
                    colors: [
                      colorBlue.withOpacity(0.3),
                      colorBlue.withOpacity(0.97),
                      colorBlue
                    ],
                  ).createShader(bounds),
                  child: Stack(
                    children: [
                      Center(
                        child: RotationTransition(
                          turns: Tween<double>(begin: 0, end: 1)
                              .animate(_controller),
                          child: Container(
                              width: widget.single ?? false ? null : 600,
                              child: leftPattern),
                        ),
                      ),
                    ],
                  ),
                )
              : ShaderMask(
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
                        top: (1 - _controller.value) * 600,
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

class LoadingWidget extends StatefulWidget {
  final bool circular;
  final bool? single;
  double scaleFactor = 1;
  late Color color;
  LoadingWidget(
      {super.key,
      required this.circular,
      this.single,
      double? scaleFactor,
      Color? color}) {
    this.scaleFactor = scaleFactor ?? this.scaleFactor;
    this.color = color ?? colorPurple;
  }

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Define two instances of your pattern image
  late Widget leftPattern;
  late Widget rightPattern;

  double value = 0;
  @override
  void initState() {
    super.initState();
    leftPattern = Image.asset('assets/patternXO.png',
        scale: widget.scaleFactor,
        repeat: ImageRepeat.repeat,
        color: colorLightYellow);
    rightPattern = Image.asset('assets/patternXO.png',
        scale: widget.scaleFactor,
        repeat: ImageRepeat.repeat,
        color: colorLightYellow);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    widget.circular
        ? null
        : _controller.addListener(() {
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
    return ClipOval(
      child: Center(
        child: SizedBox(
          child: widget.circular
              ? ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (Rect bounds) => RadialGradient(
                    center: Alignment.center,
                    colors: [
                      widget.color,
                      widget.color.withOpacity(0.97),
                      widget.color.withOpacity(0.0),
                    ],
                  ).createShader(bounds),
                  child: Stack(
                    children: [
                      Center(
                        child: RotationTransition(
                          turns: Tween<double>(begin: 0, end: 1)
                              .animate(_controller),
                          child: Container(
                              width: widget.single ?? false ? null : 600,
                              child: leftPattern),
                        ),
                      ),
                    ],
                  ),
                )
              : ShaderMask(
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
                        top: (1 - _controller.value) * 600,
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

class WinButton extends StatelessWidget {
  final bool disconnected;
  const WinButton({super.key, this.disconnected = false});

  @override
  Widget build(BuildContext context) {
    String text = '';
    if (disconnected) {
      text = 'Your opponent has disconnected';
    } else {
      text = 'You beat your opponent'; //return value if str is null
    }
    return MaterialButton(
      color: Colors.grey[300],
      minWidth: 300,
      onPressed: () => Dialogs.materialDialog(
          msg: text,
          title: "You Win!",
          color: Colors.deepPurple,
          context: context,
          titleStyle: TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          msgStyle: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w100),
          msgAlign: TextAlign.center,
          dialogWidth: kIsWeb ? 0.3 : null,
          onClose: (value) => print("returned value is '$value'"),
          actions: [
            AnimatedButton(
              child: Text(
                'Home', // add your text here
                style: TextStyle(
                  color: Colors.deepPurple,
                ),
              ),
              onPressed: () {},
              width: 120,
              color: Colors.white,
            ),
            AnimatedButton(
              child: Text(
                'Play', // add your text here
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {},
              width: 120,
              color: Colors.green,
            ),
          ]),
      child: Text("Win Button"),
    );
  }
}

class LoseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: Colors.grey[300],
      minWidth: 300,
      onPressed: () => Dialogs.materialDialog(
          msg: 'Tough Luck! Try Again?',
          title: "You Lose!",
          color: Colors.deepPurple,
          context: context,
          titleStyle: TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          msgStyle: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w100),
          msgAlign: TextAlign.center,
          dialogWidth: kIsWeb ? 0.3 : null,
          onClose: (value) => print("returned value is '$value'"),
          actions: [
            AnimatedButton(
              child: Text(
                'Home', // add your text here
                style: TextStyle(
                  color: Colors.deepPurple,
                ),
              ),
              onPressed: () {},
              width: 120,
              color: Colors.white,
            ),
            AnimatedButton(
              child: Text(
                'Play', // add your text here
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {},
              width: 120,
              color: Colors.green,
            ),
          ]),
      child: Text("Lose Button"),
    );
  }
}

class DrawButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: Colors.grey[300],
      minWidth: 300,
      onPressed: () => Dialogs.materialDialog(
          msg: 'Close Match! Try Again?',
          title: "Draw!",
          color: Colors.deepPurple,
          context: context,
          titleStyle: TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          msgStyle: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w100),
          msgAlign: TextAlign.center,
          dialogWidth: kIsWeb ? 0.3 : null,
          onClose: (value) => print("returned value is '$value'"),
          actions: [
            AnimatedButton(
              child: Text(
                'Home', // add your text here
                style: TextStyle(
                  color: Colors.deepPurple,
                ),
              ),
              onPressed: () {},
              width: 120,
              color: Colors.white,
            ),
            AnimatedButton(
              child: Text(
                'Play', // add your text here
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {},
              width: 120,
              color: Colors.green,
            ),
          ]),
      child: Text("Draw Button"),
    );
  }
}

class GameButton extends StatelessWidget {
  final BoxDecoration? baseDecoration;
  final BoxDecoration? topDecoration;
  late BorderRadius borderRadius;
  late Color color;
  final bool enableShimmer;
  late Color shimmerColor;
  final Gradient? gradient;
  final Widget? child;
  Function()? onPressed;
  final Duration? animationDuration;
  final Duration? shimmerAnimationDuration;
  final Duration? shimmerDelayDuration;
  final double? height;
  final double? width;
  final double? aspectRatio;

  GameButton(
      {super.key,
      this.baseDecoration,
      this.topDecoration,
      BorderRadius? borderRadius,
      Color? color,
      Color? shimmerColor,
      this.enableShimmer = true,
      this.gradient,
      this.child,
      this.onPressed,
      this.animationDuration,
      this.shimmerDelayDuration,
      this.shimmerAnimationDuration,
      this.height,
      this.width,
      this.aspectRatio}) {
    this.borderRadius = borderRadius ?? BorderRadius.circular(0);
    this.color = color ?? Colors.black;
    this.shimmerColor = shimmerColor ?? colorYellow.withOpacity(0.8);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedLayerButton(
      baseDecoration:
          baseDecoration?.copyWith(borderRadius: borderRadius, color: color) ??
              BoxDecoration(borderRadius: borderRadius, color: color),
      topDecoration:
          topDecoration?.copyWith(borderRadius: borderRadius, color: color) ??
              BoxDecoration(borderRadius: borderRadius, color: color),
      buttonHeight: height,
      buttonWidth: width,
      aspectRatio: aspectRatio,
      animationDuration: animationDuration ?? const Duration(milliseconds: 100),
      animationCurve: Curves.easeIn,
      onClick: onPressed,
      topLayerChild: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: child ?? Container()),
          if (enableShimmer)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: borderRadius,
                child: NeoPopShimmer(
                    shimmerColor: shimmerColor,
                    duration: shimmerAnimationDuration ??
                        const Duration(milliseconds: 1500),
                    delay: shimmerDelayDuration ??
                        const Duration(milliseconds: 2000),
                    child: Container()),
              ),
            ),
        ],
      ),
    );
  }
}

class GameButton2 extends StatelessWidget {
  final BoxDecoration? baseDecoration;
  final BoxDecoration? topDecoration;
  late BorderRadius borderRadius;
  late Color color;
  final Gradient? gradient;
  final Widget? child;
  Function()? onPressed;
  final Duration? animationDuration;

  final double? height;
  final double? width;
  final double? aspectRatio;

  GameButton2(
      {super.key,
      this.baseDecoration,
      this.topDecoration,
      BorderRadius? borderRadius,
      Color? color,
      this.gradient,
      this.child,
      this.onPressed,
      this.animationDuration,
      this.height,
      this.width,
      this.aspectRatio}) {
    this.borderRadius = borderRadius ?? BorderRadius.circular(10);
    this.color = color ?? Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedLayerButton(
      baseDecoration: baseDecoration ??
          BoxDecoration(borderRadius: borderRadius, color: color),
      topDecoration: topDecoration ??
          BoxDecoration(borderRadius: borderRadius, color: color),
      buttonHeight: height,
      buttonWidth: width,
      aspectRatio: aspectRatio,
      animationDuration: animationDuration ?? const Duration(milliseconds: 100),
      animationCurve: Curves.easeIn,
      onClick: onPressed,
      topLayerChild: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          alignment: Alignment.center,
          children: [
            child ?? Container(),
          ],
        ),
      ),
    );
  }
}


final loadingCircularBigScale = LoadingWidget(circular: true, scaleFactor: 12);
Widget viewMiddleWidget({
  required ClassicGameController? controller,
  required GameState gameState,
  required bool speedMatch,
  required int gameStartsIn,
  bool inTournament = false,
  required Function() onCoinTossEnd,
  required Function() onWinButtonClick,
  required Function() tournamentRoundEnded,
}){
  switch (gameState){
    case GameState.starting:
    case GameState.waiting:
    case GameState.connecting:
      if (gameState == GameState.starting && speedMatch){
        return StartingSpeedMatch(gameStartsIn, speedMatch, controller);
      }else{
        return Column(
          key: UniqueKey(),
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            gameState == GameState.connecting ? const Text("Connecting...")
                : gameState == GameState.starting ? Text("Starting in $gameStartsIn..")
                : const Text("Searching for an opponent.."),
            SizedBox(height: 30),
            SizedBox(
                width: 50.w,
                child: loadingCircularBigScale)
          ],
        );
      }
    case GameState.coinToss:
      return CoinToss(onEnd: onCoinTossEnd);

    case GameState.ended:
      if (controller?.winner == GameWinner.draw) return StartingSpeedMatch(gameStartsIn, speedMatch, controller);
      tournamentRoundEnded;
      return gameEndDialog(controller, inTournament);

    default: return Text('1Should not appear');
  }

}
Widget StartingSpeedMatch(int gameStartsIn, bool speedMatch, ClassicGameController? controller){
  return Container(
    key: Key('$speedMatch${controller?.roomInfo.id}'),
    width: 80.w,
    padding: EdgeInsets.all(6.w),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
          colors: [
            Colors.purple,
            colorPurple
          ]
      ),
      boxShadow: [
        BoxShadow(
            color: colorDarkBlue.withOpacity(0.5),
            offset: Offset(3, 3),
            spreadRadius: 1,
            blurRadius: 3)
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Text(
          "The Match Ended With Draw!",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          "Starting Speed Match!",
          style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.w700
          ),
        ),
        if (gameStartsIn > 0) Text(
          "$gameStartsIn seconds",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
        gameStartsIn == 0 ?
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: LinearProgressIndicator(
            color: Colors.deepOrange,
            backgroundColor: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
        ) :
        LinearPercentIndicator(
          animationDuration: 1000,
          animation: true,
          animateFromLastPercent: true,
          percent: gameStartsIn/3,
          backgroundColor: colorPurple,
          progressColor: colorDeepOrange,
          barRadius: Radius.circular(20),
        )
      ],
    ),
  );
}

Widget gameEndDialog(ClassicGameController? gameController, bool inTournament){
  return Container(
    key: UniqueKey(),
    width: 80.w,
    padding: EdgeInsets.all(6.w),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
          colors: [
            Colors.purple,
            colorPurple
          ]
      ),
      boxShadow: [
        BoxShadow(
            color: colorDarkBlue.withOpacity(0.5),
            offset: Offset(3, 3),
            spreadRadius: 1,
            blurRadius: 3)
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          inTournament ? "Round Ended" : "Game Ended",
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          gameController?.iWon ? "You Won !" : "You Lost !",
          style: const TextStyle(
              color: Colors.white,
              fontSize: 35.0,
              fontWeight: FontWeight.w700
          ),
        ),
        SizedBox(height: 3.h),
        GameButton(
          height: 6.h,
          baseDecoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gameController?.iWon ?
              [colorDeepOrange, colorDeepOrange] :
              [Colors.red, colorDeepOrange],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          topDecoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors:  !gameController?.iWon ?
              [colorDeepOrange, colorDeepOrange] :
              [colorLightYellow, colorDeepOrange],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          onPressed: (){},
          aspectRatio: 3/1,
          enableShimmer: false,
          borderRadius: BorderRadius.circular(10),
          child: Center(
              child: Text(gameController?.iWon ? (inTournament ? "Next Round" : 'Claim Reward') : 'Back To Home',
                style: TextStyle(color: Colors.black),)),
        )
      ],
    ),
  );
}
