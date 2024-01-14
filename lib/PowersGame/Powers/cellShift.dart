import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/PowersGame/core.dart';
import 'package:tictactoe/PowersGame/powerCell.dart';

class CellShift extends Power{
  @override
  int get id => 22;
  @override
  String get name => 'Cell Shifter';
  @override
  String get description => 'Move one of your cells over for one round';
  @override
  int get duration => 1;
  @override
  int requires() => 2;



  CellShift({required super.playerState});

  @override
  Map<int, Spell>? setSpell({required List<int> cells, required List<PowerCell> grid}) {


    switch(canPlay(cells.first, cells.last, grid)){
      case CellOut.passed:
        return {
          getCell(cells, grid) : Spell(
              effect: CellEffect.empty,
              duration: duration,
              from: playerState
          ),
          getCell(cells, grid, empty: true): Spell(
              effect: CellEffect.extraCell,
              duration: duration,
              from: playerState
          )
        };
      case CellOut.blocked: return null;
      case CellOut.trapped: return {
        cells.first: Spell(
            effect: CellEffect.trapped,
            duration: -1,
            from: playerState
        )
      };
    }
    return null;

  }

  CellOut canPlay(int cellOne, cellTwo, List<PowerCell> grid) {
    final cell = grid[cellOne];
    final cell2 = grid[cellTwo];

    if (!canShift(cell, cell2)) return CellOut.blocked;
    return combinedSpellEffects([cell, cell2], playerState);
  }

  getCell(List<int> cells, List<PowerCell> grid, {empty = false}){
    if (grid[cells.first].value == playerState){
      return empty ? cells.last : cells.first;
    }else{
      return empty ? cells.first : cells.last;
    }
  }

  bool canShift(PowerCell cell, PowerCell cell2){
    if ((cell.observedVal == playerState
        && cell2.observedVal == Const.nullCell)
        || (cell2.observedVal == playerState
            && cell.observedVal == Const.nullCell)){
     return true;
    }
    return false;
  }
}

class CellShiftSilver extends CellShift{
  @override
  int get id => 23;
  @override
  String get description => 'Move one of your cells over for two rounds';
  @override
  int get duration => 2;

  CellShiftSilver({required super.playerState});

}

class CellShiftFinale extends CellShift{
  @override
  int get id => 24;
  @override
  String get description => 'Move one of your cells over permanently';
  @override
  int get duration => 100;

  CellShiftFinale({required super.playerState});

}

