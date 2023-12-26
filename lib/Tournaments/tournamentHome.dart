import 'package:flutter/material.dart';

import '../UIUX/customWidgets.dart';
import '../routesGenerator.dart';

class TournamentsHomePage extends StatefulWidget {
  const TournamentsHomePage({super.key});

  @override
  State<TournamentsHomePage> createState() => _TournamentsHomePageState();
}

class _TournamentsHomePageState extends State<TournamentsHomePage> {
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
                      Colors.deepOrange,
                      Colors.deepOrange,
                      Colors.deepPurple.shade800
                    ])),
          ),
          const BackgroundScroller(),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('back'),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: (){
                  Navigator.of(context).pushNamed(Routes.classicTournamentSelection);
                }, child: Text("Classic Tournaments")),
                ElevatedButton(onPressed: (){}, child: Text("Nine Tournaments")),
                ElevatedButton(onPressed: (){}, child: Text("Powers Tournaments"))
              ],
            ),
          )
        ],
      ),
    );
  }
}
