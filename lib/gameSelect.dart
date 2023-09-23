import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'UIUX/customWidgets.dart';
import 'UIUX/themesAndStyles.dart';

class GameSelectPage extends StatefulWidget {
  const GameSelectPage({Key? key}) : super(key: key);

  @override
  State<GameSelectPage> createState() => _GameSelectPageState();
}

class _GameSelectPageState extends State<GameSelectPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colorBlue,
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          const BackgroundScroller(),
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              children: [
                SizedBox(height: 16.h),
                Text(
                  'Select Game Mode',
                  style: TextStyle(
                      fontSize: titleSize,
                      color: colorLightYellow,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 3.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 260,
                      width: 250,
                      padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.w),
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
                      child: Column(
                        children: [
                          Image.asset('assets/characters/all-05.png',
                              width: 20.w),
                          Text(
                            'Single Player',
                            style: TextStyle(
                                color: colorLightYellow,
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 3.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 260,
                      width: 250,
                      padding: EdgeInsets.all(8.w),
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
                      child: Column(
                        children: [
                          Image.asset('assets/characters/all-10.png',
                              width: 30.w),
                          Text(
                            ' Multiplayer ',
                            style: TextStyle(
                                color: colorLightYellow,
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ]));
  }
}
