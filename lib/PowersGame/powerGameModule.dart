import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/Controllers/powersGameController.dart';
import 'package:tictactoe/PowersGame/cellBarrier.dart';
import 'package:tictactoe/PowersGame/core.dart';
import 'package:tictactoe/spritesConfigurations.dart';

import '../Controllers/classicGameController.dart';
import '../UIUX/customWidgets.dart';

class SpellNotifier extends ChangeNotifier{
  List<int> spells = [];
  int length = 0;

  Power power = CellBarrier(playerState: -1);


  SpellNotifier({required this.length}){
    spells = List<int>.generate(length, (index) => -1);
  }

  int cell(int i) => spells[i];

  setCell(int i, {required int value}){
    spells[i] = value;
    notifyListeners();
  }

  reset(){
    for (int i = 0; i< length; i++){
      spells[i] = -1;
    }
    notifyListeners();
  }
}

class PowersGameModule extends StatefulWidget {
  final PowersGameController gameController;
  final Socket socket;
  const PowersGameModule({super.key, required this.gameController, required this.socket});

  @override
  State<PowersGameModule> createState() => _PowersGameModuleState();
}

class _PowersGameModuleState extends State<PowersGameModule> with TickerProviderStateMixin{

  double scale = 1.5;
  double _x = 0.0;
  double _y = 0.0;
  Offset prev = Offset.zero;
  double _baseScaleFactor = 0.0;

  late AnimationController animationController;
  late Animation animation;




  int rows = 7;
  int columns = 7;

  bool isO = false;
  List<int> cells = [];
  List<int> spells = [];
  List<Widget> animatedSprites = [];
  bool cellDefender = false;

  Widget enemy = Sprites.characterOf[characters.reaper1]!;
  Widget myself = Sprites.characterOf[characters.maskDude]!;

  ValueNotifier<characters> en = ValueNotifier(characters.reaper1);

  late SpellNotifier spellNotifier;
  late PowersGameController gameController;

