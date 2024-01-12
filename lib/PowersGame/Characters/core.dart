import 'package:flame/widgets.dart';
import 'package:tictactoe/PowersGame/cellBarrier.dart';
import 'package:tictactoe/PowersGame/cellGaurdian.dart';
import 'package:tictactoe/PowersGame/cellSwapper.dart';
import 'package:tictactoe/PowersGame/extraCell.dart';
import 'package:tictactoe/spritesConfigurations.dart';

import '../core.dart';



abstract class Character{
  late final int power1Level;
  late final int power2Level;
  late final int playerState;

  late final Power firstPower;
  late final Power secondPower;

  late final characterType type;

  late final SpriteAnimationWidget avatar;

  Character({
    required this.power1Level,
    required this.power2Level, required this.playerState});

  factory Character.fromJson(Map<String, dynamic> json){
   final characterType type = characterType.values[json['type']];
   final level1 = json['power1Level'];
   final level2 = json['power2Level'];
   final playerState = json['state'];
   switch(type){
     case characterType.minotaur:
       return Minotaur(power1Level: level1, power2Level: level2, playerState: playerState);
     case characterType.golem:
       return Golem(power1Level: level1, power2Level: level2, playerState: playerState);
     case characterType.orc:
       // TODO: Handle this case.
     case characterType.wraith:
       // TODO: Handle this case.
     case characterType.reaper:
       // TODO: Handle this case.
     case characterType.fallenAngel:
       // TODO: Handle this case.
     default:
     return Minotaur(power1Level: 1, power2Level: 1, playerState: playerState);
   }
  }

  toJson() => {
    'power1Level': power1Level,
    'power2Level': power2Level,
    'type': type.index,
    'state': playerState
  };

}


class Minotaur extends Character{

  Power get swapperCell => firstPower;
  Power get gaurdianCell => secondPower;


  Minotaur({required super.power1Level, required super.power2Level, required super.playerState}) {
    super.type = characterType.minotaur;

    /// determine first power level
    switch(power1Level){
      case 1: {
        firstPower = CellSwapper(playerState: playerState);
      }
      break;
      case 2:
        {
          firstPower = CellSwapperSliver(playerState: playerState);
        }
        break;
      case 3: {
        firstPower = CellSwapperFinale(playerState: playerState);
      }
      break;
    }

    /// determine second power level
    switch(power2Level){
      case 1:
        {
          secondPower = CellGaurdian(playerState: playerState);
        }
        break;
      case 2:
        {
          firstPower = CellGaurdianSecond(playerState: playerState);
        }
        break;
      case 3: {
        firstPower = CellGaurdianFinale(playerState: playerState);
      }
      break;
    }

    /// determine character avatar level
    int avatarLevel = 1;
    if (power2Level < power1Level){
      avatarLevel = power2Level;
    }else if (power1Level <= power2Level){
      avatarLevel = power1Level;
    }

    switch(avatarLevel){
      case 3: avatar = Sprites.characterOf[characters.minotaur3]!;
      case 2: avatar = Sprites.characterOf[characters.minotaur2]!;
      default: avatar = Sprites.characterOf[characters.minotaur1]!;
    }
  }
}


class Golem extends Character{

  Power get extraCell => firstPower;
  Power get barrierCell => secondPower;

  Golem({
    required super.power1Level,
    required super.playerState, required super.power2Level}){

    super.type = characterType.golem;
    /// determine first power level
    switch(power1Level){
      case 1: {
        firstPower = ExtraCell(playerState: playerState);
      }
      break;
      case 2:
        {
          firstPower = ExtraCellSilver(playerState: playerState);
        }
        break;
      case 3: {
        firstPower = ExtraCellFinale(playerState: playerState);
      }
      break;
    }

    /// determine second power level
    switch(power2Level){
      case 1:
        {
          secondPower = CellBarrier(playerState: playerState);
        }
        break;
      case 2:
        {
          firstPower = CellBarrierSilver(playerState: playerState);
        }
        break;
      case 3: {
        firstPower = CellBarrierFinale(playerState: playerState);
      }
      break;
    }

    /// determine character avatar level
    int avatarLevel = 1;
    if (power2Level < power1Level){
      avatarLevel = power2Level;
    }else if (power1Level <= power2Level){
      avatarLevel = power1Level;
    }

    switch(avatarLevel){
      case 3: avatar = Sprites.characterOf[characters.golem3]!;
      case 2: avatar = Sprites.characterOf[characters.golem2]!;
      default: avatar = Sprites.characterOf[characters.golem1]!;
    }
  }
}