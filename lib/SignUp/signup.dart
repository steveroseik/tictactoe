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
          Padding(
            padding: EdgeInsets.all(10.w),
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
                TextFormField(
                  // controller: emailField,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                      color: colorLightYellow, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Username',
                    filled: true,
                    fillColor: colorMediumBlue,
                    hintStyle: TextStyle(color: colorLightGrey),
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(
                      Icons.person,
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
                        style: TextStyle(color: colorLightYellow, fontSize: 20),
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
