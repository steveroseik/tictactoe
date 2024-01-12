import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/Controllers/powersGameController.dart';
import 'package:tictactoe/PowersGame/cellBarrier.dart';
import 'package:tictactoe/PowersGame/core.dart';
import 'package:tictactoe/PowersGame/powerCell.dart';
import 'package:tictactoe/UIUX/themesAndStyles.dart';
import 'package:tictactoe/objects/powerRoomObject.dart';
import 'package:tictactoe/spritesConfigurations.dart';
import '../Configurations/constants.dart';
import '../UIUX/customWidgets.dart';
import '../routesGenerator.dart';

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
  final PowersRoom roomInfo;
  const PowersGameModule({super.key,
    required this.gameController,
    required this.roomInfo,
    required this.socket});

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

  Widget enemy = Sprites.characterOf[characters.reaper1]!;
  Widget myself = Sprites.characterOf[characters.maskDude]!;

  ValueNotifier<characters> en = ValueNotifier(characters.reaper1);

  StreamController<int> gridTaps = StreamController<int>();

  StreamSubscription<int>? tapsSub;

  late SpellNotifier spellNotifier;
  late PowersGameController gameController;


  bool? firstPower;

  List<int> accumulatedCells = [];

  bool canPlayPowers = false;

  bool powerTimerOn = false;

  int pTimeoutCounter = 0;


  @override
  void initState() {
    animationController = AnimationController(duration: Duration(milliseconds: 3000), vsync: this);
    gameController = widget.gameController;
    animation = Tween(begin: 0.0, end: 1.0).animate(animationController);
    cells = List<int>.generate(rows*columns, (index) => -1);
    spells = List<int>.generate(rows*columns, (index) => -1);
    spellNotifier = SpellNotifier(length: rows*columns);

    initTapsListener();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    gridTaps.close();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => gameController,
      builder: (context, child) {
        return Consumer<PowersGameController>(
          builder: (context, controller, child) {
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
              child: Container(
                height: 100.h,
                width: 100.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Transform(
                          transform: Matrix4.identity()
                            ..translate(_x/3, _y/3, 0.0)
                            ..scale(scale),
                          child: const BackgroundAnimation()),
                    ),
                    Positioned(
                      left: 5.w,
                      top: 10.h,
                      child: SizedBox(
                        width: 90.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    canPlayPowers = !canPlayPowers;
                                  });
                                },
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
                                        AspectRatio(aspectRatio: 1, child: controller.myCharacter.avatar),
                                        Spacer(),
                                        Text('YOU', style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w900,
                                            color: isO ? Colors.grey : Colors.black),),
                                      ],
                                    )),
                              ),
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
                                      AspectRatio(aspectRatio: 1, child: controller.oppCharacter.avatar),
                                    ],
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      // transform: Matrix4.identity()
                      //   ..scale(scale)
                      //   ..translate(_x/scale, _y/scale, 0.0),
                      // alignment: Alignment.center,
                      child: Card(
                        elevation: 20,
                        color: Colors.transparent,
                        shadowColor: colorDeepOrange,
                        surfaceTintColor: Colors.yellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Container(
                          width: 90.w,
                          height: 90.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorDeepOrange.withOpacity(0.7),
                                colorPurple.withOpacity(0.6)
                              ]
                            )
                          ),
                          child: AnimatedBuilder(
                              animation: animationController,
                              builder: (context, child) {
                                List<Widget> lines = [];
                                createGridLines(90.w, 90.w, rows, columns, lines, Colors.black.withOpacity(0.7), animationController);
                                return Stack(
                                  children: [
                                    ...lines,
                                    GridView.builder(
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: rows),
                                        padding: EdgeInsets.zero,
                                        itemCount: gridLen*gridLen,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index){
                                          final row = index ~/ gridLen;
                                          final col = index % gridLen;
                                          return GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              if (tapsSub != null){
                                                gridTaps.add(index);
                                              }
                                            },
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Positioned.fill(child: Container(
                                                  color: accumulatedCells.contains(index)
                                                      ? Colors.red : Colors.transparent,)),
                                                controller.grid[row][col].observedVal != -1 ?
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: viewCell(controller.grid[row][col], controller, index),
                                                )
                                                    :Container(),
                                                // animatedSprites[index]
                                              ],
                                            ),
                                          );
                                        }),
                                  ],
                                );
                              }
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5.h,
                      right: 0,
                      left: 0,
                      child: SafeArea(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder:
                              (child, animation) =>
                                  SlideTransition(
                                      position:Tween(
                                          begin: Offset(0, 3),
                                          end: Offset(0, 0)).animate(animation),
                                      child: child),
                          child: (controller.canPlaySpell) ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedOpacity(
                                    opacity: powerTimerOn ? 1 : 0,
                                    duration: const Duration(milliseconds: 300),
                                child: Column(
                                  children: [
                                    Text('Select a power to set (${3-pTimeoutCounter})',
                                        style: const TextStyle(
                                          color: Colors.white,)),
                                    LinearPercentIndicator(
                                      animation: true,
                                      animationDuration: 1000,
                                      animateFromLastPercent: true,
                                      percent: pTimeoutCounter/3,
                                      barRadius: const Radius.circular(20),
                                      lineHeight: 10,
                                    ),
                                  ],
                                ),),
                                const SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          if (firstPower != true){
                                            setState(() {
                                              firstPower = true;
                                            });
                                          }else if (firstPower == true){
                                            setState(() {
                                              firstPower = null;
                                            });
                                          }

                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(6.w),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: colorDarkBlue.withOpacity(0.5),
                                                  offset: Offset(3, 3),
                                                  spreadRadius: 1,
                                                  blurRadius: 3)
                                            ],
                                            color: firstPower == true ? colorPurple : colorDarkBlue,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.icecream_outlined,
                                                color: firstPower == true ? colorDeepOrange : Colors.white,
                                              ),
                                              Text(
                                                controller.myCharacter.firstPower.name,
                                                style: TextStyle(
                                                  color: firstPower == true ? colorDeepOrange : Colors.white,

                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: InkWell(
                                        onTap: (){
                                          if (firstPower != false){
                                            setState(() {
                                              firstPower = false;
                                            });
                                          }else if (firstPower == false){
                                            setState(() {
                                              firstPower = null;
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(6.w),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: colorDarkBlue.withOpacity(0.5),
                                                  offset: Offset(3, 3),
                                                  spreadRadius: 1,
                                                  blurRadius: 3)
                                            ],
                                            color: firstPower == false ? colorPurple : colorDarkBlue,
                                          ),
                                          child:  Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.icecream_outlined,
                                                color: firstPower == false ? colorDeepOrange : Colors.white,
                                              ),
                                              Text(
                                                controller.myCharacter.secondPower.name,
                                                style: TextStyle(
                                                  color: firstPower == false ? colorDeepOrange : Colors.white,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ) : Container(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  Widget oppAvatarView(PowersGameController controller){
    if (controller.sameAvatar) {
      return ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (rect) => LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepOrange.withOpacity(0.9),
            Colors.purple.withOpacity(0.2)
          ]).createShader(rect),
        child: controller.oppCharacter.avatar,);
    }else{
      return controller.oppCharacter.avatar;
    }
  }

  initTapsListener(){
    tapsSub = gridTaps.stream.listen((indexTapped) {
      print('tapped: $indexTapped');

      if (gameController.isMyTurn){
        if (firstPower == null){
          handleSingleTap(indexTapped);
        }else{
          handleSpellTap(indexTapped);
        }
      }
    });
  }

  requestSpellConfirmation(Map<String, dynamic> response){
    widget.socket.emitWithAck('gameListener', response, ack:  (data){
      print('spell resp: $data');
    });
  }

  handleSingleTap(int index) {
    if (!gameController.canPlayMove) return;
    final resp = gameController.setManualMove((index ~/ gridLen, index % gridLen ));
    if (resp == null) return;
    if (resp) {
      // passed
    } else {
      // trapped
    }
    gameController.playedMove();
    final req = gameController.requestMoveConfirmation(index);
    widget.socket.emitWithAck('gameListener', req, ack:  (data){
      print('dsata: $data');
      if (gameController.canPlaySpell) setPowerTimeout();
    });
  }

  Widget viewCell(PowerCell cell, PowersGameController controller, index){

    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
        child: AspectRatio(
          key: Key('${cell.value}${cell.spell?.effect}'
              '${cell.resultVal}${cell.observedVal}'),
          aspectRatio: 1,
          child: (cell.observedVal != controller.myIndex) ?
          (cell.observedVal == Const.qCell) ? Container() : oppAvatarView(controller) :
          controller.myCharacter.avatar,
        )
    );

  }

  setPowerTimeout(){
    setState(() {
      powerTimerOn = true;
    });

    pTimeoutCounter = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (pTimeoutCounter >= 3) {
          timer.cancel();
          pTimeoutCounter = 0;
          powerTimerOn = false;
          final resp = (firstPower == null) ?
          gameController.endMyRound() : null;
          if (resp != null) widget.socket.emit('gameListener', resp);
        }else{
          pTimeoutCounter++;
        }
      });
    });
  }

  handleSpellTap(int index){
    if (!gameController.canPlaySpell) return;
    // check on cell authenticity
    int requiredCells = gameController.requiredCell(firstPower: firstPower!);
    if (accumulatedCells.length < requiredCells){
      if (!accumulatedCells.contains(index)){
        setState(() {
          accumulatedCells.add(index);
        });
      }else{
        setState(() {
          accumulatedCells.remove(index);
        });
      }
    }
    if (accumulatedCells.length == requiredCells){
      // TODO:: confirm cells
      final response = gameController.setSpellMove(cells: accumulatedCells, firstPower: firstPower!);
      if (response == null){
        // can play again, blocked
        print('blocked');
      }else{
        ///TODO: should check if trapped

        gameController.playedSpell();
        requestSpellConfirmation(response);
        firstPower = null;
      }
      accumulatedCells.clear();
    }else{
      // nothing yet
    }
  }
}


