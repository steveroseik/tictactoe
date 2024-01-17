import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'package:sizer/sizer.dart';
import 'package:tictactoe/PowersGame/Characters/core.dart';
import 'package:tictactoe/routesGenerator.dart';
import 'package:tictactoe/spritesConfigurations.dart';

import '../UIUX/customWidgets.dart';
import '../UIUX/themesAndStyles.dart';

class MultiplayerSingleSelectPage extends StatefulWidget {
  const MultiplayerSingleSelectPage({Key? key}) : super(key: key);

  @override
  State<MultiplayerSingleSelectPage> createState() => _MultiplayerSingleSelectPageState();
}

class _MultiplayerSingleSelectPageState extends State<MultiplayerSingleSelectPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
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
          const BackgroundScroller(),
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 16.h),
                  Text(
                    'Select Game Mode',
                    style: TextStyle(
                        fontSize: titleSize,
                        color: colorDarkBlue,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(Routes.classicGameMain);
                        },
                        child: Container(
                          width: 98.w,
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
                            color: colorDarkBlue.withOpacity(0.8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 6.h,
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: Sprites.badgeOf[Badges.rookie],),
                                  ),
                                  Expanded(
                                    child: LinearPercentIndicator(
                                      percent: 0.5,
                                      backgroundColor: Colors.blueGrey.shade700,
                                      barRadius: const Radius.circular(20),
                                    ),
                                  ),
                                  Container(
                                    height: 7.h,
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: Sprites.badgeOf[Badges.apprentice],),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              GameButton(
                                  onPressed: (){},
                                  baseDecoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: [
                                            Colors.deepPurple.shade800,
                                            Colors.black
                                          ]
                                      ),
                                      borderRadius: BorderRadius.circular(15)
                                  ),
                                  topDecoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: [
                                            Colors.deepPurple,
                                            Colors.black
                                          ]
                                      ),
                                      borderRadius: BorderRadius.circular(15)
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  aspectRatio: 4/1,
                                  width: 98.w,
                                  child: DefaultTextStyle.merge(
                                    style: TextStyle(
                                      color: Colors.white,),
                                    child: Padding(
                                      padding: EdgeInsets.all(3),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(1.w),
                                            child: AspectRatio(
                                              aspectRatio: 1,
                                              child: Sprites.badgeOf[Badges.apprentice],),
                                          ),
                                          Text('Tiered Match',
                                          style: TextStyle(fontSize: 20),),
                                          Spacer(),
                                          Text('1000'),
                                          Container(
                                            height: 6.h,
                                            padding: EdgeInsets.all(3.w),
                                            child: AspectRatio(
                                              aspectRatio: 1,
                                              child: Sprites.coinOf[Coins.silver],),
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                              SizedBox(height: 2.h),
                              ElevatedButton(
                                  onPressed: (){},
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15)
                                      )
                                  ),
                                  child: Row(
                                    children: [
                                      Text('Random Match'),
                                      Spacer(),
                                      Text('500'),
                                      Container(
                                        height: 6.h,
                                        padding: EdgeInsets.all(3.w),
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: Sprites.coinOf[Coins.bronze],),
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                          top: -40,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Image.asset(
                                'assets/classic.png',
                            width: 60.w,),
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(Routes.classicGameMain);
                    },
                    child: Container(
                      width: 70.w,
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
                        color: colorDarkBlue,
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            CupertinoIcons.shuffle_medium,
                            color: Colors.white,
                            size: 70,
                          ),
                          Text(
                            "Classic",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26.0,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(Routes.ninesGameMain);
                    },
                    child: Container(
                      width: 70.w,
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
                        color: colorDarkBlue,
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.grid_4x4_outlined,
                            color: Colors.white,
                            size: 70,
                          ),
                          Text(
                            "Nine x Nine",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26.0,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(Routes.powersCharacterSelect);
                    },
                    child: Container(
                      width: 70.w,
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
                        color: colorDarkBlue,
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.power,
                            color: Colors.white,
                            size: 70,
                          ),
                          Text(
                            "Powers",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26.0,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('back'),),

            ),
          )
        ]));
  }
}
