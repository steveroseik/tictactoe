import 'dart:async';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Controllers/gameEngine.dart';
import 'package:tictactoe/UIUX/themesAndStyles.dart';
import 'UIUX/customWidgets.dart';
import 'gamePage.dart';



class CubeGame extends StatefulWidget {
  const CubeGame({super.key});

  @override
  State<CubeGame> createState() => _CubeGameState();
}

class _CubeGameState extends State<CubeGame> with TickerProviderStateMixin{

  late AnimationController animationController;
  late Animation animation;
  late AnimationController focusController;
  late Animation focusAnimation;

  List<Widget> nineGames = [];
  List<GameEngine> nineEngines = [];
  double gridSize = 90.w;

  List<int> focusedGrid = [];
  int selectedIndex = -1;
  Alignment startFrom = Alignment.topLeft;
  bool isO = false;

  Alignment setStartPoint(int index){
    late Alignment ret;
    switch(index){
      case 0 : ret = Alignment.topLeft;
        break;
      case 1 : ret = Alignment.topCenter;
        break;
      case 2 : ret = Alignment.topRight;
        break;
      case 3 : ret = Alignment.centerLeft;
        break;
      case 4 : ret = Alignment.center;
        break;
      case 5 : ret = Alignment.centerRight;
        break;
      case 6 : ret = Alignment.bottomLeft;
        break;
      case 7 : ret = Alignment.bottomCenter;
        break;
      case 8 : ret = Alignment.bottomRight;
        break;
    }
    return ret;
  }

  @override
  void initState() {
    animationController = AnimationController(duration: const Duration(milliseconds: 3000), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController);

    focusController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    focusAnimation = CurvedAnimation(parent: focusController, curve: Curves.easeInOut);

    nineEngines = List<GameEngine>.generate(9, (index) => GameEngine());
    nineGames = List<Widget>.generate(9, (index) => NineGrid(size: gridSize/3, engine: nineEngines[index]));
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    focusController.dispose();
    for (var e in nineEngines){
      e.kill();
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        setState(() {
         selectedIndex = -1;
        });
        if (focusController.isCompleted){
          focusController.reverse();
        }
      },
      child: Scaffold(
        body: AnimatedBuilder(
          animation: Listenable.merge([animationController, focusController]),
          builder: (context, child) {
            List<Widget> lines = [];
            createGridLines(
                gridSize, gridSize, 3, 3, lines,
                Colors.lightBlueAccent, animationController,
                thickness: 3);
            return Stack(
              children: [
                Center(
                  child: SizedBox(
                    height: gridSize,
                    width: gridSize,
                    child: Stack(
                      children: lines..addAll([
                        GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: 9,
                            itemBuilder: (context, index){
                              final tag = 'gameOf$index';
                              return Transform(
                                transform: Matrix4.identity()
                                ..scale(selectedIndex == index ? 1 + (focusController.value/2) : 1.0),
                                alignment: setStartPoint(index),
                                child: Opacity(
                                  opacity: selectedIndex == index ? 1 - focusController.value : 1,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                      onTap: () async{
                                        focusedGrid.clear();
                                        for (var i in nineEngines[index].grid){
                                          focusedGrid.addAll(i);
                                        }
                                        setState(() {
                                          selectedIndex = index;
                                          startFrom = setStartPoint(index);
                                        });
                                        focusController.forward();
                                      },
                                      child: IgnorePointer(
                                          ignoring: true,
                                          child: nineGames[index])),
                                ),
                              );
                            }),
                        Transform(
                          transform: Matrix4.identity()
                          ..scale(focusController.value),
                          alignment: startFrom,
                          child: Opacity(
                            opacity: focusController.value > 0.5 ? 1 : focusController.value*2,
                            child: Center(
                              child: Transform(
                                transform: Matrix4.identity()
                                ..scale(1.0),
                                child: Builder(
                                  builder: (context) {
                                    List<Widget> lines = [];
                                    createGridLines(
                                        gridSize, gridSize, 3, 3, lines,
                                        Colors.lightBlueAccent, animationController,
                                        thickness: 3);
                                    return Container(
                                      color: Colors.white,
                                      height: 90.w,
                                      width: 90.w,
                                      child: Stack(
                                        children: [
                                          ...lines,
                                          GridView.builder(
                                              gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                                              itemCount: 9,
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index){
                                                return GestureDetector(
                                                  behavior: HitTestBehavior.opaque,
                                                  onTap: () async{
                                                   if (selectedIndex != -1){
                                                     nineEngines[selectedIndex]
                                                         .setManualMove((index~/3, index%3), isO: isO);
                                                     isO = !isO;
                                                     setState(() {
                                                       focusedGrid[index] = !isO ? 0 : 1;
                                                       selectedIndex = -1;
                                                     });
                                                     await Future.delayed(const Duration(milliseconds: 400));
                                                     await focusController.reverse();
                                                   }else{
                                                     print('??');
                                                   }
                                                  },
                                                  child: focusedGrid.isNotEmpty ? Container(
                                                    margin: const EdgeInsets.all(10),
                                                    child: focusedGrid[index] == 0 ? Icon(CupertinoIcons.circle, color: Colors.black,) :
                                                    focusedGrid[index] == 1 ? Icon(CupertinoIcons.xmark, color: Colors.black,) : Container(),
                                                  ) : Container(),
                                                );
                                              }),
                                        ],
                                      ),
                                    );
                                  }
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    )
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: (){
                        setState(() {
                          for (var engine in nineEngines){
                            engine.resetGame();
                          }
                        });
                      },
                      child: const Text('RESET'),
                    ),
                  ),
                )
              ],
            );
          }
        ),
      ),
    );
  }

  Future<int> showSeperateGrid(int index, List<List<int>> grid) async{
    int ret = -1;
    final linearGrid = <int>[];
    for (var i in grid) {
      linearGrid.addAll(i);
    }
    await showDialog(context: context,
        builder: (context){
          return Center(
            child: SizedBox(
              height: 90.w,
              width: 90.w,
              child: GridView.builder(
                  gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                  itemCount: 9,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    return GestureDetector(
                      onTap: () async{
                        linearGrid[index] = isO ? 0 : 1;
                        setState(() {});
                        await Future.delayed(const Duration(milliseconds: 400));
                        Navigator.of(context).pop(index);
                      },
                      child: Container(
                        margin: EdgeInsets.all(10),
                        color: Colors.blue,
                        child: linearGrid[index] == 0 ? Icon(CupertinoIcons.circle) :
                        linearGrid[index] == 1 ? Icon(CupertinoIcons.xmark) : Container(),
                      ),
                    );
                  }),
            ),
          );
        }).then((value){
          ret = value?? -1;
    });
    return ret;
  }
}


class NinesBoardPage extends StatelessWidget {
  const NinesBoardPage({super.key, required this.child, required this.tag});

