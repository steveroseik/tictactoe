import 'package:animated_button/animated_button.dart';
import 'package:crypto/crypto.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:motion/motion.dart';
import 'package:neopop/neopop.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simple_animated_button/elevated_layer_button.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Authentication/authentication.dart';
import 'package:tictactoe/Controllers/mainController.dart';
import 'package:tictactoe/UIUX/themesAndStyles.dart';
import 'package:tictactoe/UIUX/customWidgets.dart';
import 'package:tictactoe/routesGenerator.dart';

import 'UIUX/customWidgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

List<(String, String)> routes = [
  (Routes.classicGameModeSelect, 'CLASSIC GAME'),
  (Routes.experimentalGameMain, 'NINE X NINE'),
  (Routes.experimentalGameMain2, 'BIG GRID'),
  (Routes.experimentalGameMain3, 'FOURTH DIMENSION')
];

class _HomePageState extends State<HomePage> {
  late SpriteAnimation spriteAnimation;
  late SpriteAnimationComponent planetA;
  late SpriteAnimationTicker ticker;

  late MainController dataEngine;

  int currentModePage = 0;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dataEngine = context.watch<MainController>();
    return Scaffold(
      body: Stack(
        children: [
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 10.h,
              ),
              Motion.only(
                child: SizedBox(
                  width: 30.w,
                  child: Image.asset('assets/LOGO.png'),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: AnimatedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 25,
                            ),
                            Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 25,
                            ),
                            Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 25,
                            ),
                          ],
                        ),
                        onPressed: () {},
                        height: 45,
                        width: 100,
                        color: Colors.purple,
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: AnimatedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: Colors.white,
                              size: 25,
                            ),
                            Text('1000')
                          ],
                        ),
                        onPressed: () {},
                        height: 45,
                        width: 120,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: AnimatedButton(
                            child: Icon(
                              Icons.group,
                              color: Colors.white,
                              size: 25,
                            ),
                            onPressed: () {},
                            height: 50,
                            width: 50,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(
                          height: 1.h,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: AnimatedButton(
                            child: Icon(
                              Icons.group,
                              color: Colors.white,
                              size: 25,
                            ),
                            onPressed: () async{

                              final token = await Authentication().getFacebookAccessToken();
                              print(token?.token);
                              final friends = await Authentication().getFacebookFriends(token: token!.token);
                              print(friends[0]);
                            },
                            height: 50,
                            width: 50,
                            color: Colors.orangeAccent,
                          ),
                        ),
                        SizedBox(
                          height: 1.h,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: AnimatedButton(
                            child: Icon(
                              Icons.group,
                              color: Colors.white,
                              size: 25,
                            ),
                            onPressed: () {},
                            height: 50,
                            width: 50,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                    InkWell(
                      onTap: (){
                        Navigator.of(context).pushNamed(Routes.classicGameMain);
                      },
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorPurple,
                            border: Border.all(
                                strokeAlign: BorderSide.strokeAlignOutside,
                                color: colorPurple.withOpacity(0.4), width: 5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Center(
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Icon(
                                        Icons.multiple_stop_rounded,
                                        color: Colors.black,
                                        size: 80,
                                      ),
                                      Text(
                                        "Online Multiplayer",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 26.0,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: NeoPopShimmer(
                                      shimmerColor: Colors.purpleAccent.shade200.withOpacity(0.8),
                                      duration: const Duration(milliseconds: 1500),
                                      delay: const Duration(milliseconds: 2000),
                                      child:Container()
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 0.5.h,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedButton(
                    child: Text(
                      'Tournaments', // add your text here
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    color: Colors.orange,
                    width: 300,
                    onPressed: () {
                      Navigator.of(context).pushNamed(Routes.tournamentsHome);
                    },
                  ),
                  SizedBox(
                    height: 2.h,
                  ),

                  GameButton(
                    onPressed: () {
                      print('tapped');
                    },
                    borderRadius: BorderRadius.circular(15),
                    aspectRatio: 4/1,
                    width: 70.w,
                    baseDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.green.shade800, colorDarkBlue]
                        )
                    ),
                    topDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.green, colorDarkBlue]
                        )
                    ),
                    child: const Center(
                      child: Text(
                        'sdsds', // add your text here
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  WinButton(disconnected: false),
                  // LoseButton(),
                  // DrawButton(),
                ],
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      AnimatedButton(
                        child: Text(
                          'Characters', // add your text here
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        width: 100,
                        onPressed: () {},
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: AnimatedButton(
                          child: Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 25,
                          ),
                          onPressed: () {
                            dataEngine.signOut();
                          },
                          height: 50,
                          width: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
