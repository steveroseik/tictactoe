import 'dart:math';

import 'package:flame/widgets.dart';
import 'package:tictactoe/PowersGame/Powers/cellBarrier.dart';
import 'package:tictactoe/PowersGame/Powers/cellGaurdian.dart';
import 'package:tictactoe/PowersGame/Powers/cellRewinder.dart';
import 'package:tictactoe/PowersGame/Powers/cellShift.dart';
import 'package:tictactoe/PowersGame/Powers/cellSwapper.dart';
import 'package:tictactoe/PowersGame/Powers/extraCell.dart';
import 'package:tictactoe/PowersGame/Powers/quantumCell.dart';
import 'package:tictactoe/PowersGame/Powers/stealthCell.dart';
import 'package:tictactoe/spritesConfigurations.dart';

import '../core.dart';



abstract class Character{
  late final int power1Level;
  late final int power2Level;
  late final int playerState;

  late final Power firstPower;
  late final Power secondPower;

  late final String name;

  late final characterType type;

  late final SpriteAnimationWidget avatar;

  int get level => min(power2Level, power1Level);

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
       return Orc(power1Level: level1, power2Level: level2, playerState: playerState);
     case characterType.wraith:
       return Wraith(power1Level: level1, power2Level: level2, playerState: playerState);
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

  @override
  get name => "Minotaur";


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
          secondPower = CellGaurdianSecond(playerState: playerState);
        }
        break;
      case 3: {
        secondPower = CellGaurdianFinale(playerState: playerState);
      }
      break;
    }

    /// determine character avatar level
    int avatarLevel = min(power1Level, power2Level);

    switch(avatarLevel){
      case 3: avatar = Sprites.characterOf[CharacterType.minotaur2]!;
      case 2: avatar = Sprites.characterOf[CharacterType.minotaur1]!;
      default: avatar = Sprites.characterOf[CharacterType.minotaur3]!;
    }
  }
}


class Golem extends Character{

  Power get extraCell => firstPower;
  Power get barrierCell => secondPower;
  @override
  get name => "Golem";

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
          secondPower = CellBarrierSilver(playerState: playerState);
        }
        break;
      case 3: {
        secondPower = CellBarrierFinale(playerState: playerState);
      }
      break;
    }

    /// determine character avatar level
    int avatarLevel = 1;
    if (power2Level < power1Level){
      avatarLevel = power2Level;
    }else{
      avatarLevel = power1Level;
    }

    switch(avatarLevel){
      case 3: avatar = Sprites.characterOf[CharacterType.golem3]!;
      case 2: avatar = Sprites.characterOf[CharacterType.golem1]!;
      default: avatar = Sprites.characterOf[CharacterType.golem2]!;
    }
  }
}

class Wraith extends Character{

  Power get stealthCell => firstPower;
  Power get quantumCell => secondPower;
  @override
  get name => "Wraith";

  Wraith({
    required super.power1Level,
    required super.playerState, required super.power2Level}){

    super.type = characterType.wraith;
    /// determine first power level
    switch(power1Level){
      case 1: {
        firstPower = StealthCell(playerState: playerState);
      }
      break;
      case 2:
        {
          firstPower = StealthCellSilver(playerState: playerState);
        }
        break;
      case 3: {
        firstPower = StealthCellFinale(playerState: playerState);
      }
      break;
    }

    /// determine second power level
    switch(power2Level){
      case 1:
        {
          secondPower = QuantumCell(playerState: playerState);
        }
        break;
      case 2:
        {
          secondPower = QuantumCellSilver(playerState: playerState);
        }
        break;
      case 3: {
        secondPower = QuantumCellFinale(playerState: playerState);
      }
      break;
    }

    /// determine character avatar level
    int avatarLevel = min(power1Level, power2Level);

    switch(avatarLevel){
      case 3: avatar = Sprites.characterOf[CharacterType.wraith3]!;
      case 2: avatar = Sprites.characterOf[CharacterType.wraith1]!;
      default: avatar = Sprites.characterOf[CharacterType.wraith2]!;
    }
  }
}

class Orc extends Character{

  Power get cellShift => firstPower;
  Power get cellRewind => secondPower;
  @override
  get name => "Orc";

  Orc({
    required super.power1Level,
    required super.playerState, required super.power2Level}){

    super.type = characterType.orc;
    /// determine first power level
    switch(power1Level){
      case 1: {
        firstPower = CellShift(playerState: playerState);
      }
      break;
      case 2:
        {
          firstPower = CellShiftSilver(playerState: playerState);
        }
        break;
      case 3: {
        firstPower = CellShiftFinale(playerState: playerState);
      }
      break;
    }

    /// determine second power level
    switch(power2Level){
      case 1:
        {
          secondPower = RewindControl(playerState: playerState);
        }
        break;
      case 2:
        {
          secondPower = RewindControlSilver(playerState: playerState);
        }
        break;
      case 3: {
        secondPower = RewindControlFinale(playerState: playerState);
      }
      break;
    }

    /// determine character avatar level
    int avatarLevel = min(power1Level, power2Level);

    switch(avatarLevel){
      case 3: avatar = Sprites.characterOf[CharacterType.orc]!;
      case 2: avatar = Sprites.characterOf[CharacterType.ogre]!;
      default: avatar = Sprites.characterOf[CharacterType.goblin]!;
    }
  }
}