import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../UIUX/customWidgets.dart';
import '../UIUX/themesAndStyles.dart';
import '../routesGenerator.dart';


class ClassicTournamentSelection extends StatefulWidget {
  const ClassicTournamentSelection({super.key});

  @override
  State<ClassicTournamentSelection> createState() => _ClassicTournamentSelectionState();
}

class _ClassicTournamentSelectionState extends State<ClassicTournamentSelection> {
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
                child: ElevatedButton(onPressed: (){
                  Navigator.of(context).pop();
                }, child: Text("Back")),
          )),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: (){
                  Navigator.of(context).pushNamed(Routes.classicTournamentRoom);
                }, child: Text("Neophyte Challenge")),
                ElevatedButton(onPressed: (){
                  showCustomDialog(context: context, child: Container());
                }, child: Text("Vanguard Valor Championship")),
                ElevatedButton(onPressed: (){}, child: Text("Supremacy Summit Showdown"))
              ],
            ),
          )
        ],
      ),
    );
  }

  wonARound(){
    showCustomDialog(context: context, child: Container(
      child: Column(
        children: [
          Text('You Won!'),
          ElevatedButton(onPressed: (){
            Navigator.of(context).pop();
          }, child: Text('Next game'))
        ],
      ),
    ));
  }

  void showCustomDialog({required BuildContext context, required Widget child}) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, __, ___) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      width: 10, color: colorPurple.withOpacity(0.6),
                      strokeAlign: BorderSide.strokeAlignOutside),
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [colorDarkBlue, colorPurple]
                  )
              ),
              padding: EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('You Won!'),
                  ElevatedButton(onPressed: (){
                    Navigator.of(context).pop();
                  }, child: Text('Next game'))
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: Offset(-1, 0), end: Offset.zero);
        } else {
          tween = Tween(begin: Offset(1, 0), end: Offset.zero);
        }

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }
}
