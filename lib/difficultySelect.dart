import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'UIUX/customWidgets.dart';
import 'UIUX/themesAndStyles.dart';

class difficultySelect extends StatefulWidget {
  const difficultySelect({Key? key}) : super(key: key);

  @override
  State<difficultySelect> createState() => _difficultySelectState();
}

class _difficultySelectState extends State<difficultySelect> {
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
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: colorLightYellow,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.w))),
                    label: Text(
                      'Easy',
                      style: TextStyle(color: colorLightYellow, fontSize: 20),
                    ),
                    icon: Image.asset(
                      'assets/characters/all-05.png',
                      height: 1.h,
                    ),
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Container(
                  width: 80.w,
                  height: 6.h,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: colorLightYellow,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.w))),
                    label: Text(
                      'Medium',
                      style: TextStyle(color: colorDarkBlue, fontSize: 20),
                    ),
                    icon: Image.asset(
                      'assets/characters/all-08.png',
                      height: 1.h,
                    ),
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Container(
                  width: 80.w,
                  height: 6.h,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: colorLightYellow,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.w))),
                    label: Text(
                      'Hard',
                      style: TextStyle(color: colorLightYellow, fontSize: 20),
                    ),
                    icon: Image.asset(
                      'assets/characters/all-02.png',
                      height: 1.h,
                    ),
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Container(
                  width: 80.w,
                  height: 6.h,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colorDarkBlue,
                        foregroundColor: colorLightYellow,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.w))),
                    label: Text(
                      'Extreme',
                      style: TextStyle(color: colorLightYellow, fontSize: 20),
                    ),
                    icon: Image.asset(
                      'assets/characters/all-01.png',
                      height: 1.h,
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
