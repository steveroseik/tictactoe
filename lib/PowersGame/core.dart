
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/PowersGame/powerCell.dart';

enum CellOut{
  passed,
  blocked,
  trapped
}

enum characterType{
  minotaur,
  golem,
  orc,
  wraith,
  reaper,
  fallenAngel
}

enum powerType{
  none,
  gaurdian,
  swapper,
  barrier,
  stealth,
  quantum,
  extra,
  transporter,
  terminator,
  trapper,
  shielder
}

enum powerActionType{
  none,
  beforePlay,
  afterPlay,
  beforeAndAfter
}

/// CELL EFFECTS
enum CellEffect{
  protected,
  swapped,
  quantum,
  empty,
  hidden,
  hiddenTrap,
  trap,
  trapped,
  extraCell,
  decoy,
}

/// CELL SPELLS
class Spell{
  CellEffect effect;
  int duration;
  int from;

  Spell({required this.effect, required this.duration, required this.from});


  decrementDuration() => duration--;

  factory Spell.fromJson(Map<String, dynamic> json) =>
      Spell(
          effect: CellEffect.values[json['effect']],
          duration: json['duration'],
          from: json['from']
      );

  toJson() => {
    "effect": effect.index,
    "duration": duration,
    "from": from
  };

  bool isEqual(Spell b){
    if (effect != b.effect) return false;
    if (duration != b.duration) return false;
    if (from != b.from) return false;
    return true;
  }
}
/// Just an abstract, may be used later
abstract class Power{
  final int id = 0;
  final String name = '';
  final String description = '';
  final int duration = 0;
  final int playerState;
  final powerActionType actionType = powerActionType.none;
  final powerType type = powerType.none;



  Power({required this.playerState});


  int requires() => 0;

  Map<int, Spell>? setSpell({required List<int> cells, required List<PowerCell> grid}) => null;
}



/// if effect can be pressed: [traps & decoys can be pressed to enable consequences]
/// *protections and other effects cannot be pressed and have no consequences
CellOut spellEffect (PowerCell cell, int playerState){
  if (cell.spell == null) return CellOut.passed;
  if (cell.spell!.from == playerState) {

    if (cell.spell!.effect == CellEffect.hidden
        || cell.spell!.effect == CellEffect.hiddenTrap){
      return CellOut.passed;
    }
    return CellOut.blocked;
  }

  switch(cell.spell!.effect){
    case CellEffect.decoy:
    case CellEffect.hiddenTrap:
    case CellEffect.trap:
      return CellOut.trapped;

    default:
      return CellOut.blocked;
  }
}

/// Recurse through multiple cells and return result of going through them all: in terms of spells
CellOut combinedSpellEffects(List<PowerCell> cells, int playerState, { int index = 0}){
  if (index == cells.length - 1 ) return spellEffect(cells[index], playerState);
  final myCell = cells[index];
  final pThrough = spellEffect(myCell, playerState);
  if (pThrough == CellOut.trapped) return CellOut.trapped;

  switch(combinedSpellEffects(cells, playerState, index: index + 1)){
    case CellOut.trapped:
      return CellOut.trapped;
    case CellOut.blocked:
      return CellOut.blocked;
    case CellOut.passed:
      if (pThrough == CellOut.blocked) return CellOut.blocked;
      return pThrough;
  }
}


int opponentState(int playerState){
  if (playerState == Const.xCell) return Const.oCell;
  if (playerState == Const.oCell) return Const.xCell;
  return Const.nullCell;
}


int expToLevel(int exp){
  switch(exp % 100){
    case 10:
    case 9:
    case 8:
      return 3;
    case 7:
    case 6:
    case 5:
    case 4:
      return 2;
    case 3:
    case 2:
    case 1:
    case 0:
      return 1;
    default: return 1;
  }
}
