import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../UIUX/customWidgets.dart';
import '../UIUX/themesAndStyles.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBlue,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const BackgroundScroller(),
          AppBar(
              excludeHeaderSemantics: true,
              backgroundColor: Colors.transparent),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  Text(
                    'Signup',
                    style: TextStyle(
                        fontSize: titleSize,
                        color: colorLightYellow,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    // controller: emailField,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                        color: colorLightYellow, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: colorMediumBlue,
                      hintStyle: TextStyle(color: colorLightGrey),
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(
                        Icons.email,
                        color: colorLightYellow,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.w),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.w),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    // controller: emailField,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                        color: colorLightYellow, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: colorMediumBlue,
                      hintStyle: TextStyle(color: colorLightGrey),
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(
                        Icons.key,
                        color: colorLightYellow,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.w),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.w),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    // controller: emailField,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                        color: colorLightYellow, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Re-enter Password',
                      filled: true,
                      fillColor: colorMediumBlue,
                      hintStyle: TextStyle(color: colorLightGrey),
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(
                        Icons.key,
                        color: colorLightYellow,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.w),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.w),
                          borderSide: BorderSide.none),
                    ),
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
                            backgroundColor: colorDarkBlue,
                            foregroundColor: colorLightYellow,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.w))),
                        child: Text(
                          'Create Account',
                          style: TextStyle(color: colorLightYellow),
                        )),
                  ),
                  SizedBox(height: 5.h),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Divider(
                            thickness: 2,
                            color: colorLightYellow,
                          )),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'OR',
                          style: TextStyle(color: colorLightYellow, fontSize: 16),
                        ),
                      ),
                      Expanded(
                          child: Divider(
                            thickness: 2,
                            color: colorLightYellow,
                          )),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: colorLightYellow),
                        child: IconButton(
                            onPressed: () {},
                            icon: Image.asset(
                              'assets/google_icon.png',
                              height: 3.h,
                            )),
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: colorLightYellow),
                        child: IconButton(
                            onPressed: () {},
                            icon: Image.asset(
                              'assets/apple_icon.png',
                              height: 3.5.h,
                            )),
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: colorLightYellow),
                        child: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.facebook_rounded,
                              color: CupertinoColors.systemBlue,
                              size: 3.5.h,
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