  final Widget child;
  final String tag;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(child: Hero(tag: tag, child: child)));
  }
}

class NineGrid extends StatefulWidget {
  const NineGrid({super.key, required this.size, required this.engine});

  final double size;
  final GameEngine engine;

  @override
  State<NineGrid> createState() => _NineGridState();
}

class _NineGridState extends State<NineGrid> with TickerProviderStateMixin {



  late GameEngine gameEngine;
  late AnimationController animationController;
  late Animation animation;



  @override
  void initState() {
    animationController = AnimationController(duration: const Duration(milliseconds: 3000), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController);

    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    // widget.engine.kill();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    gameEngine = widget.engine;
    return ChangeNotifierProvider(
      create: (context) => gameEngine,
      child: Consumer<GameEngine>(
        builder: (context, engine, child) {
          return AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              List<Widget> lines = [];
              // Draw box lines
              createGridLines(
                  widget.size, widget.size, 3, 3, lines, Colors.lightBlueAccent.withOpacity(0.5), animationController);
              final linearGrid = <int>[];
              for (var i in gameEngine.grid) {
                linearGrid.addAll(i);
              }
              return SizedBox(
                height: widget.size,
                width: widget.size,
                child: Stack(
                  children: [
                    ...lines,
                    GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: 9,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: (){
                              int row = (index ~/ 3);
                              int column = index % 3;
                              gameEngine.setManualMove((row, column), isO: false);
                              setState(() {});
                            },
                            child: Container(
                              margin: EdgeInsets.all(3),
                              child: linearGrid[index] == 0 ? Icon(CupertinoIcons.circle, color: Colors.black,) :
                              linearGrid[index] == 1 ? Icon(CupertinoIcons.xmark, color: Colors.black,) : Container(),
                            ),
                          );
                        }),
                  ],
                ),
              );
            }
          );
        }
      ),
    );
  }
}


