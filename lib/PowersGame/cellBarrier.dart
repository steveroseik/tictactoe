import 'package:tictactoe/PowersGame/core.dart';

import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/PowersGame/core.dart';

class CellBarrier extends Power{
  @override
  int get id => 16;
  @override
  String get name => 'Cell Barrier';
  @override
  String get description => 'Block an empty cell from all for one round';
  @override
  int get duration => 1;


  CellBarrier({required super.playerState});

  Map<int, Spell>? setSpell({required List<int> cells, required List<PowerCell> grid}){
    switch(canPlay(cells.first, grid)){
      case CellOut.passed:
        return {
          cells.first: Spell(
              effect: CellEffect.protected,
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
              effect: CellEffect.protected,
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


class CellBarrierSilver extends CellBarrier{

  @override
  int get id => 17;
  @override
  String get name => 'Cell Barrier';
  @override
  String get description => 'Block an empty cell from all for two rounds';
  @override
  int get duration => 2;


  CellBarrierSilver({required super.playerState});

}

class CellBarrierFinale extends Power{

  @override
  int get id => 18;
  @override
  String get name => 'Cell Barrier';
  @override
  String get description => 'Block two empty cells from all for one round';
  @override
  int get duration => 1;


  CellBarrierFinale({required super.playerState});

  Map<int, Spell>? setSpell(
      {required List<int> cells, required List<PowerCell> grid}) {
    switch(canPlay(cells.first, cells.last, grid)){
      case CellOut.passed:
        return {
          cells.first: Spell(
              effect: CellEffect.protected,
              duration: duration,
              from: playerState
          ),
          cells.last: Spell(
              effect: CellEffect.protected,
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
              effect: CellEffect.protected,
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