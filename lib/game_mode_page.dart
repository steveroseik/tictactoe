import 'package:button_animations/button_animations.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:motion/motion.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Controllers/dataEngine.dart';
import 'package:tictactoe/UIUX/customWidgets.dart';
import 'package:tictactoe/routesGenerator.dart';

class GameModeSelectPage extends StatefulWidget {
  const GameModeSelectPage({super.key});

  @override
  State<GameModeSelectPage> createState() => _GameModeSelectPageState();
}

List<(String, String)> routes = [
  (Routes.classicGameModeSelect, 'CLASSIC GAME'),
  (Routes.experimentalGameMain, 'NINE X NINE'),
  (Routes.experimentalGameMain2, 'BIG GRID'),
  (Routes.experimentalGameMain3, 'FOURTH DIMENSION')
];

class _GameModeSelectPageState extends State<GameModeSelectPage> {
  late SpriteAnimation spriteAnimation;
  late SpriteAnimationComponent planetA;
  late SpriteAnimationTicker ticker;

  late DataEngine dataEngine;

  int currentModePage = 0;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dataEngine = context.watch<DataEngine>();
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.deepPurple, Colors.deepPurple.shade800])),
          ),
          Center(
            child: Column(
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
                          onTap: () {},
                          type: null,
                          height: 45,
                          width: 100,
                          borderRadius: 22.5,
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
                          onTap: () {},
                          type: null,
                          height: 45,
                          width: 120,
                          borderRadius: 22.5,
                          color: Colors.green[800],
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
                              onTap: () {},
                              type: null,
                              height: 50,
                              width: 50,
                              borderRadius: 5,
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
                              onTap: () {},
                              type: null,
                              height: 50,
                              width: 50,
                              borderRadius: 5,
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
                              onTap: () {},
                              type: null,
                              height: 50,
                              width: 50,
                              borderRadius: 5,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 4.w,
                      ),
                      Motion.only(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: AnimatedButton(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 120,
                                ),
                                Text(
                                  "ONLINE",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26.0,
                                  ),
                                )
                              ],
                            ),
                            onTap: () {},
                            type: null,
                            height: 180,
                            isOutline: true,
                            shadowHeightBottom: 8,
                            width: 250,
                            color: Colors.red,
                            borderWidth: 2,
                          ),
                        ),
                      ),
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
                      type: null,
                      width: 300,
                      darkShadow: false,
                      isOutline: true,
                      borderWidth: 2,
                      onTap: () {},
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    AnimatedButton(
                      child: Text(
                        'Challenges', // add your text here
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      width: 300,
                      darkShadow: false,
                      isOutline: true,
                      borderWidth: 2,
                      onTap: () {},
                    ),
                    WinButton(disconnected: true),
                    LoseButton(),
                    DrawButton(),
                  ],
                ),

                // Container(
                //   child: Container(
                //     width: 60.w,
                //     child: Image.asset('assets/characters/all-01.png'),
                //   ),
                // ),
                // const Spacer(),
                // CarouselSlider.builder(
                //   itemCount: routes.length,
                //   options: CarouselOptions(
                //       height: 30.h,
                //       autoPlay: true,
                //       autoPlayInterval: Duration(seconds: 3),
                //       autoPlayAnimationDuration: Duration(milliseconds: 800),
                //       autoPlayCurve: Curves.fastOutSlowIn,
                //       viewportFraction: 0.6,
                //       animateToClosest: true,
                //       scrollDirection: Axis.horizontal,
                //       enlargeFactor: 0.2,
                //       enableInfiniteScroll: true,
                //       enlargeCenterPage: true,
                //       onPageChanged: (changedInd, reason) {
                //         setState(() {
                //           currentModePage = changedInd;
                //         });
                //       }),
                //   itemBuilder:
                //       (BuildContext context, int index, int realIndex) {
                //     String path = 'assets/images/';
                //     switch (index) {
                //       case 0:
                //         path += 'tournaments.png';
                //         break;
                //       case 1:
                //         path += 'ninegame.png';
                //         break;
                //       case 2:
                //         path += 'biggrid.jpg';
                //         break;
                //       case 3:
                //         path += 'fourDimension.png';
                //         break;
                //     }
                //     return Container(
                //       padding: EdgeInsets.all(2.h),
                //       child: Motion(
                //         shadow: null,
                //         glare: (index != currentModePage)
                //             ? null
                //             : const GlareConfiguration(),
                //         translation: (index != currentModePage)
                //             ? const TranslationConfiguration(
                //                 maxOffset: Offset.zero)
                //             : const TranslationConfiguration(),
                //         borderRadius: BorderRadius.circular(12.w),
                //         child: GestureDetector(
                //           onTap: () {
                //             Navigator.of(context).pushNamed(routes[index].$1);
                //           },
                //           child: Container(
                //             padding: EdgeInsets.all(2.w),
                //             height: 24.h,
                //             decoration: BoxDecoration(
                //                 borderRadius: BorderRadius.circular(12.w),
                //                 color: colorDarkBlue),
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.spaceAround,
                //               children: [
                //                 SizedBox(
                //                   height: 19.h,
                //                   child: ClipRRect(
                //                       borderRadius: BorderRadius.circular(10.w),
                //                       child: Image.asset(
                //                         path,
                //                         fit: BoxFit.cover,
                //                       )),
                //                 ),
                //                 Flexible(
                //                   child: Text(
                //                     routes[index].$2,
                //                     style: TextStyle(
                //                         fontWeight: FontWeight.w900,
                //                         fontSize: 10.sp,
                //                         color: Colors.white.withOpacity(0.8)),
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //     );
                //   },
                // ),
                Spacer(),
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
                          darkShadow: false,
                          isOutline: true,
                          borderWidth: 2,
                          onTap: () {},
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
                            onTap: () {},
                            type: null,
                            height: 50,
                            width: 50,
                            borderRadius: 22.5,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
