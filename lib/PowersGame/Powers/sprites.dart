


import 'package:flame/widgets.dart';

import '../../Controllers/powersGameController.dart';
import '../../spritesConfigurations.dart';
import '../core.dart';

SpriteAnimationWidget gaurdianPowerSprite(Spell spell, PowersGameController controller){
  if (spell.from == controller.myIndex){
    switch(controller.myCharacter.level){
      case 1: return Sprites.spellOf[spellEffects.gaurdianPower1]!;
      case 2: return Sprites.spellOf[spellEffects.gaurdianPower2]!;
      case 3: return Sprites.spellOf[spellEffects.gaurdianPower3]!;
      default: return Sprites.spellOf[spellEffects.gaurdianPower1]!;
    }
  }else{
    switch(controller.myCharacter.level){
      case 1: return Sprites.spellOf[spellEffects.gaurdianPower1]!;
      case 2: return Sprites.spellOf[spellEffects.gaurdianPower2]!;
      case 3: return Sprites.spellOf[spellEffects.gaurdianPower3]!;
      default: return Sprites.spellOf[spellEffects.gaurdianPower1]!;
    }
  }
}