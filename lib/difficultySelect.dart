import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'UIUX/customWidgets.dart';
import 'UIUX/themesAndStyles.dart';

class DifficultySelectPage extends StatefulWidget {
  const DifficultySelectPage({Key? key}) : super(key: key);

  @override
  State<DifficultySelectPage> createState() => _DifficultySelectPageState();
}

class _DifficultySelectPageState extends State<DifficultySelectPage> {
  bool _hasBeenPressed = false;

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
                SizedBox(height: 20.h),
                Text(
                  'Select Difficulty',
                  style: TextStyle(
                      fontSize: titleSize,
                      color: colorLightYellow,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Container(
                  width: 80.w,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[100],
                        foregroundColor: colorLightYellow,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.w))),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                            'assets/characters/all-05.png',
                            height: 5.h,
                          ),
                        ),
                        Center(
                          child: Text(
                            'Easy',
                            style:
                                TextStyle(color: colorDarkBlue, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Container(
                  width: 80.w,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[300],
                        foregroundColor: colorLightYellow,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.w))),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                            'assets/characters/all-08.png',
                            height: 5.h,
                          ),
                        ),
                        Center(
                          child: Text(
                            'Medium',
                            style:
                                TextStyle(color: colorDarkBlue, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Container(
                  width: 80.w,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: colorLightYellow,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.w))),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                            'assets/characters/all-02.png',
                            height: 5.h,
                          ),
                        ),
                        Center(
                          child: Text(
                            'Hard',
                            style:
                                TextStyle(color: colorDarkBlue, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Container(
                  width: 80.w,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        foregroundColor: colorLightYellow,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.w))),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                            'assets/characters/all-01.png',
                            height: 5.h,
                          ),
                        ),
                        Center(
                          child: Text(
                            'Extreme',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30.w,
                      decoration: BoxDecoration(
                        border: _hasBeenPressed
                            ? Border.all(
                                color: colorLightYellow,
                                width: 3.0,
                                style: BorderStyle.solid)
                            : null,
                        borderRadius: BorderRadius.circular(20),
                        color: _hasBeenPressed ? Colors.blue : Colors.black,
                      ),
                      child: TextButton(
                        onPressed: () => {
                          setState(() {
                            _hasBeenPressed = !_hasBeenPressed;
                          })
                        },
                        child: Icon(
                          CupertinoIcons.xmark,
                          size: 70,
                          color: _hasBeenPressed
                              ? colorDarkBlue
                              : colorLightYellow,
                        ),

                        // Text(
                        //   'X',
                        //   style: TextStyle(
                        //       fontSize: 48,
                        //       color: _hasBeenPressed
                        //           ? colorDarkBlue
                        //           : colorLightYellow,
                        //       fontWeight: FontWeight.bold),
                        // ),
                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Container(
                      width: 30.w,
                      decoration: BoxDecoration(
                        border: !_hasBeenPressed
                            ? Border.all(
                                color: colorLightYellow,
                                width: 3.0,
                                style: BorderStyle.solid)
                            : null,
                        borderRadius: BorderRadius.circular(20),
                        color: _hasBeenPressed ? Colors.black : Colors.blue,
                      ),
                      child: TextButton(
                          onPressed: () => {
                                setState(() {
                                  _hasBeenPressed = !_hasBeenPressed;
                                })
                              },
                          child: Icon(
                            CupertinoIcons.circle,
                            size: 70,
                            color: _hasBeenPressed
                                ? colorLightYellow
                                : colorDarkBlue,
                          )),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.h,
                ),
                Container(
                  width: 50.w,
                  height: 6.h,
                  child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colorDarkBlue,
                          foregroundColor: colorLightYellow,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.w))),
                      child: Text(
                        'Start',
                        style: TextStyle(
                            color: colorLightYellow, fontSize: titleSize),
                      )),
                ),
              ],
            ),
          )
        ]));
  }
}
