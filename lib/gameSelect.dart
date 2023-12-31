import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/routesGenerator.dart';

import 'UIUX/customWidgets.dart';
import 'UIUX/themesAndStyles.dart';

class ClassicGameSelectPage extends StatefulWidget {
  const ClassicGameSelectPage({Key? key}) : super(key: key);

  @override
  State<ClassicGameSelectPage> createState() => _ClassicGameSelectPageState();
}

class _ClassicGameSelectPageState extends State<ClassicGameSelectPage> {
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
                            "Random",
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
                  Container(
                    height: 50.w,
                    width: 50.w,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/characters/all-10.png',
                            width: 20.w),
                        SizedBox(height: 2.h),
                        Text(
                          ' Multiplayer ',
                          style: TextStyle(
                              color: colorLightYellow,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ]));
  }
}
