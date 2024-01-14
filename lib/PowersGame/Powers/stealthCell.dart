import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/PowersGame/core.dart';
import 'package:tictactoe/PowersGame/powerCell.dart';

class StealthCell extends Power{
  @override
  int get id => 7;
  @override
  String get name => 'Stealth Move';
  @override
  String get description => 'hide your play for one round';
  @override
  int get duration => 1;
  @override
  int requires() => 1;

  StealthCell({required super.playerState});

  @override
  Map<int, Spell>? setSpell({required List<int> cells, required List<PowerCell> grid}){
    switch(canPlay(cells.first, grid)){
      case CellOut.passed:
        return {
          cells.first: Spell(
              effect: CellEffect.hidden,
              duration: duration,
              from: playerState
          )
        };
      case CellOut.blocked:
        return null;
      case CellOut.trapped:
      // TODO: Handle this case better.
      // negative duration means a trap
        return {
          cells.first: Spell(
              effect: CellEffect.hidden,
              duration: -1,
              from: playerState)
        };
    }
  }

  CellOut canPlay(int cellAt, List<PowerCell> grid) {
    final cell = grid[cellAt];

    if (cell.value != Const.nullCell) return CellOut.blocked;

    /// then in terms of spells
    return (spellEffect(cell, playerState));
  }

}

class StealthCellSilver extends Power{

  @override
  int get id => 8;
  @override
  String get name => 'Stealth Move';
  @override
  String get description => 'hide your play and set a decoy for one round';
  @override
  int get duration => 1;
  @override
  int requires() => 2;

  StealthCellSilver({required super.playerState});

  @override
  Map<int, Spell>? setSpell({required List<int> cells,  required List<PowerCell> grid}){
    switch(canPlay(cells.first, cells.last, grid)){
      case CellOut.passed:
        return {
          cells.first: Spell(
              effect: CellEffect.hidden,
              duration: duration,
              from: playerState
          ),
          cells.last: Spell(
              effect: CellEffect.decoy,
              duration: duration,
              from: playerState
          )
        };
      case CellOut.blocked:
        return null;
      case CellOut.trapped:
      // TODO: Handle this case better.
      // negative duration means a trap
        return {
          cells.first: Spell(
              effect: CellEffect.hidden,
              duration: -1,
              from: playerState)
        };
    }
  }

  getCell(List<int> cells, List<PowerCell> grid, {empty = false}){
    if (grid[cells.first].value == playerState){
      return empty ? cells.last : cells.first;
    }else{
      return empty ? cells.first : cells.last;
    }
  }

  CellOut canPlay(int cellPlay, int cellDecoy, List<PowerCell> grid) {
    final play = grid[cellPlay];
    final decoy = grid[cellDecoy];

    if (play.value != Const.nullCell || decoy.value != Const.nullCell) return CellOut.blocked;

    /// then in terms of spells
    return (combinedSpellEffects([play, decoy], playerState));
  }
}

class StealthCellFinale extends StealthCell{

  @override
  int get id => 9;
  @override
  String get name => 'Stealth Move';
  @override
  String get description => 'Hide your play & make it a trap for two rounds';
  @override
  int get duration => 2;

  StealthCellFinale({required super.playerState});

  @override
  Map<int, Spell>? setSpell({required List<int> cells, required List<PowerCell> grid}){
    switch(canPlay(cells.first, grid)){
      case CellOut.passed:
        return {
          cells.first: Spell(
              effect: CellEffect.hiddenTrap,
              duration: duration,
              from: playerState
          )
        };
      case CellOut.blocked:
        return null;
      case CellOut.trapped:
      // TODO: Handle this case better.
      // negative duration means a trap
        return {
          cells.first: Spell(
              effect: CellEffect.hiddenTrap,
              duration: -1,
              from: playerState)
        };
    }
  }
}