import 'dart:async';
import 'dart:math';

import 'package:flame/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/Controllers/powersGameController.dart';
import 'package:tictactoe/PowersGame/Powers/cellBarrier.dart';
import 'package:tictactoe/PowersGame/Powers/quantumCellWidget.dart';
import 'package:tictactoe/PowersGame/Powers/sprites.dart';
import 'package:tictactoe/PowersGame/core.dart';
import 'package:tictactoe/PowersGame/powerCell.dart';
import 'package:tictactoe/PowersGame/powerWidgets.dart';
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
  final GameRoom roomInfo;
  final Function() checkWin;
  final Function(Map<String, dynamic> data)? sendTournamentUpdate;
  const PowersGameModule({super.key,
    required this.gameController,
    required this.roomInfo,
    required this.checkWin,
    this.sendTournamentUpdate,
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

  ValueNotifier<double> _progress = ValueNotifier(0.0);

  Timer? timeoutTimer;


  @override
  void initState() {
    animationController = AnimationController(duration: Duration(milliseconds: 3000), vsync: this);
    gameController = widget.gameController;
    animation = Tween(begin: 0.0, end: 1.0).animate(animationController);
    spellNotifier = SpellNotifier(length: rows*columns);
    runTimeoutTimer(socket: widget.socket);
    initTapsListener();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    gridTaps.close();
    timeoutTimer?.cancel();

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
              // onScaleUpdate: (scaleDet){
              //   setState(() {
              //     scale = _baseScaleFactor * scaleDet.scale;
              //     if (scale < 1.2){
              //       scale = 1.2;
              //     }
              //     if (scale > 2){
              //       scale = 2;
              //     }
              //     final trueHeight = (100.h *scale)/4;
              //     final trueWidth = (100.w *scale)/4;
              //     _x += scaleDet.focalPoint.dx - prev.dx;
              //     _y += scaleDet.focalPoint.dy - prev.dy;
              //     if (_x >= trueWidth || _x <= -trueWidth){
              //       _x = _x.isNegative ? -trueWidth : trueWidth;
              //     }
              //     if (_y >= trueHeight || _y <= -trueHeight){
              //       _y = _y.isNegative ? -trueHeight : trueHeight;
              //     }
              //     prev = scaleDet.focalPoint;
              //   });
              // },
              // onScaleStart: (scaleDet){
              //   _baseScaleFactor = scale;
              //   prev = scaleDet.focalPoint;
              // },
              child: SizedBox(
                height: 100.h,
                width: 100.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.deepOrange,
                                Colors.deepOrange,
                                Colors.deepPurple.shade800
                              ])),
                    ),
                    Align(
                        alignment: Alignment.topCenter,
                        child: const BackgroundScroller()),
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                onPressed: (){},
                                icon: Icon(CupertinoIcons.gear_alt_fill),
                              ),
                            ),
                            SizedBox(
                              width: 100.w,
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      height: 6.h,
                                      padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 3.w),
                                      decoration: BoxDecoration(
                                          border: !gameController.isMyTurn ? Border.all(color: Colors.deepOrange.shade100, width: 0.5.w): null,
                                          borderRadius: BorderRadius.circular(25.sp),
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: !gameController.isMyTurn ?
                                              [Colors.deepOrange, Colors.deepOrange.shade900] : [Colors.deepOrange.shade900, Colors.deepOrange.shade900]
                                          )
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('ENEMY', style: TextStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w800,
                                              color: gameController.isMyTurn ? Colors.grey : Colors.black),),
                                          SizedBox(width: 10.w),
                                          AspectRatio(aspectRatio: 1, child: controller.oppCharacter.avatar),
                                        ],
                                      )),
                                  Expanded(
                                    child: ValueListenableBuilder(
                                        valueListenable: _progress,
                                        builder: (context, progress, child) {
                                          return controller.oppConnection == GameConn.offline ?
                                             Padding(
                                               padding: const EdgeInsets.all(10.0),
                                               child: LinearProgressIndicator(
                                                 color: Colors.deepOrange,
                                                 backgroundColor: Colors.black,
                                                 borderRadius: BorderRadius.circular(20),
                                               ),
                                             )
                                              : AnimatedOpacity(
                                            duration: const Duration(milliseconds: 300),
                                            opacity: (!controller.isMyTurn && controller.winner == GameWinner.none) ? 1 : 0,
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: LinearPercentIndicator(
                                                animation: true,
                                                animateFromLastPercent: true,
                                                animationDuration: 600,
                                                progressColor: Colors.deepPurple,
                                                backgroundColor: Colors.black,
                                                percent: progress,
                                                barRadius: const Radius.circular(20),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Card(
                                elevation: 20,
                                color: Colors.transparent,
                                shadowColor: colorDeepOrange,
                                surfaceTintColor: Colors.yellow,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Container(
                                  width: 95.w,
                                  height: 95.w,
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
                                        createGridLines(94.5.w, 94.9.w, rows, columns, lines, Colors.black.withOpacity(0.7), animationController);
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
                                                      if (tapsSub != null && controller.state == GameState.started){
                                                        gridTaps.add(index);
                                                      }
                                                    },
                                                    child: Stack(
                                                      alignment: Alignment.center,
                                                      children: [
                                                        Positioned.fill(child: Container(
                                                          color: accumulatedCells.contains(index)
                                                              ? Colors.red : Colors.transparent,)),
                                                        if (controller.grid[row][col].spell != null) viewSpell(controller.grid[row][col]),
                                                        if (controller.grid[row][col].observedVal != -1) Padding(
                                                          padding: EdgeInsets.all(2.w),
                                                          child: viewCell(controller.grid[row][col], controller, index),
                                                        ),
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
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: 100.w,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: controller.myConnection == GameConn.offline ?
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: LinearProgressIndicator(
                                          color: Colors.deepOrange,
                                          backgroundColor: Colors.black,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      )
                                          : ValueListenableBuilder(
                                          valueListenable: _progress,
                                          builder: (context, progress, child) {
                                            return AnimatedOpacity(
                                              duration: const Duration(milliseconds: 300),
                                              opacity: (controller.isMyTurn && controller.winner == GameWinner.none) ? 1 : 0,
                                              child: Padding(
                                                padding: const EdgeInsets.all(10),
                                                child: LinearPercentIndicator(
                                                  animation: true,
                                                  animateFromLastPercent: true,
                                                  animationDuration: 600,
                                                  progressColor: colorPurple,
                                                  backgroundColor: Colors.black,
                                                  percent: progress,
                                                  barRadius: const Radius.circular(20),
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                                    AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        height: 6.h,
                                        padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 3.w),
                                        decoration: BoxDecoration(
                                            border: gameController.isMyTurn ? Border.all(color: Colors.deepOrange.shade100, width: 0.5.w): null,
                                            borderRadius: BorderRadius.circular(25.sp),
                                            gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: gameController.isMyTurn ?
                                                [Colors.deepOrange, Colors.deepOrange.shade900] : [Colors.deepOrange.shade900, Colors.deepOrange.shade900]
                                            )
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AspectRatio(aspectRatio: 1, child: controller.myCharacter.avatar),
                                            SizedBox(width: 10.w),
                                            Text('YOU', style: TextStyle(
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w800,
                                                color: !gameController.isMyTurn ? Colors.grey : Colors.black),),
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
                                    Text('Select a power to set (${3-pTimeoutCounter+1})',
                                        style: const TextStyle(
                                          color: Colors.white,)),
                                    LinearPercentIndicator(
                                      animation: true,
                                      animationDuration: 1000,
                                      animateFromLastPercent: true,
                                      percent: 1-(pTimeoutCounter/3),
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
                                          accumulatedCells.clear();
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
                                          padding: EdgeInsets.all(4.w),
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
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
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
                                              SizedBox(height: 2.w),
                                              Row(
                                                children: [
                                                  Expanded(child: LinearPercentIndicator(
                                                    percent: 1,
                                                    progressColor: colorYellow,
                                                    barRadius: const Radius.circular(20),
                                                  )),
                                                  CircleAvatar(
                                                    backgroundColor: Colors.deepPurple,
                                                    radius: 3.w,
                                                    child: Center(child: Text('1')),
                                                  ),
                                                ],
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
                                          accumulatedCells.clear();
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

  Widget viewSpell(PowerCell cell){

    print(cell.spell!.effect);

    switch(cell.spell!.effect){

      case CellEffect.protected:
        return AspectRatio(
          aspectRatio: 1,
          child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..scale(1.9),
              child: gaurdianPowerSprite(cell.spell!, gameController)),
        );
      case CellEffect.swapped:
        return Padding(
          padding: EdgeInsets.all(0.5.w),
          child: AspectRatio(
            aspectRatio: 1,
            child: Opacity(
                opacity: 0.4,
                child: gameController.myCharacter.avatar),
          ),
        );
      case CellEffect.quantum:
        return QuantumCellWidget(
            controller: gameController);

      case CellEffect.empty:
      case CellEffect.hidden:
        if (cell.spell!.from == gameController.myIndex) {
          return Padding(
            padding: EdgeInsets.all(2.w),
            child: AspectRatio(
              aspectRatio: 1,
              child: Opacity(
                  opacity: 0.4,
                  child: gameController.myCharacter.avatar),
            ),
          );
        }else if (cell.spell!.effect == CellEffect.empty){
          return Padding(
            padding: EdgeInsets.all(2.w),
            child: AspectRatio(
              aspectRatio: 1,
              child: Opacity(
                  opacity: 0.4,
                  child: gameController.oppCharacter.avatar),
            ),
          );
        }
        break;
      case CellEffect.hiddenTrap:
        // TODO: Handle this case.
      case CellEffect.trap:
        // TODO: Handle this case.
      case CellEffect.trapped:
        // TODO: Handle this case.
      case CellEffect.extraCell:
        // TODO: Handle this case.
      case CellEffect.decoy:
        // TODO: Handle this case.
    }
    return Container();

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

  setPowerTimeout(){
    setState(() {
      powerTimerOn = true;
    });

    pTimeoutCounter = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (pTimeoutCounter >= 3 || firstPower != null) {
          timer.cancel();
          pTimeoutCounter = 0;
          powerTimerOn = false;
          if (firstPower == null) {
            final resp = gameController.sendEndRound();
            if (resp != null){
              widget.socket.emitWithAck('gameListener', resp, ack: (data){
                widget.checkWin();
                final req = gameController.endMyRound();
                if (req != null) widget.sendTournamentUpdate??(req);
              });
            }
          }
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
      playSpell();
    }else{
      // nothing yet
    }
  }

  playSpell(){
    // TODO:: confirm cells
    bool playHidden = false;
    playHidden = checkStealthPower();
    final spells = gameController.setSpellMove(cells: accumulatedCells, firstPower: firstPower!);
    if (spells == null){
      // can play again, blocked
      print('blocked');
    }else{
      ///TODO: should check if trapped
      gameController.playedSpell();
      requestSpellConfirmation(
          gameController.requestSpellConfirmation(spells, firstPower!));

      firstPower = null;
      if (playHidden){
        handleSingleTap(accumulatedCells.first);
      }
    }
    accumulatedCells.clear();
  }

  bool checkStealthPower(){
    if (gameController.myCharacter.type == characterType.wraith
        && firstPower == true){
      return true;
    }
    return false;
  }

  runTimeoutTimer({required Socket socket}) async{
    // await Future.delayed(const Duration(seconds: 3));
    // setState(() {});

    timeoutTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {

      if (gameController.state == GameState.ended) {
        timer.cancel();
        return;
      }
      if (gameController.state == GameState.paused){
        return;
      }
      if (gameController.timeout == null && _progress.value != 0) {
        _progress.value = 0;
      }else{
        final now = DateTime.now();
        if (gameController.timeout!.isAfter(now)){
          final perc = gameController.timeout!.difference(now).inSeconds / Const.powersRoundDuration;
          _progress.value = perc > 1 ? 1 : perc < 0 ? 0 : perc;
        }else{
          if (gameController.isMyTurn){
            if (gameController.canPlayMove){
              final req = gameController.playRandom();
              if (req != null){
                gameController.playedMove();
                widget.socket.emitWithAck('gameListener', req, ack: (data){

                });
              }
            }else{
              final resp = gameController.sendEndRound();
              if (resp != null){
                widget.socket.emitWithAck('gameListener', resp, ack: (data){
                  widget.checkWin();
                  final req = gameController.endMyRound();
                  if (req != null) widget.sendTournamentUpdate??(req);
                });
              }
            }
            firstPower = null;
            accumulatedCells.clear();
          }
          _progress.value = 0;
        }
      }

    });
  }

  // sendToGameListener(dynamic data){
  //   widget.socket.emitWithAck('gameListener', data, ack: (data){
  //
  //   });
  // }
}


