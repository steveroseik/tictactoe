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

enum lvl {easy, medium, hard, extreme, none}

class _DifficultySelectPageState extends State<DifficultySelectPage> {
  bool _hasBeenPressed = false;

  lvl difficulty = lvl.none;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colorBlue,
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          const BackgroundScroller(),
          AppBar(backgroundColor: Colors.transparent),
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
                    onPressed: () {
                      setState(() {
                        difficulty = lvl.easy;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: difficulty == lvl.easy ? colorDarkBlue : Colors.blue[100],
                        foregroundColor: difficulty == lvl.easy ? Colors.blue[100] : colorDarkBlue,
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
                                TextStyle(fontSize: 20),
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
                    onPressed: () {
                      setState(() {
                        difficulty = lvl.medium;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: difficulty == lvl.medium ? colorDarkBlue : Colors.blue[300],
                        foregroundColor: difficulty == lvl.medium ? Colors.blue[300] : colorDarkBlue,
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
                                TextStyle(fontSize: 20),
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
                    onPressed: () {
                      setState(() {
                        difficulty = lvl.hard;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: difficulty == lvl.hard ? colorDarkBlue : Colors.blue[700],
                        foregroundColor: difficulty == lvl.hard ? Colors.blue[700] : colorDarkBlue,
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
                                TextStyle(fontSize: 20),
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
                    onPressed: () {
                      setState(() {
                        difficulty = lvl.extreme;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: difficulty == lvl.extreme ? colorDarkBlue : Colors.blue[900],
                        foregroundColor: difficulty == lvl.extreme ? Colors.blue[900] : colorDarkBlue,
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
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 30.w,
                      decoration: BoxDecoration(
                        border: _hasBeenPressed
                            ? Border.all(
                                color: Colors.blue,
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
                          size: 40,
                          color: _hasBeenPressed
                              ? colorDarkBlue
                              : colorLightYellow,
                        ),


                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 30.w,
                      decoration: BoxDecoration(
                        border: !_hasBeenPressed
                            ? Border.all(
                                color: Colors.blue,
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
                            size: 40,
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
                  width: 60.w,
                  height: 6.h,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/game');
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colorDarkBlue,
                          foregroundColor: colorLightYellow,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.w))),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              'Start Game',
                              style: TextStyle(
                                  color: colorLightYellow, fontSize: 15.sp),
                            ),
                          ),
                          Align(alignment: Alignment.centerRight, child: Icon(CupertinoIcons.right_chevron))
                        ],
                      )),
                ),
              ],
            ),
          )
        ]));
  }
}
