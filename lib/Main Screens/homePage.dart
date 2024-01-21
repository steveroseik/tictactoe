import 'package:animated_button/animated_button.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Controllers/mainController.dart';
import 'package:tictactoe/UIUX/customWidgets.dart';
import 'package:tictactoe/UIUX/themesAndStyles.dart';
import 'package:tictactoe/routesGenerator.dart';
import 'package:tictactoe/spritesConfigurations.dart';

import '../Authentication/authentication.dart';
import '../Configurations/constants.dart';

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

  CarouselController gameModesController = CarouselController();
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
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                SizedBox(
                  height: 26.h,
                ),
                CarouselSlider(
                  carouselController: gameModesController,
                  options: CarouselOptions(
                    viewportFraction: 0.8,
                    aspectRatio: 16 / 10,
                    enlargeFactor: 0.25,
                    enlargeCenterPage: true,
                    clipBehavior: Clip.none,
                    onPageChanged: (index, reason) {
                      setState(() {
                        currentModePage = index;
                      });
                    },
                  ),
                  items: [...gameModeItems()],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                      3,
                      (index) => GestureDetector(
                            onTap: () =>
                                gameModesController.animateToPage(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: currentModePage == index ? 12.0 : 9.0,
                              height: currentModePage == index ? 12.0 : 9.0,
                              margin: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black)
                                      .withOpacity(currentModePage == index
                                          ? 0.9
                                          : 0.4)),
                            ),
                          )),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GameButton2(
                        onPressed: () {
                          Navigator.of(context).pushNamed(Routes.tournamentsHome);
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
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
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
                                        shimmerColor: colorLightGrey
                                            .withOpacity(0.8),
                                        duration: const Duration(
                                            milliseconds: 1500),
                                        delay: const Duration(
                                            milliseconds: 2000),
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.fromLTRB(
                                              10, 2, 10, 2),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Tournaments', // add your text here
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                                textAlign:
                                                TextAlign.start,
                                              ),
                                              Spacer(),
                                              Text(
                                                'Active: 63', // add your text here
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
                                    padding: const EdgeInsets.fromLTRB(
                                        8, 2, 8, 2),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.white,
                                        ),
                                        Spacer(),
                                        Text(
                                          'Daily Tournament!', // add your text here
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
                    SizedBox(height: 1.h),
                    GameButton(
                        onPressed: () {
                          print('tapped');
                        },
                        enableShimmer: false,
                        borderRadius: BorderRadius.circular(10),
                        aspectRatio: 4 / 1,
                        width: 70.w,
                        baseDecoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                            Colors.lightGreen.shade600,
                            Colors.lightGreen.shade900,
                            ]
                          )
                        ),
                        topDecoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.lightGreen,
                                  Colors.lightGreen.shade800,
                                ]
                            )
                        ),
                        child: const Center(
                          child: Text(
                            'Play With Friends', // add your text here
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        )),
                    SizedBox(height: 1.h),
                    GameButton2(
                        onPressed: () {
                          print('tapped');
                        },
                        borderRadius: BorderRadius.circular(10),
                        aspectRatio: 6 / 3,
                        width: 80.w,
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
                                                Colors.orange,
                                                Colors.orange.shade800,
                                              ])),
                                      child: NeoPopShimmer(
                                        shimmerColor:
                                        colorPurple.withOpacity(0.8),
                                        duration: const Duration(
                                            milliseconds: 1500),
                                        delay: const Duration(
                                            milliseconds: 2000),
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.fromLTRB(
                                              10, 2, 10, 2),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Challenges', // add your text here
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.start,
                                              ),
                                              Spacer(),
                                              Text(
                                                '2/5 Complete!', // add your text here
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
                                            Colors.yellow.shade600,
                                            Colors.yellow.shade800,
                                          ])),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Win 5 matches in a row', // add your text here
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 25,
                                          shadows: [
                                            Shadow(
                                                color: Colors.black.withOpacity(0.4),
                                              blurRadius: 10,
                                            )
                                          ]
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      // Text(
                                      //   'Reward:',
                                      //   style: TextStyle(
                                      //       color: Colors.white,
                                      //       fontSize: 20),
                                      //   textAlign: TextAlign.start,
                                      // ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 20),
                                        decoration: BoxDecoration(
                                            color: Colors.orange.shade800,
                                            borderRadius:
                                            BorderRadius.circular(
                                                20)),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 5.h,
                                              padding: EdgeInsets.all(3.w),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  AspectRatio(
                                                    aspectRatio: 1,
                                                    child: Sprites.coinOf[
                                                    Coins.bronze],
                                                  ),
                                                  SizedBox(
                                                    width: 1.w,
                                                  ),
                                                  Text(
                                                    '50',
                                                    style: TextStyle(
                                                        color:
                                                        Colors.white,
                                                      fontSize: 20
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 5.h,
                                              padding:
                                              EdgeInsets.all(3.w),
                                              child: Row(
                                                children: [
                                                  AspectRatio(
                                                    aspectRatio: 1,
                                                    child: Sprites.coinOf[
                                                    Coins.silver],
                                                  ),
                                                  SizedBox(
                                                    width: 1.w,
                                                  ),
                                                  Text(
                                                    '25',
                                                    style: TextStyle(
                                                        color:
                                                        Colors.white,
                                                        fontSize: 20),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 5.h,
                                              padding:
                                              EdgeInsets.all(3.w),
                                              child: Row(
                                                children: [
                                                  AspectRatio(
                                                    aspectRatio: 1,
                                                    child: Sprites.coinOf[
                                                    Coins.gold],
                                                  ),
                                                  SizedBox(
                                                    width: 1.w,
                                                  ),
                                                  Text(
                                                    '10',
                                                    style: TextStyle(
                                                        color:
                                                        Colors.white,
                                                        fontSize: 20),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: List<Widget>.generate(
                                            3,
                                                (index) => GestureDetector(
                                              onTap: () =>
                                                  gameModesController
                                                      .animateToPage(
                                                      index),
                                              child:
                                              AnimatedContainer(
                                                duration:
                                                const Duration(
                                                    milliseconds:
                                                    300),
                                                width:
                                                currentModePage ==
                                                    index
                                                    ? 8.0
                                                    : 5.0,
                                                height:
                                                currentModePage ==
                                                    index
                                                    ? 8.0
                                                    : 5.0,
                                                margin: EdgeInsets
                                                    .symmetric(
                                                    vertical: 8.0,
                                                    horizontal:
                                                    4.0),
                                                decoration: BoxDecoration(
                                                    shape: BoxShape
                                                        .circle,
                                                    color: (Theme.of(context)
                                                        .brightness ==
                                                        Brightness
                                                            .dark
                                                        ? Colors
                                                        .white
                                                        : Colors
                                                        .black)
                                                        .withOpacity(
                                                        currentModePage ==
                                                            index
                                                            ? 0.9
                                                            : 0.4)),
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                )),
                          ]),
                        )),
                  ],
                ),
                SizedBox(
                  height: 2.h,
                ),
              ],
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [...gameCoinList()],
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GameButton(
                          onPressed: (){},
                          width: 12.w,
                          aspectRatio: 1,
                          borderRadius: BorderRadius.circular(10),
                          baseDecoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.indigo.shade700,
                                    Colors.indigo.shade900
                                  ]
                              )
                          ),
                          topDecoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.indigo,
                                    Colors.indigo.shade400
                                  ]
                              )
                          ),
                          enableShimmer: false,
                          child:  Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                        ),

                        Container(
                          width: 12.w,
                          height: 12.w,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.black,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.deepPurple.shade900,
                                      colorPurple
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: colorDarkBlue.withOpacity(0.3),
                                        offset: Offset(3, 3),
                                        spreadRadius: 1,
                                        blurRadius: 3)
                                  ],
                                ),
                              ),
                              Positioned(
                                  top: -15,
                                  child: SizedBox(
                                      height: 14.w,
                                      child: Image.asset('assets/trophy.png'))),
                            ],
                          ),
                        ),
                        Container(
                          width: 12.w,
                          height: 12.w,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.black,
                                    gradient: LinearGradient(
                                        colors: [
                                          Colors.deepPurple.shade900,
                                          colorPurple
                                        ]
                                    ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: colorDarkBlue.withOpacity(0.3),
                                        offset: Offset(3, 3),
                                        spreadRadius: 1,
                                        blurRadius: 3)
                                  ],
                                ),
                              ),
                              Positioned(
                                  top: -13,
                                  child: SizedBox(
                                      height: 12.w,
                                      child: Image.asset('assets/friends.png'))),
                            ],
                          ),
                        ),
                        Container(
                          width: 12.w,
                          height: 12.w,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.black,
                                    gradient: LinearGradient(
                                        colors: [
                                          Colors.deepPurple.shade900,
                                          colorPurple
                                        ]
                                    ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: colorDarkBlue.withOpacity(0.3),
                                        offset: Offset(3, 3),
                                        spreadRadius: 1,
                                        blurRadius: 3)
                                  ],
                                ),
                              ),
                              Positioned(
                                  top: -10,
                                  child: SizedBox(
                                      height: 12.w,
                                      child: Image.asset('assets/shop-bag.png'))),
                            ],
                          ),
                        ),
                        GameButton(
                          onPressed: () => dataEngine.signOut(),
                          width: 12.w,
                          aspectRatio: 1,
                          borderRadius: BorderRadius.circular(10),
                          baseDecoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.black,
                                    Colors.black
                                  ]
                              )
                          ),
                          topDecoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.red,
                                    Colors.black
                                  ]
                              )
                          ),
                          enableShimmer: false,
                          child:  Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> gameModeItems() {
    return [
      gameModeWidget(
        imgPath: 'assets/classic.png',
        imgWidth: 50.w,
        gameMode: GameMode.classicSingle
      ),
      gameModeWidget(
        imgPath: 'assets/9x9.png',
        imgWidth: 30.w,
          gameMode: GameMode.nineSingle
      ),
      gameModeWidget(
        imgPath: 'assets/powers.png',
        imgWidth: 50.w,
          gameMode: GameMode.powersSingle
      ),
    ];
  }

  gameModeWidget({
    required String imgPath,
    required double imgWidth,
    required GameMode gameMode,
    EdgeInsets? containerPadding,
  }) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: containerPadding ?? EdgeInsets.all(3.w),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: colorDarkBlue.withOpacity(0.3),
                      offset: Offset(3, 3),
                      spreadRadius: 1,
                      blurRadius: 3)
                ],
                gradient: LinearGradient(
                    colors: [colorDarkBlue.withOpacity(0.5), Colors.black])),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Sprites.badgeOf[Badges.rookie],
                      ),
                    ),
                    Flexible(
                      flex: 7,
                      child: LinearPercentIndicator(
                        percent: 0.5,
                        backgroundColor: Colors.blueGrey.shade700,
                        barRadius: const Radius.circular(20),
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Sprites.badgeOf[Badges.apprentice],
                      ),
                    ),
                  ],
                ),
                GameButton(
                    onPressed: () {
                      switch(gameMode){
                        case GameMode.classicSingle:
                          Navigator.of(context).pushNamed(Routes.classicGameMain);
                          break;
                        case GameMode.nineSingle:
                          Navigator.of(context).pushNamed(Routes.ninesGameMain);
                          break;
                        case GameMode.powersSingle:
                          Navigator.of(context).pushNamed(Routes.powersCharacterSelect);
                          break;
                        default: return null;
                      }
                    },
                    baseDecoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.deepPurple.shade800,
                        Colors.deepPurple.shade900.withOpacity(0.4),
                      ]),
                    ),
                    topDecoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.deepPurple,
                        Colors.deepPurple.shade900
                      ]),
                    ),
                    borderRadius: BorderRadius.circular(10),
                    aspectRatio: 5 / 1,
                    width: 98.w,
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(3),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(1.w),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Sprites.badgeOf[Badges.apprentice],
                              ),
                            ),
                            Text(
                              'Tiered Match',
                              style: TextStyle(fontSize: 20),
                            ),
                            Spacer(),
                            Text('1000'),
                            Container(
                              height: 6.h,
                              padding: EdgeInsets.all(3.w),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Sprites.coinOf[Coins.silver],
                              ),
                            )
                          ],
                        ),
                      ),
                    )),
                GameButton(
                    onPressed: () {},
                    enableShimmer: false,
                    baseDecoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.deepPurple.shade900,
                        Colors.black
                      ]),
                    ),
                    topDecoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.black,
                        Colors.deepPurple.shade900,
                      ]),
                    ),
                    borderRadius: BorderRadius.circular(10),
                    aspectRatio: 6 / 1,
                    width: 98.w,
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            Text('Random Match'),
                            Spacer(),
                            Text('500'),
                            Container(
                              padding: EdgeInsets.all(3.w),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Sprites.coinOf[Coins.bronze],
                              ),
                            )
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
          Positioned(
              top: -40,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  imgPath,
                  width: imgWidth,
                ),
              )),
        ],
      ),
    );
  }

  List<Widget> gameCoinList() {
    return List.from(Coins.values.map((e) => coinWidget(coin: e, scale: 1.2)));
  }

  Widget coinWidget({
    required Coins coin,
    double? scale,
  }) {
    return Transform(
      transform: Matrix4.identity()..scale(scale ?? 1),
      child: SizedBox(
        width: 20.w,
        child: AspectRatio(
          aspectRatio: 3 / 1,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.passthrough,
            children: [
              Container(
                width: 20.w,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.black, Colors.deepPurple.shade900]),
                    boxShadow: [
                      BoxShadow(
                          color: colorDarkBlue.withOpacity(0.3),
                          offset: Offset(3, 3),
                          spreadRadius: 1,
                          blurRadius: 3)
                    ],
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.only(left: 20),
                child: Center(
                  child: Text(
                    '100',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(1.5),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset(Sprites.staticCoinOf[coin]!),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
