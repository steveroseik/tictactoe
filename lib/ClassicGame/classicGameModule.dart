import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/ClassicGame/classicWidgets.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/Authentication/sessionProvider.dart';
import 'package:tictactoe/Controllers/classicGameController.dart';
import 'package:tictactoe/UIUX/themesAndStyles.dart';
import 'package:tictactoe/spritesConfigurations.dart';

import '../UIUX/customWidgets.dart';

class ClassicGameModule extends StatefulWidget {
  final ClassicGameController controller;
  final Function(GameWinner, bool)? gameStateChanged;
  final Socket socket;
  final bool isNine;
  final bool speedMatch;
  final int? smallIndex;
  const ClassicGameModule({super.key,
    required this.controller,
    required this.socket,
    this.speedMatch = false,
    required this.gameStateChanged,
    this.isNine = false,
    this.smallIndex
    });

  @override
  State<ClassicGameModule> createState() => _ClassicGameModuleState();
}

class _ClassicGameModuleState extends State<ClassicGameModule> with TickerProviderStateMixin {

  late AnimationController _animationController;

  late ClassicGameController controller;

  late Animation _animation;

  late SessionProvider mainController;

  List<Widget> lines = [];

  double _progress = 0;

  late Widget opponentCharacter;
  late Widget myCharacter;

  late ClassicGameController gameControl;

  Timer? timeoutTimer;

  GameWinner? winner;

