import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/PowersGame/core.dart';
import 'package:tictactoe/PowersGame/powerCell.dart';

class RewindControl extends Power{
  @override
  int get id => 19;
  @override
  String get name => 'Rewind Control';
  @override
  String get description => "undo opponent's last move for one round";
  @override
  int get duration => 1;
  @override
  int requires() => 1;


  RewindControl({required super.playerState});

  @override
  Map<int, Spell>? setSpell({required List<int> cells, required List<PowerCell> grid}) {


    switch(canPlay(cells.first, grid)){
      case CellOut.passed:
        return {
          cells.first: Spell(
              effect:
              CellEffect.empty,
              duration: duration,
              from: playerState
          )
        };
      case CellOut.blocked: return null;
      case CellOut.trapped: print('rewinder :: should not happen');
    }
    return null;

  }

  CellOut canPlay(int cellOne, List<PowerCell> grid) {
    final cell = grid[cellOne];

    if (cell.value != (1-playerState)) return CellOut.blocked;
    return spellEffect(cell, playerState);
  }

}

class RewindControlSilver extends RewindControl{
  @override
  int get id => 20;
  @override
  String get description => "undo opponent's last move for two rounds";
  @override
  int get duration => 2;


  RewindControlSilver({required super.playerState});

}

class RewindControlFinale extends RewindControl{
  @override
  int get id => 21;
  @override
  String get description => "undo any opponent's move for one round";
  @override
  int get duration => 1;

  RewindControlFinale({required super.playerState});

}

