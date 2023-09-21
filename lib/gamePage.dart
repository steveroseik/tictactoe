import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Controllers/gameEngine.dart';

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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              width: 80.w,
              child: AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    lines.clear();
                    init(constraints.maxWidth, constraints.maxWidth, lines, _animationController);
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
          ),
          ElevatedButton(onPressed: (){
            setState(() {
              engine.resetGame();
            });
          }, child: Text('restart')),
          ElevatedButton(onPressed: (){
            setState(() {
              FirebaseAuth.instance.signOut();
              // setState(() {
              //   // engine.winningPath = engine.winningPath.isNotEmpty ? [] : [3,4,5];
              // });
              // if (_animationController.isCompleted){
              //   _animationController.reverse();
              // }else{
              //   _animationController.forward();
              // }
            });
          }, child: Text('move'))
        ],
      ),
    );
  }
}
