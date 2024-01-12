import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:sizer/sizer.dart';
import 'package:tictactoe/PowersGame/Characters/core.dart';
import 'package:tictactoe/routesGenerator.dart';

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
            child: Padding(
              padding: EdgeInsets.all(10.w),
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
                      Navigator.of(context).pushNamed(Routes.powersGameMain,
                      arguments: Minotaur(power1Level: 1, power2Level: 1, playerState: -1));
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