  @override
  void initState() {

    controller = widget.controller;

    if (controller.opponent.characterId != null){
      opponentCharacter = classicOppViewAvatar(Sprites.characterOf[characters.values[controller.opponent.characterId!]]!, controller.sameAvatar);
      myCharacter = Sprites.characterOf[characters.values[controller.me.characterId!]]!;
    }else{
      opponentCharacter = controller.opponent.character!.avatar;
      myCharacter = controller.me.character!.avatar;
    }

    _animationController = AnimationController(
        duration: Duration(milliseconds: 3000), vsync: this);

    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {
        setState(() {
          _progress = _animation.value;
        });
      });

    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => runTimeoutTimer());
    
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    mainController = context.watch<SessionProvider>();
    if (widget.isNine) gameControl = context.watch<ClassicGameController>();
    return (widget.isNine) ?
    Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          color: Colors.transparent),
      /// MAIN GRID
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
            builder: (context, constraints) {
              lines.clear();
              //Draw box lines
              createGridLines(
                  constraints.maxWidth,
                  constraints.maxWidth,
                  3,
                  3,
                  lines,
                  colorDarkBlue,
                  _animationController);
              final linearGrid = gameControl.grid[widget.smallIndex!];
              return Stack(
                children: lines
                  ..addAll([GridView.builder(
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: linearGrid.length,
                      itemBuilder: (context, index) {
                        return Container(
                          child: linearGrid[index] == -1
                              ? Container()
                              : linearGrid[index] ==
                              controller.myIndex ? myCharacter : opponentCharacter,
                        );
                      })]),
              );
            }),
      ),
    )
        : ChangeNotifierProvider<ClassicGameController>(
      create: (context) => controller,
      child: Consumer<ClassicGameController>(
        builder: (BuildContext context, ClassicGameController gameLiveController, Widget? child) {
          return Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 18.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 2.w),
                              decoration: BoxDecoration(
                                border: !controller.isMyTurn
                                    ? Border.all(color: Colors.purple)
                                    : null,
                                borderRadius:
                                BorderRadius.circular(15.sp),
                                color: !controller.isMyTurn
                                    ? Colors.deepOrange
                                    : Colors.purple,
                              ),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  controller.myConnection == GameConn.offline ?
                                  SizedBox(
                                    height:4.h,
                                    width:4.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 5,color: !controller.isMyTurn
                                        ? Colors.purple
                                        : Colors.deepOrange, strokeCap: StrokeCap.round,),
                                  )
                                      : SizedBox(
                                    height: 5.h,
                                    child: Stack(
                                      children: [
                                        if(controller.isMyTurn && controller.winner == GameWinner.none) CircularPercentIndicator(
                                            circularStrokeCap: CircularStrokeCap.round,
                                            progressColor: Colors.deepOrange,
                                            backgroundColor: Colors.purple,
                                            animation: true,
                                            animationDuration: 200,
                                            animateFromLastPercent: true,
                                            percent: _progress,
                                            radius: 5.h/2),
                                        AspectRatio(
                                            aspectRatio: 1,
                                            child: myCharacter),
                                      ],
                                    ),
                                  ),
                                  const Expanded(
                                    child: Text(
                                      'You',
                                      style: TextStyle(
                                        color: colorLightYellow,
                                      ),
                                      maxLines: 1,
                                      textAlign: TextAlign.end,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 7.w),
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 2.w),
                              decoration: BoxDecoration(
                                border: controller.isMyTurn
                                    ? Border.all(color: Colors.purple)
                                    : null,
                                borderRadius:
                                BorderRadius.circular(15.sp),
                                color: !controller.isMyTurn
                                    ? Colors.purple
                                    : Colors.deepOrange,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [

                                  controller.oppConnection == GameConn.offline ?
                                  SizedBox(
                                    height:4.h,
                                    width:4.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 5,color: controller.isMyTurn
                                        ? Colors.purple
                                        : Colors.deepOrange, strokeCap: StrokeCap.round,),
                                  )
                                      :  SizedBox(
                                    height: 5.h,
                                    child: Stack(
                                      children: [
                                        if(!controller.isMyTurn && controller.winner == GameWinner.none) AspectRatio(
                                          aspectRatio: 1,
                                          child: CircularPercentIndicator(
                                              circularStrokeCap: CircularStrokeCap.round,
                                              progressColor: Colors.deepOrange,
                                              backgroundColor: Colors.purple,
                                              animationDuration: 200,
                                              animation: true,
                                              animateFromLastPercent: true,
                                              percent: _progress,
                                              radius: 5.h/2),
                                        ),
                                        AspectRatio(
                                            aspectRatio: 1,
                                            child:opponentCharacter),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Expanded(
                                    child: Text(
                                      controller.opponent.userId,
                                      style: TextStyle(
                                          color: colorLightYellow,
                                          fontWeight: FontWeight.w500),
                                    ),
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
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          color: Colors.white24),
                      width: 80.w,
                      /// MAIN GRID
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: LayoutBuilder(
                            builder: (context, constraints) {
                              lines.clear();
                              //Draw box lines
                              createGridLines(
                                  constraints.maxWidth,
                                  constraints.maxWidth,
                                  3,
                                  3,
                                  lines,
                                  Colors.white.withOpacity(0.5),
                                  _animationController);
                              final linearGrid = <int>[];
                              for (var i in controller.grid) {
                                linearGrid.addAll(i);
                              }
                              return Stack(
                                children: lines
                                  ..addAll([
                                    Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        GridView.builder(
                                            gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                            ),
                                            physics: const NeverScrollableScrollPhysics(),
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            itemCount: linearGrid.length,
                                            itemBuilder: (context, index) {
                                              return InkWell(
                                                onTap: (controller.isMyTurn &&
                                                        controller.state == GameState.started) ? () async {
                                                  if (linearGrid[index] == -1) {
                                                    final affirm = controller.setManualMove(((index ~/ 3),
                                                        (index % 3)));
                                                    if (affirm != null){

                                                      widget.socket.emitWithAck('gameListener', affirm, ack: (data) {
                                                        print(data);
                                                      });
                                                    }
                                                  }
                                                  setState(() {});
                                                } : null,
                                                child: Container(
                                                  padding:
                                                  linearGrid[index] ==
                                                      -1 ? const EdgeInsets.all(5) : const EdgeInsets.all(20),
                                                  child: linearGrid[index] ==
                                                      -1
                                                      ? Container()
                                                      : linearGrid[index] ==
                                                      controller.myIndex ? myCharacter : opponentCharacter,
                                                ),
                                              );
                                            }),
                                      ],
                                    ),
                                  ]),
                              );
                            }),
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
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                        '/', (route) => false);
                                  },
                                  style: IconButton.styleFrom(
                                      backgroundColor:
                                      Colors.white.withOpacity(0.5)),
                                  icon: Icon(
                                    CupertinoIcons.house_alt_fill,
                                    color: Colors.deepPurple,
                                  )),
                            ),
                          ),
                          SizedBox(
                            width: 15.w,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: IconButton(
                                  onPressed: () async{
                                    widget.socket.disconnect();
                                    await Future.delayed(const Duration(seconds: 3));
                                    widget.socket.connect();
                                  },
                                  style: IconButton.styleFrom(
                                      backgroundColor:
                                      Colors.white.withOpacity(0.5)),
                                  icon: Icon(
                                    Icons.refresh_rounded,
                                    color: Colors.deepPurple,
                                  )),
                            ),
                          ),
                          SizedBox(
                            width: 15.w,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: IconButton(
                                  onPressed: () {
                                    mainController.signOut();
                                  },
                                  style: IconButton.styleFrom(
                                      backgroundColor:
                                      Colors.white.withOpacity(0.5)),
                                  icon: Icon(
                                    CupertinoIcons.gear_alt_fill,
                                    color: Colors.deepPurple,
                                  )),
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
  }

  runTimeoutTimer() async{
    // await Future.delayed(const Duration(seconds: 3));
    // setState(() {});
    if (widget.isNine) return;

    timeoutTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {

      if (widget.controller.state == GameState.coinToss) {
        timer.cancel();
        return;
      }

      print('${_progress} :: ${controller.isMyTurn}');

      if (controller.state == GameState.ended) {
        timer.cancel();
        return;
      }
      if (controller.state == GameState.paused){

        controller.addExtraTime(500);
        return;
      }
      if (controller.timeout == null) {
        if ( _progress != 0){
          setState(() {
            _progress = 0;
          });
        }
      }else{
        final now = DateTime.now();
        if (controller.timeout?.isAfter(now)?? false){
          setState(() {

            final perc = controller.timeout!.difference(now).inSeconds /
                (widget.speedMatch ? Const.speedRoundDuration : Const.classicRoundDuration);
            _progress = perc > 1 ? 1 : perc < 0 ? 0 : perc;
          });
        }else{
          if (controller.isMyTurn){
            print('played Random @ ${DateTime.now().toIso8601String()}');
            final req = controller.playRandom();
            if (req != null){
              widget.socket.emitWithAck('gameListener', req, ack: (data){
                print('eh? $data');
              });
            }
          }
          setState(() {
            _progress = 0;
          });
        }
      }

    });
  }

  // updateGameState(ClassicGameController controller) {
  //   if (controller.winner != winner) {
  //     print('sent');
  //     winner = controller.winner;
  //     if (widget.gameStateChanged != null) widget.gameStateChanged!(controller.winner, controller.iWon);
  //   }
  // }
}
