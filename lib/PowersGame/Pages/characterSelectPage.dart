import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/PowersGame/Characters/core.dart';
import 'package:tictactoe/PowersGame/core.dart';
import 'package:tictactoe/UIUX/customWidgets.dart';
import 'package:tictactoe/routesGenerator.dart';
import 'package:tictactoe/spritesConfigurations.dart';

import '../../UIUX/themesAndStyles.dart';


class PowersCharacterSelectPage extends StatefulWidget {
  final bool tournament;
  const PowersCharacterSelectPage({
    this.tournament = false,
    super.key});

  @override
  State<PowersCharacterSelectPage> createState() => _PowersCharacterSelectPageState();
}

class _PowersCharacterSelectPageState extends State<PowersCharacterSelectPage> {

  @override
  void initState() {
    print(widget.tournament);
    super.initState();
  }
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
              child: ElevatedButton(onPressed: () => Navigator.of(context).pop(),
              child: Text('back'),),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                  itemCount: characterType.values.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    final character = Character.fromJson({
                      'power1Level': 1,
                      'power2Level': 1,
                      'type': index,
                      'state': 1
                    });
                    return InkWell(
                      onTap: () {
                        print(widget.tournament);
                        if (!widget.tournament){
                          Navigator.of(context).popAndPushNamed(Routes.powersGameMain,
                              arguments: character);
                        }else{
                          Navigator.of(context).popAndPushNamed(Routes.powersTournamentRoom,
                              arguments: character);
                        }

                      },
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        margin: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.purple,
                              Colors.blue
                            ]
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: colorDarkBlue.withOpacity(0.5),
                                offset: Offset(3, 3),
                                spreadRadius: 1,
                                blurRadius: 3)
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: character.avatar,),
                            ),
                            Text(
                              character.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20
                              ),
                            ),
                            Text('${character.firstPower.name} lvl ${character.power1Level}',
                              style: TextStyle(
                                color: colorDarkBlue
                              ),
                            ),
                            Text('${character.secondPower.name} lvl ${character.power2Level}',
                              style: TextStyle(
                                color: colorDarkBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          )
        ],
      ),
    );
  }
}
