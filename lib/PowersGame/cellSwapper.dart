import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/PowersGame/core.dart';

class CellSwapper extends Power{
  @override
  int get id => 4;
  @override
  String get name => 'Cell Swapper';
  @override
  String get description => 'swap your cell with enemy cell for one round';
  @override
  int get duration => 1;


  CellSwapper({required super.playerState});


  @override
  Map<int, Spell>? setSpell({required List<int> cells, required List<PowerCell> grid}) {


    switch(canPlay(cells.first, cells.last, grid)){
      case CellOut.passed:
        return {
          cells.first: Spell(
              effect:
              CellEffect.swapped,
              duration: duration,
              from: playerState
          ),
          cells.last: Spell(
              effect: CellEffect.swapped,
              duration: duration,
              from: playerState
          )
        };
      case CellOut.blocked: return null;
      case CellOut.trapped: print('swapper:: should not happen');
    }
    return null;
  }

  CellOut canPlay(int cellOne, cellTwo, List<PowerCell> grid) {
    final cell = grid[cellOne];
    final cell2 = grid[cellTwo];

    if (!areSwappable(cell, cell2)) return CellOut.blocked;

    return combinedSpellEffects([cell, cell2], playerState);
  }

  bool areSwappable(PowerCell cell, PowerCell cell2){
    if (cell.value == Const.oCell || cell.value == Const.xCell){
      if (cell2.value == Const.oCell || cell2.value == Const.xCell){
        if (cell.value != cell2.value){
          return true;
        }
      }
    }
    return false;
  }
}

class CellSwapperSliver extends CellSwapper{
  @override
  int get id => 5;
  @override
  String get name => 'Cell Swapper';
  @override
  String get description => 'swap your cell with enemy cell for two rounds';
  @override
  int get duration => 2;

  CellSwapperSliver({required super.playerState});

}

class CellSwapperFinale extends CellSwapper{
  @override
  int get id => 6;
  @override
  String get name => 'Cell Swapper';
  @override
  String get description => 'swap your cell with enemy cell permanently';
  @override
  int get duration => 100;

  CellSwapperFinale({required super.playerState});

}

