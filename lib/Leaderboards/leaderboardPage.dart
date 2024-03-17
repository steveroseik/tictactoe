import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/Leaderboards/scoresPage.dart';
import '../UIUX/customWidgets.dart';

class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          AppBar(
            excludeHeaderSemantics: true,
            backgroundColor: Colors.transparent,
          ),
          Center(
            // Wrap the Column with Center widget
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScoresPage(),
                            settings: const RouteSettings(
                              arguments: Game.classic,
                            ),
                          ),
                        );
                      },
                      child: const Text('Classic'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScoresPage(),
                            settings: const RouteSettings(
                              arguments: Game.nine,
                            ),
                          ),
                        );
                      },
                      child: const Text('NineXNine'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScoresPage(),
                            settings: const RouteSettings(
                              arguments: Game.powers,
                            ),
                          ),
                        );
                      },
                      child: const Text('Powers'),
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
}
