import 'package:tictactoe/PowersGame/core.dart';

import '../Configurations/constants.dart';

class QuantumCell extends Power{
  @override
  int get id => 10;
  @override
  String get name => 'Quantum Cell';
  @override
  String get description => 'Make enemy cell in quantum state for one round';
  @override
  int get duration => 1;

  QuantumCell({required super.playerState});

  Map<int, Spell>? setSpell({required List<int> cells, required List<PowerCell> grid}){
    switch(canPlay(cells.first, grid)){
      case CellOut.passed:
        return {
          cells.first: Spell(
              effect: CellEffect.quantum,
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
              effect: CellEffect.quantum,
              duration: -1,
              from: playerState)
        };
    }
  }

  CellOut canPlay(int cellAt, List<PowerCell> grid) {
    final cell = grid[cellAt];

    if (cell.value != opponent(playerState)) return CellOut.blocked;

    /// then in terms of spells
    return (spellEffect(cell, playerState));
  }
}

class QuantumCellSilver extends Power{
  @override
  int get id => 11;
  @override
  String get name => 'Quantum Cell';
  @override
  String get description => 'Make two enemy cells in quantum state for two round';
  @override
  int get duration => 2;

  QuantumCellSilver({required super.playerState});

  Map<int, Spell>? setSpell(
      {required List<int> cells, required List<PowerCell> grid}) {


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
    final theOpponent = opponent(playerState);

    if (cell.value != theOpponent || cell2.value != theOpponent) return CellOut.blocked;

    return combinedSpellEffects([cell, cell2], playerState);
  }
}

class QuantumCellFinale extends QuantumCellSilver{
  @override
  int get id => 12;
  @override
  String get name => 'Quantum Cell';
  @override
  String get description => 'Make two enemy cells in quantum state permanently';
  @override
  int get duration => 100;

  QuantumCellFinale({required super.playerState});

}

