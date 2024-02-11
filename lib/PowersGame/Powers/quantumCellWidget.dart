import 'dart:async';
import 'dart:ffi';

import 'package:flame/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Controllers/powersGameController.dart';

import '../powerWidgets.dart';

class QuantumCellWidget extends StatefulWidget {

  final PowersGameController controller;

  const QuantumCellWidget({
    Key? key,
    required this.controller
  }) : super(key: key);

  @override
  State<QuantumCellWidget> createState() => _QuantumCellWidgetState();
}

class _QuantumCellWidgetState extends State<QuantumCellWidget> {


  bool switcher = false;
  late Timer timer;
  @override
  void initState() {
    timer = Timer.periodic(const Duration(milliseconds: 700), (timer) => setState(() {
      switcher = !switcher;
    }));
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: EdgeInsets.all(2.w),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
        child: switcher ?
        AspectRatio(
            key: UniqueKey(),
            aspectRatio: 1,
            child: widget.controller.myCharacter.avatar):
        AspectRatio(
            key: UniqueKey(),
            aspectRatio: 1,
            child: oppAvatarView(widget.controller)),
      ),
    );
  }
}

