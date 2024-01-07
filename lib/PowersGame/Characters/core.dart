import 'package:flame/widgets.dart';
import 'package:tictactoe/PowersGame/cellBarrier.dart';
import 'package:tictactoe/PowersGame/cellGaurdian.dart';
import 'package:tictactoe/PowersGame/cellSwapper.dart';
import 'package:tictactoe/PowersGame/extraCell.dart';
import 'package:tictactoe/spritesConfigurations.dart';

import '../core.dart';


abstract class Character{
  late final int level;
  late final int playerState;

  late final Power firstPower;
  late final Power secondPower;

  late final characterType type;

  late final SpriteAnimationWidget avatar;

  Character({required this.level, required this.playerState});
}


class Minotaur extends Character{

  Power get swapperCell => firstPower;
  Power get gaurdianCell => secondPower;


  Minotaur({required super.level, required super.playerState}) {
    super.type = characterType.minotaur;

    switch(level){
      case 1: {
        firstPower = CellSwapper(playerState: playerState);
        secondPower = CellGaurdian(playerState: playerState);
        avatar = Sprites.characterOf[characters.minotaur1]!;
      }
      break;
      case 2:
        {
          firstPower = CellSwapperSliver(playerState: playerState);
          secondPower = CellGaurdianSecond(playerState: playerState);
          avatar = Sprites.characterOf[characters.minotaur2]!;
        }
        break;
      case 3: {
        firstPower = CellSwapperFinale(playerState: playerState);
        secondPower = CellGaurdianFinale(playerState: playerState);
        avatar = Sprites.characterOf[characters.minotaur3]!;
      }
      break;
    }
  }
}


class Golem extends Character{

  Power get extraCell => firstPower;
  Power get barrierCell => secondPower;

  Golem({required super.level, required super.playerState}){
    super.type = characterType.golem;
    switch(level){
      case 1: {
        firstPower = ExtraCell(playerState: playerState);
        secondPower = CellBarrier(playerState: playerState);
        avatar = Sprites.characterOf[characters.golem1]!;
      }
      break;
      case 2:
        {
          firstPower = ExtraCellSilver(playerState: playerState);
          secondPower = CellBarrier(playerState: playerState);
          avatar = Sprites.characterOf[characters.golem2]!;
        }
        break;
      case 3: {
        firstPower = ExtraCellFinale(playerState: playerState);
        secondPower = CellBarrier(playerState: playerState);
        avatar = Sprites.characterOf[characters.golem3]!;
      }
      break;
    }
  }
}