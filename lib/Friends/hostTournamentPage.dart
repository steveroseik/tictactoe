import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/UIUX/customWidgets.dart';
import '../UIUX/themesAndStyles.dart';



class HostTournamentPage extends StatefulWidget {
  final String friendId;
  const HostTournamentPage({super.key, required this.friendId});

  @override
  State<HostTournamentPage> createState() => _HostTournamentPageState();
}

class _HostTournamentPageState extends State<HostTournamentPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
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
          SafeArea(
            child: Column(
              children:[
                Text(widget.friendId),
                ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colorDarkBlue,
                        foregroundColor: colorLightYellow,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.w))),
                    child: Text(
                      'Classic Mode',
                      style: TextStyle(color: colorLightYellow),
                    )),ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colorDarkBlue,
                        foregroundColor: colorLightYellow,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.w))),
                    child: Text(
                      '9x9 Mode',
                      style: TextStyle(color: colorLightYellow),
                    )),ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colorDarkBlue,
                        foregroundColor: colorLightYellow,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.w))),
                    child: Text(
                      'Power Up Mode',
                      style: TextStyle(color: colorLightYellow),
                    ))],
            ),
          ),
        ],
      ),
    );
  }




}