  @override
  void initState() {
    animationController = AnimationController(duration: Duration(milliseconds: 3000), vsync: this);
    gameController = widget.gameController;
    animation = Tween(begin: 0.0, end: 1.0).animate(animationController);
    cells = List<int>.generate(rows*columns, (index) => -1);
    spells = List<int>.generate(rows*columns, (index) => -1);
    spellNotifier = SpellNotifier(length: rows*columns);

    for (int i=0; i < rows*columns; i++){
      animatedSprites.add(AnimatedSpriteWidget(index: i));
    }

    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => spellNotifier),
        ChangeNotifierProvider(create: (context) => gameController),
      ],
      builder: (context, child) {
        return GestureDetector(
          onScaleUpdate: (scaleDet){
            setState(() {
              scale = _baseScaleFactor * scaleDet.scale;
              if (scale < 1.2){
                scale = 1.2;
              }
              if (scale > 2){
                scale = 2;
              }
              final trueHeight = (100.h *scale)/4;
              final trueWidth = (100.w *scale)/4;
              _x += scaleDet.focalPoint.dx - prev.dx;
              _y += scaleDet.focalPoint.dy - prev.dy;
              if (_x >= trueWidth || _x <= -trueWidth){
                _x = _x.isNegative ? -trueWidth : trueWidth;
              }
              if (_y >= trueHeight || _y <= -trueHeight){
                _y = _y.isNegative ? -trueHeight : trueHeight;
              }
              prev = scaleDet.focalPoint;
            });
          },
          onScaleStart: (scaleDet){
            _baseScaleFactor = scale;
            prev = scaleDet.focalPoint;
          },
          child: Scaffold(
            body: Stack(
              children: [
                Transform(
                    transform: Matrix4.identity()
                      ..translate(_x/3, _y/3, 0.0)
                      ..scale(scale),
                    child: const BackgroundAnimation()),
                Positioned(
                  top: 10.h,
                  left: 5.w,
                  child: SizedBox(
                    width: 90.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 6.h,
                              padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 3.w),
                              decoration: BoxDecoration(
                                  border: !isO ? Border.all(color: Colors.deepOrange.shade100, width: 0.5.w): null,
                                  borderRadius: BorderRadius.circular(25.sp),
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: !isO ?
                                      [Colors.deepOrange, Colors.deepOrange.shade900] : [Colors.deepOrange.shade900, Colors.deepOrange.shade900]
                                  )
                              ),
                              child: Row(
                                children: [
                                  AspectRatio(aspectRatio: 1, child: myself),
                                  Spacer(),
                                  Text('YOU', style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w900,
                                      color: isO ? Colors.grey : Colors.black),),
                                ],
                              )),
                        ),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 6.h,
                              padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 3.w),
                              decoration: BoxDecoration(
                                border: isO ? Border.all(color: Colors.deepOrange.shade100, width: 0.5.w): null,
                                  borderRadius: BorderRadius.circular(25.sp),
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: isO ?
                                      [Colors.deepOrange, Colors.deepOrange.shade900] : [Colors.deepOrange.shade900, Colors.deepOrange.shade900]
                                  )
                              ),
                              child: Row(
                                children: [
                                  Text('ENEMY', style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w900,
                                      color: !isO ? Colors.grey : Colors.black),),
                                  Spacer(),
                                  AspectRatio(aspectRatio: 1, child: enemy),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Transform(
                    transform: Matrix4.identity()
                    ..scale(scale)
                    ..translate(_x/scale, _y/scale, 0.0),
                    alignment: Alignment.center,
                    child: Container(
                      width: 50.w,
                      height: 50.w,
                      color: Colors.deepPurpleAccent.withOpacity(0.1),
                      child: Consumer<PowersGameController>(
                        builder: (context, gameController, child) {
                          return AnimatedBuilder(
                            animation: animationController,
                            builder: (context, child) {
                              List<Widget> lines = [];
                              createGridLines(50.w, 50.w, rows, columns, lines, Colors.white.withOpacity(0.1), animationController);
                              return Stack(
                                children: [
                                  ...lines,
                                  GridView.builder(
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: rows),
                                      padding: EdgeInsets.zero,
                                      itemCount: powersGridLength,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index){

                                    return InkWell(
                                      // // onTap: (gameController.isMyTurn &&
                                      // //     gameController.state == gameController.started) ? () async {
                                      // //
                                      // //   if (gameController.grid[index] == -1) {
                                      // //     final affirm = gameController.setManualMove(((index ~/ 3),
                                      // //     (index % 3)));
                                      // //     if (affirm != null){
                                      // //
                                      // //       widget.socket.emitWithAck('gameListener', affirm, ack: (data) {
                                      // //         print(data);
                                      // //       });
                                      // //     }
                                      // //   }
                                      // //   setState(() {});
                                      // } : null,
                                      child: Stack(
                                        children: [
                                          cells[index] != -1 ?
                                          AspectRatio(
                                            aspectRatio: 1,
                                           child: cells[index] == 0 ? enemy : myself,)
                                          :Container(),
                                          animatedSprites[index]
                                        ],
                                      ),
                                    );
                                      }),
                                ],
                              );
                            }
                          );
                        }
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: (){
                        for (int i = 0; i< rows*columns; i++){
                          cells[i] = -1;
                          spells[i] = -1;
                          spellNotifier.reset();
                        }
                        setState(() {
                        });
                      },
                      child: Text('RESET'),
                    ),
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: ElevatedButton(
                      onPressed: (){
                        setState(() {
                          cellDefender = true;
                        });
                      },
                      child: Text(cellDefender ? "SELECT CELL" : 'DEFEND CELL'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

class AnimatedSpriteWidget extends StatefulWidget {
  const AnimatedSpriteWidget({super.key, required this.index});
  final int index;
  @override
  State<AnimatedSpriteWidget> createState() => _AnimatedSpriteWidgetState();
}

class _AnimatedSpriteWidgetState extends State<AnimatedSpriteWidget> {
  @override
  Widget build(BuildContext context) {
    final spellNotifier = context.watch<SpellNotifier>();

    return spellNotifier.cell(widget.index) == -1 ? Container() : SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: SpriteAnimationWidget.asset(
        path: 'impacts.png',
        data: SpriteAnimationData.sequenced(
            amount: 6,
            stepTime: 0.1,
            textureSize: Vector2.all(64),
            texturePosition: Vector2(0, 64*(spellNotifier.cell(widget.index)) + 1),
            loop: true
        ),
      ),
    );
  }
}