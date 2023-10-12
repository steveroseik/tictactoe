import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/UIUX/themesAndStyles.dart';
import 'package:tictactoe/routesGenerator.dart';

class GameModeSelectPage extends StatefulWidget {
  const GameModeSelectPage({super.key});

  @override
  State<GameModeSelectPage> createState() => _GameModeSelectPageState();
}

class _GameModeSelectPageState extends State<GameModeSelectPage> {
  late SpriteAnimation spriteAnimation;
  late SpriteAnimationComponent planetA;
  late SpriteAnimationTicker ticker;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
    super.initState();
  }

  List<(String, String)> routes = [
    (Routes.classicGameModeSelect, 'CLASSIC GAME'),
    (Routes.experimentalGameMain, 'NINE X NINE'),
    (Routes.experimentalGameMain2, 'BIG GRID'),
    (Routes.experimentalGameMain3, 'FOURTH DIMENSION')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  Colors.deepOrange.shade300,
                  Colors.deepPurple.shade800
                ])),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 10.h,
                ),
                SizedBox(
                  height: 17.h,
                  child: Image.asset('assets/LOGO.png'),
                ),
                SizedBox(
                  height: 5.h,
                ),
                CarouselSlider.builder(
                  itemCount: routes.length,
                  options: CarouselOptions(
                    height: 40.h,
                    viewportFraction: 0.7,
                    animateToClosest: true,
                    scrollDirection: Axis.horizontal,
                    enlargeFactor: 0.2,
                    enableInfiniteScroll: true,
                    enlargeCenterPage: true,
                  ),
                  itemBuilder:
                      (BuildContext context, int index, int realIndex) {
                    String path = 'assets/images/';
                    switch (index) {
                      case 0:
                        path += 'tournaments.png';
                        break;
                      case 1:
                        path += 'ninegame.png';
                        break;
                      case 2:
                        path += 'biggrid.jpg';
                        break;
                      case 3:
                        path += 'fourDimension.png';
                        break;
                    }
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(routes[index].$1);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height:30.h,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.w),
                                child: Image.asset(
                                  path,
                                  fit: BoxFit.cover,
                                )),
                          ),
                          // GlassContainer(
                          //   borderRadius: BorderRadius.circular(15.w),
                          //   blur: 2,
                          //   color: Colors.purple.withOpacity(0.1),
                          // ),
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.w),
                                color: colorDarkBlue),
                            child: FittedBox(
                              child: Text(
                                routes[index].$2,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white.withOpacity(0.8)),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
                const Spacer(),
                SafeArea(
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/characters');
                      },
                      child: const Text('Characters')),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
