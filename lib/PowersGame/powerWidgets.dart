import 'package:flutter/material.dart';

import '../Controllers/powersGameController.dart';

Widget oppAvatarView(PowersGameController controller){
  if (controller.sameAvatar) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (rect) => LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.6),
            Colors.purple.withOpacity(0.6)
          ]).createShader(rect),
      child: controller.oppCharacter.avatar,);
  }else{
    return controller.oppCharacter.avatar;
  }
}
