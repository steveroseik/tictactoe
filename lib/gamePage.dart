import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic_button/neumorphic_button.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Controllers/dataEngine.dart';
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

  int xWins = 0;
  int oWins = 0;
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
      body: Consumer<DataEngine>(
        builder: (BuildContext context, DataEngine dataEngine, Widget? child) {
          return ChangeNotifierProvider<GameEngine>(
            create: (context) => engine,
            child: Consumer<GameEngine>(
              builder: (BuildContext context, GameEngine gameEngine, Widget? child) {
                return Stack(
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
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                                    decoration: BoxDecoration(
                                        border: engine.xTurn ? Border.all(
                                            color: Colors.blue
                                        ) : null,
                                        borderRadius: BorderRadius.circular(15.sp),
                                        gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: engine.xTurn ? [Colors.blue.shade700, colorBlue] : [colorBlue, colorMediumBlue]
                                        )
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.person, color: colorLightYellow, size: 8.w),
                                        SizedBox(width: 3.w),
                                        Column(
                                          children: [
                                            Text('You', style: TextStyle(
                                              color: colorLightYellow, fontWeight: FontWeight.w500,),),
                                            Icon(CupertinoIcons.xmark, color: colorLightYellow,)
                                          ],
                                        ),
                                        Spacer(),
                                        Text('$xWins', style: TextStyle(
                                            color: colorLightYellow,
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w500),),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 7.w),
                                Expanded(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                                    decoration: BoxDecoration(
                                        border: !engine.xTurn ? Border.all(
                                            color: Colors.blue
                                        ) : null,
                                        borderRadius: BorderRadius.circular(15.sp),
                                        gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: !engine.xTurn ? [Colors.blue.shade700, colorBlue] : [colorBlue, colorMediumBlue]
                                        )
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text('$oWins', style: TextStyle(color: colorLightYellow,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18.sp)),
                                        Spacer(),
                                        SizedBox(width: 1.w),
                                        Column(
                                          children: [
                                            Text('Ai', style: TextStyle(color: colorLightYellow, fontWeight: FontWeight.w500),),
                                            Icon(CupertinoIcons.circle, color: colorLightYellow)
                                          ],
                                        ),
                                        SizedBox(width: 3.w),
                                        Image.asset('assets/characters/all-01.png', width: 9.w),
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
                                    createGridLines(constraints.maxWidth, constraints.maxWidth, 3, 3,
                                        lines, Colors.lightBlueAccent.withOpacity(0.5), _animationController);
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
                                                      gameWinner? winner;
                                                      if (linearGrid[index] == -1){
                                                        winner = engine.setManualMove(isO: false, ((index ~/ 3),(index % 3)));
                                                        setState(() {});
                                                        await Future.delayed(const Duration(milliseconds: 1000));
                                                        winner = engine.setAiMove(isO: true);
                                                      }
                                                      if (winner != null){
                                                        if (winner == gameWinner.x) xWins ++;
                                                        if (winner == gameWinner.o) oWins ++;
                                                      }
                                                      setState(() {});

                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.all(5),
                                                      child: linearGrid[index] == -1 ? Container() :
                                                      Icon(linearGrid[index] == 0 ? CupertinoIcons.circle :  CupertinoIcons.xmark,
                                                          color: Colors.blue, size: 12.w),
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
                          SizedBox(height: 10.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 15.w,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: IconButton(onPressed: (){
                                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                                    },
                                        style: IconButton.styleFrom(
                                            backgroundColor: colorBlue.withOpacity(0.5)
                                        ),
                                        icon: Icon(CupertinoIcons.house_alt_fill, color: Colors.blue,)),
                                  ),
                                ),
                                SizedBox(
                                  width: 15.w,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: IconButton(onPressed: (){
                                      engine.resetGame();
                                    },
                                        style: IconButton.styleFrom(
                                            backgroundColor: colorBlue.withOpacity(0.5)
                                        ),
                                        icon: Icon(Icons.refresh_rounded, color: Colors.blue,)),
                                  ),
                                ),
                                SizedBox(
                                  width: 15.w,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: IconButton(onPressed: (){
                                      dataEngine.signOut();
                                    },
                                        style: IconButton.styleFrom(
                                            backgroundColor: colorBlue.withOpacity(0.5)
                                        ),
                                        icon: Icon(CupertinoIcons.gear_alt_fill, color: Colors.blue,)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
