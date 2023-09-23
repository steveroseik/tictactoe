import 'package:flutter/material.dart';
import 'package:neumorphic_button/neumorphic_button.dart';
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
                SizedBox(height: 25.h),
                Text(
                  'Select Game Mode',
                  style: TextStyle(
                      fontSize: titleSize,
                      color: colorLightYellow,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 6.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(
                              color: colorDarkBlue.withOpacity(0.5),
                              offset: Offset(3, 3),
                              spreadRadius: 1,
                              blurRadius: 3
                            )],
                            color: colorLightYellow,
                          ),
                      child: Column(
                        children: [
                          Image.asset('assets/characters/all-05.png', width: 20.w),
                          Text(
                            'Single Player',
                            style: TextStyle(
                                color: colorDarkBlue,
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 3.h,
                ),
                // Container(
                //   decoration: BoxDecoration(
                //     // border: Border.all(
                //     //     color: Colors.black,
                //     //     width: 5.0,
                //     //     style: BorderStyle.solid),
                //     borderRadius: BorderRadius.circular(20),
                //     color: Colors.yellowAccent,
                //   ),
                //   child: Column(
                //     children: [
                //       IconButton(
                //           onPressed: () {},
                //           icon: Icon(
                //             Icons.group,
                //             size: 45.w,
                //             color: colorDarkBlue,
                //           )),
                //       Text(
                //         'Multiplayer',
                //         style: TextStyle(
                //             color: colorDarkBlue,
                //             fontSize: titleSize,
                //             fontWeight: FontWeight.bold),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          )
        ]));
  }
}
