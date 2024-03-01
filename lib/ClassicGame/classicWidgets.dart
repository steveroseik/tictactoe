import 'package:flutter/material.dart';
import 'package:tictactoe/Controllers/classicGameController.dart';


Widget classicOppViewAvatar(Widget character, bool sameAvatar){
  if (sameAvatar) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (rect) => LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.6),
            Colors.purple.withOpacity(0.6)
          ]).createShader(rect),
      child: character,);
  }else{
    return character;
  }
}
