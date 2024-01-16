import 'package:animated_button/animated_button.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Controllers/mainController.dart';
import 'package:tictactoe/UIUX/customWidgets.dart';
import 'package:tictactoe/UIUX/themesAndStyles.dart';
import 'package:tictactoe/routesGenerator.dart';
import 'package:tictactoe/spritesConfigurations.dart';

import '../Authentication/authentication.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

List<(String, String)> routes = [
  (Routes.classicGameModeSelect, 'CLASSIC GAME'),
  (Routes.ninesGameMain, 'NINE X NINE'),
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
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: AnimatedButton(
                        color: Colors.purple,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.monetization_on,
                                color: Colors.white,
                                size: 27,
                              ),
                              Spacer(),
                              Text('100',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white)),
                              Spacer(),
                              Icon(
                                Icons.add_circle_outlined,
                                color: Colors.white,
                                size: 27,
                              ),
                            ],
                          ),
                        ),
                        onPressed: () {},
                        height: 45,
                        width: 105,
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: AnimatedButton(
                        color: Colors.green,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.monetization_on,
                                color: Colors.white,
                                size: 27,
                              ),
                              Spacer(),
                              Text('100',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white)),
                              Spacer(),
                              Icon(
                                Icons.add_circle_outlined,
                                color: Colors.white,
                                size: 27,
                              ),
                            ],
                          ),
                        ),
                        onPressed: () {},
                        height: 45,
                        width: 105,
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: AnimatedButton(
                        color: Colors.blue,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              AspectRatio(
                                  aspectRatio: 1,
                              child: Sprites.coinOf[Coins.bronze],),
                              Text('100',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white)),
                              Icon(
                                Icons.add_circle_outlined,
                                color: Colors.white,
                                size: 27,
                              ),
                            ],
                          ),
                        ),
                        onPressed: () {},
                        height: 45,
                        width: 105,
                      ),
                    ),
                    Spacer(),
                    AnimatedButton(
                        onPressed: () {},
                        width: 45,
                        height: 45,
                        color: Colors.yellow.shade800,
                        child: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.settings,
                              color: Colors.white,
                              shadows: [
                                Shadow(color: Colors.yellow, blurRadius: 30)
                              ],
                            ))),
                  ],
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GameButton2(
                      onPressed: () {},
                      borderRadius: BorderRadius.circular(10),
                      aspectRatio: 1.5 / 1,
                      width: 20.w,
                      baseDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: colorDarkBlue,
                      ),
                      topDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.lightBlueAccent,
                                Colors.lightBlue
                              ])),
                      child: Column(children: [
                        Expanded(
                            flex: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                    Colors.deepPurple,
                                    Colors.purple.shade800,
                                  ])),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.leaderboard_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ])),
                  SizedBox(
                    width: 1.h,
                  ),
                  GameButton2(
                      onPressed: () async {
                        final token =
                            await Authentication().getFacebookAccessToken();
                        print(token?.token);
                        final friends = await Authentication()
                            .getFacebookFriends(token: token!.token);
                        print(friends[0]);
                      },
                      borderRadius: BorderRadius.circular(10),
                      aspectRatio: 1.5 / 1,
                      width: 20.w,
                      baseDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: colorDarkBlue,
                      ),
                      topDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.lightBlueAccent,
                                Colors.lightBlue
                              ])),
                      child: Column(children: [
                        Expanded(
                            flex: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                    Colors.lightBlueAccent,
                                    Colors.lightBlue
                                  ])),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.group,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ])),
                  SizedBox(
                    width: 1.h,
                  ),
                  GameButton2(
                      onPressed: () {
                        // Navigator.of(context).pushNamed(Routes.s);
                      },
                      borderRadius: BorderRadius.circular(10),
                      aspectRatio: 1.5 / 1,
                      width: 20.w,
                      baseDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: colorDarkBlue,
                      ),
                      topDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.lightBlueAccent,
                                Colors.lightBlue
                              ])),
                      child: Column(children: [
                        Expanded(
                            flex: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                    Colors.green,
                                    Colors.green.shade800,
                                  ])),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ])),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GameButton2(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(Routes.classicGameMain);
                        },
                        borderRadius: BorderRadius.circular(10),
                        aspectRatio: 1.5 / 1,
                        width: 70.w,
                        baseDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: colorDarkBlue,
                        ),
                        topDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.lightBlueAccent,
                                  Colors.lightBlue
                                ])),
                        child: Column(children: [
                          Expanded(
                              flex: 10,
                              child: Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                      Colors.purple,
                                      Colors.purple.shade800,
                                    ])),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 2, 8, 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.play_arrow_rounded,
                                              size: 120, color: Colors.white),
                                          Text(
                                            'Online Multiplayer', // add your text here
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 25,
                                            ),
                                            textAlign: TextAlign.end,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ])),

                    // Card(
                    //   elevation: 10,
                    //   shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(20)),
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       color: colorPurple,
                    //       border: Border.all(
                    //           strokeAlign: BorderSide.strokeAlignOutside,
                    //           color: colorPurple.withOpacity(0.4),
                    //           width: 5),
                    //       borderRadius: BorderRadius.circular(20),
                    //     ),
                    //     child: Stack(
                    //       children: [
                    //         Padding(
                    //           padding: EdgeInsets.symmetric(
                    //               horizontal: 20, vertical: 10),
                    //           child: Center(
                    //             child: const Column(
                    //               mainAxisAlignment:
                    //                   MainAxisAlignment.spaceAround,
                    //               children: [
                    //                 Icon(
                    //                   Icons.multiple_stop_rounded,
                    //                   color: Colors.black,
                    //                   size: 80,
                    //                 ),
                    //                 Text(
                    //                   "Online Multiplayer",
                    //                   style: TextStyle(
                    //                     color: Colors.black,
                    //                     fontSize: 26.0,
                    //                   ),
                    //                 )
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //         Positioned.fill(
                    //           child: ClipRRect(
                    //             borderRadius: BorderRadius.circular(20),
                    //             child: NeoPopShimmer(
                    //                 shimmerColor: Colors.purpleAccent.shade200
                    //                     .withOpacity(0.8),
                    //                 duration:
                    //                     const Duration(milliseconds: 1500),
                    //                 delay: const Duration(milliseconds: 2000),
                    //                 child: Container()),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              SizedBox(
                height: 0.5.h,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 2.h,
                  ),
                  GameButton2(
                      onPressed: () {
                        print('tapped');
                      },
                      borderRadius: BorderRadius.circular(10),
                      aspectRatio: 4 / 1,
                      width: 70.w,
                      baseDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: colorDarkBlue,
                      ),
                      topDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.lightBlueAccent,
                                Colors.lightBlue
                              ])),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                flex: 10,
                                child: ClipRRect(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                          colorDarkBlue,
                                          Colors.blue.shade800,
                                        ])),
                                    child: NeoPopShimmer(
                                      shimmerColor: colorLightGrey.withOpacity(0.8),
                                      duration: const Duration(milliseconds: 1500),
                                      delay: const Duration(milliseconds: 2000),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.fromLTRB(4, 2, 4, 2),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Tournaments', // add your text here
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.start,
                                            ),
                                            Spacer(),
                                            Text(
                                              'Time Left: 2h 6m 32s', // add your text here
                                              style: TextStyle(
                                                color: Colors.yellow,
                                              ),
                                              textAlign: TextAlign.end,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                              flex: 10,
                              child: Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                      Colors.lightBlue,
                                      Colors.lightBlue.shade800,
                                    ])),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.white,
                                      ),
                                      Spacer(),
                                      Text(
                                        'Battle Royale!', // add your text here
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 25,
                                        ),
                                        textAlign: TextAlign.end,
                                      )
                                    ],
                                  ),
                                ),
                              )),
                        ]),
                      )),
                  SizedBox(
                    height: 2.h,
                  ),
                  GameButton2(
                      onPressed: () {
                        print('tapped');
                      },
                      borderRadius: BorderRadius.circular(10),
                      aspectRatio: 4 / 1,
                      width: 70.w,
                      baseDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: colorDarkBlue,
                      ),
                      topDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.lightBlueAccent,
                                Colors.lightBlue
                              ])),
                      child: Column(children: [
                        Expanded(
                            flex: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                    Colors.lightGreen,
                                    Colors.lightGreen.shade800,
                                  ])),
                              child: NeoPopShimmer(
                                shimmerColor: Colors.yellow.withOpacity(0.8),
                                duration: const Duration(milliseconds: 1500),
                                delay: const Duration(milliseconds: 2000),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 2, 8, 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Play With Friends', // add your text here
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 25,
                                        ),
                                        textAlign: TextAlign.end,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )),
                      ])),
                  SizedBox(
                    height: 2.h,
                  ),
                  //CarouselSlider(items: items, options: options),
                  SizedBox(
                    height: 2.h,
                  ),

                  // GameButton(
                  //   onPressed: () {
                  //     print('tapped');
                  //   },
                  //   borderRadius: BorderRadius.circular(15),
                  //   aspectRatio: 4 / 1,
                  //   width: 70.w,
                  //   baseDecoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(15),
                  //       gradient: LinearGradient(
                  //           begin: Alignment.topLeft,
                  //           end: Alignment.bottomRight,
                  //           colors: [Colors.green.shade800, colorDarkBlue])),
                  //   topDecoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(15),
                  //       gradient: const LinearGradient(
                  //           begin: Alignment.topLeft,
                  //           end: Alignment.bottomRight,
                  //           colors: [Colors.green, colorDarkBlue])),
                  //   child: const Center(
                  //     child: Text(
                  //       'Challenges', // add your text here
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //       ),
                  //       textAlign: TextAlign.center,
                  //     ),
                  //   ),
                  // ),
                  // WinButton(disconnected: false),
                  // LoseButton(),
                  // DrawButton(),
                ],
              ),
              Spacer(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      // AnimatedButton(
                      //   child: Text(
                      //     'Characters', // add your text here
                      //     style: TextStyle(
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      //   width: 100,
                      //   onPressed: () {},
                      // ),
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
