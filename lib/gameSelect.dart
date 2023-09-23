import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'UIUX/customWidgets.dart';
import 'UIUX/themesAndStyles.dart';

class gameSelect extends StatefulWidget {
  const gameSelect({Key? key}) : super(key: key);

  @override
  State<gameSelect> createState() => _gameSelectState();
}

class _gameSelectState extends State<gameSelect> {
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
                SizedBox(height: 18.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: colorDarkBlue,
                            width: 5.0,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(20),
                        color: colorDarkBlue,
                      ),
                      child: Column(
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.computer,
                                size: 45.w,
                                color: colorLightYellow,
                              )),
                          Text(
                            'Single Player',
                            style: TextStyle(
                                color: colorLightYellow,
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 3.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        // border: Border.all(
                        //     color: Colors.black,
                        //     width: 5.0,
                        //     style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.yellowAccent,
                      ),
                      child: Column(
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.group,
                                size: 45.w,
                                color: colorDarkBlue,
                              )),
                          Text(
                            'Multiplayer',
                            style: TextStyle(
                                color: colorDarkBlue,
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ]));
  }
}
