import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic_button/neumorphic_button.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Controllers/gameEngine.dart';
import 'package:tictactoe/UIUX/themesAndStyles.dart';

import 'UIUX/customWidgets.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {

  final GameEngine engine = GameEngine();

  late AnimationController _animationController;

  late Animation _animation;

  List<Widget> lines = [];

  double _progress = 0;
  @override void initState() {
    _animationController = AnimationController(duration: Duration(milliseconds: 3000), vsync: this);

    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {
        setState(() {
          _progress = _animation.value;
        });
      });
    
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBlue,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colorBlue, colorBlue, Colors.blue]
              )
            ),
          ),
          BackgroundScroller(height: 25.h),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 24.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.lightBlueAccent
                            ),
                            borderRadius: BorderRadius.circular(15.sp),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [colorBlue, colorMediumBlue]
                            )
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: Icon(Icons.person),
                              ),
                              SizedBox(width: 1.w),
                              Column(
                                children: [
                                  Text('You', style: TextStyle(color: colorLightYellow, fontWeight: FontWeight.w500),),
                                  Icon(CupertinoIcons.circle)
                                ],
                              ),
                              Spacer(),
                              Text('0', style: TextStyle(color: colorLightYellow, fontWeight: FontWeight.w500),),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.sp),
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [colorBlue, colorMediumBlue]
                              )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('0', style: TextStyle(color: colorLightYellow, fontWeight: FontWeight.w500),),
                              Spacer(),
                              SizedBox(width: 1.w),
                              Column(
                                children: [
                                  Text('Ai', style: TextStyle(color: colorLightYellow, fontWeight: FontWeight.w500),),
                                  Icon(CupertinoIcons.xmark)
                                ],
                              ),
                              SizedBox(width: 1.w),
                              CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: Icon(Icons.person),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 5.h),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.sp),
                  ),
                  width: 80.w,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        lines.clear();
                        //Draw box lines
                        init(constraints.maxWidth, constraints.maxWidth, lines, Colors.lightBlueAccent.withOpacity(0.5), _animationController);
                        final linearGrid = <int>[];
                        for (var i in engine.grid){
                          linearGrid.addAll(i);
                        }
                        return Stack(
                          children: lines..addAll([
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                    ),
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: linearGrid.length,
                                    itemBuilder: (context, index){
                                      return InkWell(
                                        onTap: () async{
                                          if (linearGrid[index] == -1){
                                            engine.setManualMove(isO: false, ((index ~/ 3),(index % 3)));
                                            setState(() {});
                                            await Future.delayed(const Duration(milliseconds: 500));
                                            engine.setAiMove(isO: true);
                                            setState(() {});
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          child: linearGrid[index] == -1 ? Container() :
                                          Icon(linearGrid[index] == 0 ? CupertinoIcons.circle :  CupertinoIcons.xmark),
                                        ),
                                      );
                                    }),
                              ],
                            ),

                            IgnorePointer(
                              child: AnimatedBuilder(
                                animation: _animationController, // Your animation controller
                                builder: (BuildContext context, Widget? child) {
                                  return CustomPaint(
                                    size: Size(90.w, 50.h),
                                    painter: WinningLinePainter(engine.winningPath, _animation.value),
                                  );
                                },
                              ),
                            )
                          ]),
                        );
                      }
                    ),
                  ),
                ),
                Spacer(),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue.shade600,
                          child: Icon(CupertinoIcons.house_alt_fill, color: colorBlue,),)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
