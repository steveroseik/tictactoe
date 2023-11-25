import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:motion/motion.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Controllers/dataEngine.dart';
import 'package:tictactoe/UIUX/themesAndStyles.dart';
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
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  Colors.deepOrange,
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
                Motion.only(
                  child: SizedBox(
                    width: 60.w,
                    child: Image.asset('assets/LOGO.png'),
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                CarouselSlider.builder(
                  itemCount: routes.length,
                  options: CarouselOptions(
                    height: 42.h,
                    viewportFraction: 0.7,
                    animateToClosest: true,
                    scrollDirection: Axis.horizontal,
                    enlargeFactor: 0.2,
                    enableInfiniteScroll: true,
                    enlargeCenterPage: true,
                    onPageChanged: (changedInd, reason){
                      setState(() {
                        currentModePage = changedInd;
                      });
                    }
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
                    return Container(
                      padding: EdgeInsets.all(2.h),
                      child: Motion(
                        shadow: null,
                        glare: (index != currentModePage) ? null : const GlareConfiguration(),
                        translation: (index != currentModePage) ? const TranslationConfiguration(
                          maxOffset: Offset.zero
                        )
                            : const TranslationConfiguration(),
                        borderRadius: BorderRadius.circular(12.w),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(routes[index].$1);
                          },
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            height: 38.h,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.w),
                                color: colorDarkBlue),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  height: 32.h,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.w),
                                      child: Image.asset(
                                        path,
                                        fit: BoxFit.cover,
                                      )),
                                ),
                                Flexible(
                                  child: Text(
                                    routes[index].$2,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13.sp,
                                        color: Colors.white.withOpacity(0.8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/characters');
                            },
                            child: const Text('Characters')),
                        const Spacer(),
                        IconButton(onPressed: (){
                          dataEngine.signOut();
                        },
                            style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.deepPurple
                            ),
                            icon: Icon(Icons.logout,)),
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
