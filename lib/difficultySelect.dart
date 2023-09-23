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
                        backgroundColor: Colors.green,
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
                            style: TextStyle(color: colorDarkBlue, fontSize: 20),
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
                        backgroundColor: Colors.yellow,
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
                            style: TextStyle(color: colorDarkBlue, fontSize: 20),
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
                        backgroundColor: Colors.red,
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
                            style: TextStyle(color: colorDarkBlue, fontSize: 20),
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
                        backgroundColor: colorDarkBlue,
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
                            'Medium',
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
                        border: Border.all(
                            color: colorLightYellow,
                            width: 3.0,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(20),
                        color: colorDarkBlue,
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'X',
                          style: TextStyle(
                              fontSize: 48,
                              color: colorLightYellow,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Container(
                      width: 30.w,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: colorDarkBlue,
                            width: 2.0,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(20),
                        color: colorDarkBlue,
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'O',
                          style: TextStyle(
                              fontSize: 48,
                              color: colorLightYellow,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
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
