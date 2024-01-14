import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/PowersGame/core.dart';
import 'package:tictactoe/PowersGame/powerCell.dart';

class ExtraCell extends Power{
  @override
  int get id => 13;
  @override
  String get name => 'Extra Space';
  @override
  String get description => 'Play in an extra cell for one round';
  @override
  int get duration => 1;

  @override
  int requires() => 1;

  ExtraCell({required super.playerState});

  @override
  Map<int, Spell>? setSpell({required List<int> cells, required List<PowerCell> grid}){
    switch(canPlay(cells.first, grid)){
      case CellOut.passed:
        return {
          cells.first: Spell(
              effect: CellEffect.extraCell,
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
              effect: CellEffect.extraCell,
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


class ExtraCellSilver extends ExtraCell{

  @override
  int get id => 14;
  @override
  String get name => 'Extra Space';
  @override
  String get description => 'Play in an extra cell for two rounds';
  @override
  int get duration => 2;


  ExtraCellSilver({required super.playerState});

}

class ExtraCellFinale extends Power{

  @override
  int get id => 15;
  @override
  String get name => 'Extra Space';
  @override
  String get description => 'Play in an extra two cells for one round';
  @override
  int get duration => 1;

  @override
  int requires() => 2;


  ExtraCellFinale({required super.playerState});

  Map<int, Spell>? setSpell(
      {required List<int> cells, required List<PowerCell> grid}) {
    switch(canPlay(cells.first, cells.last, grid)){
      case CellOut.passed:
        return {
          cells.first: Spell(
              effect: CellEffect.extraCell,
              duration: duration,
              from: playerState
          ),
          cells.last: Spell(
              effect: CellEffect.extraCell,
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
              effect: CellEffect.extraCell,
              duration: -1,
              from: playerState
          )
        };
    }
  }

  CellOut canPlay(int cellOne, cellTwo, List<PowerCell> grid) {
    final cell = grid[cellOne];
    final cell2 = grid[cellTwo];
    if (cell.value != Const.nullCell || cell2.value != Const.nullCell) return CellOut.blocked;

    return combinedSpellEffects([cell, cell2], playerState);
  }
}