import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/Providers/apiLibrary.dart';
import 'package:tictactoe/objects/leaderboardObjects.dart';
import '../UIUX/customWidgets.dart';

class ScoresPage extends ConsumerStatefulWidget {
  const ScoresPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ScoresPage> createState() => _ScoresPageState();
}

class _ScoresPageState extends ConsumerState<ScoresPage> {
  ApiLibrary get apiLib => ref.read(apiProvider);

  List<LeaderboardObject>? leaderboardData;
  bool isGlobal = true;
  GameType? gameType;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboards();
  }

  Future<void> _fetchLeaderboards() async {
    try {
      final List<LeaderboardObject>? leaderboard = await apiLib.getLeaderboards(
        isGlobal: isGlobal,
        gameType: gameType ?? GameType.classicSingleTiered,
      );

      if (leaderboard != null) {
        setState(() {
          leaderboardData = leaderboard;
        });
      }
    } catch (e) {
      print('Error fetching leaderboards: $e');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = ModalRoute.of(context)!.settings.arguments as Game?;
    String gameName = '';
    if (game != null) {
      switch (game) {
        case Game.classic:
          gameName = 'Classic';
          break;
        case Game.nine:
          gameName = 'NineXNine';
          break;
        case Game.powers:
          gameName = 'Powers';
          break;
      }
    } else {
      gameName = 'Unknown Game errrrooooor';
    }

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
                ],
              ),
            ),
          ),
          const BackgroundScroller(),
          AppBar(
            excludeHeaderSemantics: true,
            backgroundColor: Colors.transparent,
            title: Text('Scores for $gameName'),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20),

                    // Toggle button for isGlobal
                    Switch(
                      value: isGlobal,
                      onChanged: (value) {
                        setState(() {
                          isGlobal = value;
                        });
                        _fetchLeaderboards();
                      },
                    ),
                    // Add toggle buttons for tournament types
                    IconButton(
                      onPressed: () {
                        setState(() {
                          switch (game) {
                            case Game.classic:
                              gameType = GameType.classicSingleRandom;
                              break;
                            case Game.nine:
                              gameType = GameType.nineSingleRandom;
                              break;
                            case Game.powers:
                              gameType = GameType.powersSingleRandom;
                              break;
                            default:
                              gameType = null;
                              break;
                          }

                          _fetchLeaderboards();
                        });
                      },
                      icon: Icon(Icons.sports_score),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          switch (game) {
                            case Game.classic:
                              gameType = GameType.classicDailyTournament;
                              break;
                            case Game.nine:
                              gameType = GameType.nineDailyTournament;
                              break;
                            case Game.powers:
                              gameType = GameType.powersDailyTournament;
                              break;
                            default:
                              gameType = null;
                              break;
                          }
                          _fetchLeaderboards();
                        });
                      },
                      icon: Icon(Icons.calendar_today),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          switch (game) {
                            case Game.classic:
                              gameType = GameType.classicWeeklyTournament;
                              break;
                            case Game.nine:
                              gameType = GameType.nineWeeklyTournament;
                              break;
                            case Game.powers:
                              gameType = GameType.powersWeeklyTournament;
                              break;
                            default:
                              gameType = null;
                              break;
                          }
                          _fetchLeaderboards();
                        });
                      },
                      icon: Icon(Icons.calendar_view_week),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          switch (game) {
                            case Game.classic:
                              gameType = GameType.classicMonthlyTournament;
                              break;
                            case Game.nine:
                              gameType = GameType.nineMonthlyTournament;
                              break;
                            case Game.powers:
                              gameType = GameType.powersMonthlyTournament;
                              break;
                            default:
                              gameType = null;
                              break;
                          }
                          _fetchLeaderboards();
                        });
                      },
                      icon: Icon(Icons.event_note),
                    ),

                    if (leaderboardData != null) ...[
                      // Displaying leaderboard data based on gameType
                      for (var data in leaderboardData!) ...[
                        Text('UserId: ${data.userId}'),
                        if (gameType == GameType.classicSingleRandom ||
                            gameType == GameType.nineSingleRandom ||
                            gameType == GameType.powersSingleRandom)
                          Text('Score: ${data.score}'),
                        if (gameType == GameType.classicDailyTournament ||
                            gameType == GameType.nineDailyTournament ||
                            gameType == GameType.powersDailyTournament)
                          Text(
                              'Daily Tournament Wins: ${data.dailyTournamentWins}'),
                        if (gameType == GameType.classicWeeklyTournament ||
                            gameType == GameType.nineWeeklyTournament ||
                            gameType == GameType.powersWeeklyTournament)
                          Text(
                              'Weekly Tournament Wins: ${data.weeklyTournamentWins}'),
                        if (gameType == GameType.classicMonthlyTournament ||
                            gameType == GameType.nineMonthlyTournament ||
                            gameType == GameType.powersMonthlyTournament)
                          Text(
                              'Monthly Tournament Wins: ${data.monthlyTournamentWins}'),
                        SizedBox(height: 20),
                      ],
                    ],
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
