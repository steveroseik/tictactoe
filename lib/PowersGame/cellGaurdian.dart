import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/PowersGame/core.dart';



//TODO:: change to [Protect & destroy spells]
class CellGaurdian extends Power{

  @override
  int get id => 1;
  @override
  String get name => 'Cell Guardian';
  @override
  String get description => 'Protect one cells for one round';
  @override
  int get duration => 1;

  CellGaurdian({required super.playerState});

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
    /// each power has two types of validations
    /// first if the cell chosen is correct in terms if its value [x, o, empty, both]
    if (cell.value != playerState) return CellOut.blocked;

    /// then in terms of spells
    return (spellEffect(cell, playerState));
  }

}

class CellGaurdianSecond extends Power {

  @override
  int get id => 2;
  @override
  String get name => 'Cell Guardian';
  @override
  String get description => 'Protect two cells for one round';
  @override
  int get duration => 1;

  CellGaurdianSecond({required super.playerState});

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
    if (cell.value != playerState || cell2.value != playerState) return CellOut.blocked;

    return combinedSpellEffects([cell, cell2], playerState);
  }
}


class CellGaurdianFinale extends CellGaurdianSecond {

  @override
  int get id => 3;
  @override
  String get description => 'Protect two cells for two rounds';
  @override
  get duration => 3;

  CellGaurdianFinale({required super.playerState});


  @override
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
}

