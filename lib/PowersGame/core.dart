
import 'package:tictactoe/Configurations/constants.dart';

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
}


/// Power Cell Container
class PowerCell{
  int value = Const.nullCell;
  Spell? spell;
}



/// Just an abstract, may be used later
abstract class Power{
  final int id = 0;
  final String name = '';
  final String description = '';
  final int duration = 0;
  final int playerState;

  Power({required this.playerState});

  Map<int, Spell>? setSpell({required List<int> cells, required List<PowerCell> grid}) {
        return null;
      }
}



/// if effect can be pressed: [traps & decoys can be pressed to enable consequences]
/// *protections and other effects cannot be pressed and have no consequences
CellOut spellEffect (PowerCell cell, int playerState){
  if (cell.spell == null) return CellOut.passed;
  if (cell.spell!.from == playerState) return CellOut.blocked;

  switch(cell.spell!.effect){
    case CellEffect.decoy:
      return CellOut.passed;

    case CellEffect.hiddenTrap:
    case CellEffect.trap:
      return CellOut.trapped;

    default:
      return CellOut.blocked;
  }
}

/// Recurse through multiple cells and return result of going through them all: in terms of spells
CellOut combinedSpellEffects(List<PowerCell> cells, int playerState, { int index = 0}){
  if (index == cells.length -1 ) return spellEffect(cells[index], playerState);
  final myCell = cells[index];
  final pThrough = spellEffect(myCell, playerState);
  if (pThrough == CellOut.trapped) return CellOut.trapped;

  switch(combinedSpellEffects(cells, playerState, index: index + 1)){
    case CellOut.trapped:
      return CellOut.trapped;
    case CellOut.blocked:
      if (pThrough == CellOut.trapped) return CellOut.trapped;
      return CellOut.blocked;
    case CellOut.passed:
      if (pThrough == CellOut.trapped) return CellOut.trapped;
      if (pThrough == CellOut.blocked) return CellOut.blocked;
      return pThrough;
  }
}


int opponent(int playerState){
  if (playerState == Const.xCell) return Const.oCell;
  if (playerState == Const.oCell) return Const.xCell;
  return Const.nullCell;
}



// final cellExchangeOne = Power(
//   id: 2,
//   name: 'Cell Exchange',
//   description: 'Swap your cell with enemy cell for one round',
//   duration: 1,
//   changeValue: CellEffect.normal,
// );
//
// final stealthMoveOne = Power(
//   id: 3,
//   name: 'Stealth Move',
//   description: 'Hide your next play for one round',
//   duration: 1,
//   changeValue: CellEffect.normal,
// );
//
// final symbolicTakeoverOne = Power(
//   id: 4,
//   name: 'Symbolic Takeover',
//   description: 'Make enemy occupied cell to x and o for one round',
//   duration: 1,
//   changeValue: CellEffect.xAndO,
// );
//
// final extraSpaceOne = Power(
//   id: 5,
//   name: 'Extra Space',
//   description: 'Play in an extra cell for one round',
//   duration: 1,
//   changeValue: CellEffect.normal,
// );
//
// final cellBlockadeOne = Power(
//   id: 6,
//   name: 'Cell Blockade',
//   description: 'Block an empty cell from all for one round',
//   duration: 1,
//   changeValue: CellEffect.blocked,
// );
//
// final cellShiftOne = Power(
//   id: 7,
//   name: 'Cell Shift',
//   description: 'Move one of your cells over for one round',
//   duration: 1,
//   changeValue: CellEffect.shifted,
// );
//
// final retroRevertOne = Power(
//   id: 8,
//   name: 'Retro Revert',
//   description: 'Undo player last move for one round',
//   duration: 1,
//   changeValue: CellEffect.normal,
// );
//
// final trapLureOne = Power(
//   id: 9,
//   name: 'Trap Lure',
//   description: 'Put trap for enemy in one cell for one round',
//   duration: 1,
//   changeValue: CellEffect.normal,
// );
//
// final surroundingShieldOne = Power(
//   id: 10,
//   name: 'Surrounding Shield',
//   description: 'Protect horizontal/vertical surroundings of cell for one round',
//   duration: 1,
//   changeValue: CellEffect.normal,
// );