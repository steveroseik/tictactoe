import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/UIUX/customWidgets.dart';
import 'package:tictactoe/spritesConfigurations.dart';

import '../Authentication/sessionProvider.dart';
import '../UIUX/themesAndStyles.dart';

class storeHome extends StatefulWidget {
  const storeHome({Key? key}) : super(key: key);

  @override
  State<storeHome> createState() => _storeHomeState();
}

class _storeHomeState extends State<storeHome> {
  late SessionProvider dataEngine;

  @override
  Widget build(BuildContext context) {
    dataEngine = context.watch<SessionProvider>();
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                SizedBox(
                  height: 26.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                            Expanded(
                                flex: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                        Colors.purple.shade600,
                                        Colors.purple.shade800,
                                      ])),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 10.h,
                                            padding: EdgeInsets.all(3.w),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                AspectRatio(
                                                  aspectRatio: 1,
                                                  child: Sprites
                                                      .coinOf[Coins.gold],
                                                ),
                                                SizedBox(
                                                  width: 1.w,
                                                ),
                                                Text(
                                                  '10',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20),
                                                  textAlign: TextAlign.center,
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: 8.h,
                                            padding: EdgeInsets.all(3.w),
                                            child: Row(
                                              children: [
                                                AspectRatio(
                                                  aspectRatio: 1,
                                                  child: Sprites
                                                      .coinOf[Coins.silver],
                                                ),
                                                SizedBox(
                                                  width: 1.w,
                                                ),
                                                Text(
                                                  '25',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: 6.h,
                                            padding: EdgeInsets.all(3.w),
                                            child: Row(
                                              children: [
                                                AspectRatio(
                                                  aspectRatio: 1,
                                                  child: Sprites
                                                      .coinOf[Coins.bronze],
                                                ),
                                                SizedBox(
                                                  width: 1.w,
                                                ),
                                                Text(
                                                  '50',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
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
                                            Colors.white,
                                            Colors.white,
                                          ])),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 8, 20, 8),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Mini Bundle', // add your text here
                                              style: TextStyle(
                                                  color: Colors.deepPurple,
                                                  fontSize: 30),
                                              textAlign: TextAlign.start,
                                            ),
                                            Spacer(),
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Colors.purple,
                                                        Colors.purple.shade900,
                                                      ])),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(6.0),
                                                child: Text(
                                                  '3.99',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 25),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]),
                        )),
                  ],
                ),
                SizedBox(
                  height: 3.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                            Expanded(
                                flex: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                        Colors.orangeAccent,
                                        Colors.orangeAccent,
                                      ])),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 10.h,
                                            padding: EdgeInsets.all(3.w),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                AspectRatio(
                                                  aspectRatio: 1,
                                                  child: Sprites
                                                      .coinOf[Coins.gold],
                                                ),
                                                SizedBox(
                                                  width: 1.w,
                                                ),
                                                Text(
                                                  '30',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20),
                                                  textAlign: TextAlign.center,
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: 8.h,
                                            padding: EdgeInsets.all(3.w),
                                            child: Row(
                                              children: [
                                                AspectRatio(
                                                  aspectRatio: 1,
                                                  child: Sprites
                                                      .coinOf[Coins.silver],
                                                ),
                                                SizedBox(
                                                  width: 1.w,
                                                ),
                                                Text(
                                                  '60',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: 6.h,
                                            padding: EdgeInsets.all(3.w),
                                            child: Row(
                                              children: [
                                                AspectRatio(
                                                  aspectRatio: 1,
                                                  child: Sprites
                                                      .coinOf[Coins.bronze],
                                                ),
                                                SizedBox(
                                                  width: 1.w,
                                                ),
                                                Text(
                                                  '100',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
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
                                            Colors.orange.shade600,
                                          ])),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 8, 20, 8),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Super Bundle', // add your text here
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 30),
                                              textAlign: TextAlign.start,
                                            ),
                                            Spacer(),
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Colors.purple,
                                                        Colors.purple.shade900,
                                                      ])),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(6.0),
                                                child: Text(
                                                  '6.99',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 25),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]),
                        )),
                  ],
                ),
                SizedBox(
                  height: 3.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                            Expanded(
                                flex: 10,
                                child: NeoPopShimmer(
                                  shimmerColor: colorLightGrey.withOpacity(0.8),
                                  duration: const Duration(milliseconds: 1500),
                                  delay: const Duration(milliseconds: 2000),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                          Colors.brown.shade600,
                                          Colors.brown.shade800,
                                        ])),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 10.h,
                                              padding: EdgeInsets.all(3.w),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  AspectRatio(
                                                    aspectRatio: 1,
                                                    child: Sprites
                                                        .coinOf[Coins.gold],
                                                  ),
                                                  SizedBox(
                                                    width: 1.w,
                                                  ),
                                                  Text(
                                                    '50',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20),
                                                    textAlign: TextAlign.center,
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 8.h,
                                              padding: EdgeInsets.all(3.w),
                                              child: Row(
                                                children: [
                                                  AspectRatio(
                                                    aspectRatio: 1,
                                                    child: Sprites
                                                        .coinOf[Coins.silver],
                                                  ),
                                                  SizedBox(
                                                    width: 1.w,
                                                  ),
                                                  Text(
                                                    '100',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 6.h,
                                              padding: EdgeInsets.all(3.w),
                                              child: Row(
                                                children: [
                                                  AspectRatio(
                                                    aspectRatio: 1,
                                                    child: Sprites
                                                        .coinOf[Coins.bronze],
                                                  ),
                                                  SizedBox(
                                                    width: 1.w,
                                                  ),
                                                  Text(
                                                    '200',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
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
                                            Colors.orange.shade600,
                                          ])),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 8, 20, 8),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Jumbo Bundle', // add your text here
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 30),
                                              textAlign: TextAlign.start,
                                            ),
                                            Spacer(),
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Colors.purple,
                                                        Colors.purple.shade900,
                                                      ])),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(6.0),
                                                child: Text(
                                                  '9.99',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 25),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]),
                        )),
                  ],
                ),
              ])),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 50.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.orange,
                                  Colors.orange.shade800,
                                ])),
                        child: Text(
                          'Store',
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        )),
                    SizedBox(height: 3.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [...gameCoinList()],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(child: Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(CupertinoIcons.left_chevron),),
          ))
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
