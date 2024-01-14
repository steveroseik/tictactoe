import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/objects/classicObjects.dart';

class ClassicGameController extends ChangeNotifier{

  late int gridLength;

  List<List<int>> grid = [];
  
  List<int> winningPath = [];

  List<int> nineWins = [];

  late bool _myTurn;

  late int _myIndex;

  ClassicRoom roomInfo;

  GameWinner _gameWinner = GameWinner.none;

  GameConn _myConnection = GameConn.online;

  GameConn _oppConnection = GameConn.online;

  late ValueNotifier<GameState> _currentState;

  bool _iWon = false;

  final bool speedMatch;

  (int, int)? _lastMove;

  String uid;

  DateTime? _roundTimeout;

  get isMyTurn => _myTurn;
  get state => _currentState.value;
  get myConnection => _myConnection;
  get oppConnection => _oppConnection;
  DateTime? get timeout => _roundTimeout;
  GameWinner get winner => _gameWinner;
  get myIndex => _myIndex;
  get iWon => _iWon;

  get isNine => gridLength == 9;

  ClientObject get opponent => roomInfo.users.firstWhere((e) => e.userId != uid);
  
  ClassicGameController({
    required this.roomInfo,
    this.gridLength = 3,
    this.speedMatch = false,
    required ValueNotifier<GameState> currentState,
    required this.uid}){
    if (isNine){
      nineWins = List.filled(gridLength, -1);
    }
    grid = List<List<int>>
        .generate(gridLength, (index) => List.filled(gridLength, -1));
    _currentState = currentState;
    _roundTimeout = DateTime.now().add(
        isNine ? const Duration(seconds: 20) :
        const Duration(seconds: 13));

    if (roomInfo.userTurn == opponent.userId){
      _myIndex = Const.oCell;
      _myTurn = false;
    }else{
      _myIndex = Const.xCell;
      _myTurn = true;
    }
  }

  int genCount = 0;


  int spotsRemaining({int? index}){
    int count = 0;
    if (index != null){
      for (int i=0; i < grid[index].length; i++) {
        if (grid[index][i] == Const.nullCell) count++;
      }

    }else{
      for (int i=0; i < grid.length; i++) {
        for (int j = 0; j < grid[i].length; j++) {
          if (grid[i][j] == Const.nullCell) count++;
        }
      }
    }

    return count;
  }

  // (int, int) bestMove(bool maximize) {
  //
  //   //placeholder for the best next move
  //   (int, int) move = (-1,-1);
  //   // placeholder for the best final score;
  //   int bestScore = maximize ? -999 : 999;
  //
  //   //loop through empty cells and running minimax
  //   // algorithm on each one and getting the best score accordingly
  //   for (int i = 0; i < grid.length; i++) {
  //     for (int j = 0; j < grid[i].length; j++) {
  //       if (grid[i][j] == -1) {
  //         int score = 0;
  //         // check whether there is a blocking move or not
  //         // if (isBlockingMove(maximize, (i, j))) score += maximize ? 50 : -50;
  //         // // check whether there is a winning move or not
  //         // if (isBlockingMove(!maximize, (i, j))) score += !maximize ? 100 : 100;
  //
  //         //check for center
  //         // if (i == j && j == 1 && grid[i][j] == -1) score += maximize ? 20 : -20;
  //
  //         grid[i][j] = maximize ? 0 : 1;
  //         score += minimax(grid, 9, -999, 999, !maximize);
  //         grid[i][j] = -1;
  //         if ((maximize && score > bestScore) || (!maximize && score < bestScore)) {
  //           bestScore = score;
  //           move = (i, j);
  //         }
  //       }
  //     }
  //   }
  //   return move;
  // }

  // int minimax(List<List<int>> grid, int depth, int alpha, int beta, bool maximize) {
  //   final winner = checkWinner(grid).$1;
  //   if (winner != null || depth == 0){
  //     switch(winner) {
  //       case 0:
  //         return maximize ? (depth+1) : (depth+1);
  //       case 1:
  //         return maximize ? -(depth+1) : -(depth+1);
  //       default:
  //         return 0;
  //     }
  //   }
  //   int bestScore = maximize ? -999 : 999;
  //
  //   bool kill = false;
  //   for (int i=0; i < grid.length; i++){
  //     for (int j=0; j < grid[i].length; j++){
  //       if (grid[i][j] == -1) {
  //         grid[i][j] = maximize ? 0 : 1;
  //         final score = minimax(grid, depth-1, alpha, beta, !maximize);
  //         grid[i][j] = -1;
  //         bestScore = maximize ? max(score, bestScore) : min(score, bestScore);
  //
  //         // alpha beta pruning (optimization)
  //         if (maximize){
  //           alpha = max(score, alpha);
  //           if (beta <= alpha){
  //             kill = true;
  //             break;
  //           }
  //         }else{
  //           beta = min(score, beta);
  //           if (beta <= alpha){
  //             kill = true;
  //             break;
  //           }
  //         }
  //       }
  //     }
  //     if (kill) break;
  //   }
  //   return bestScore;
  // }

  _winCheck({bool notify = true}){
    // TODO:: complete
    final data = isNine ? _checkNine() : _checkWinnerClassic();
    winningPath = data.$2;
    _gameWinner = data.$1;
    switch (data.$1){
      case GameWinner.o:
        if (_myIndex == Const.oCell){
          _iWon = true;
        }
        break;
      case GameWinner.x:
        if (_myIndex == Const.xCell){
          _iWon = true;
        }
        break;
      default: // nothing
    }
    if (_gameWinner != GameWinner.none) {
      _roundTimeout = null;
      _currentState.value = GameState.ended;
    }else{
      setTimeout();
    }

    if (notify) notifyListeners();
  }

  (GameWinner, List<int>) _checkNine(){
    for (int i = 0; i < gridLength ; i++){
      nineWins[i] = _checkWinnerNine(gridIndex: i).$1;
    }

    final winner = _checkWinnerNine(list: nineWins, path: true);

    switch(winner.$1){
      case -1: return (GameWinner.none, winner.$2);
      case 0: return (GameWinner.o, winner.$2);
      case 1: return (GameWinner.x, winner.$2);
      case 2: return (GameWinner.draw, winner.$2);

      default: return (GameWinner.none, []);
    }

  }
  (int, List<int>) _checkWinnerNine({int? gridIndex, List<int>? list, bool path = false}){
    List<List<int>> smallGrid = [];

    if (gridIndex != null){
      for (int i = 0; i < 9 ; i+=3){
        smallGrid.add([grid[gridIndex][i], grid[gridIndex][i+1], grid[gridIndex][i+2]]);
      }
    }
    if (list != null){
      for (int i = 0; i < 9 ; i+=3){
        smallGrid.add([list[i], list[i+1], list[i+2]]);
      }
    }

    for (int i = 0; i < 3; i++) {
      if (smallGrid[i][0] == smallGrid[i][1] && smallGrid[i][1] == smallGrid[i][2]) {
        if (smallGrid[i][0] == 1) {
          return (1, path ? [i*3, i*3+1, i*3+2] : []); // Player X wins
        } else if (smallGrid[i][0] == 0) {
          return (0, path ? [i*3, i*3+1, i*3+2] : []); // Player O wins
        }
      }
    }

    // Check columns
    for (int j = 0; j < 3; j++) {
      if (smallGrid[0][j] == smallGrid[1][j] && smallGrid[1][j] == smallGrid[2][j]) {
        if (smallGrid[0][j] == 1) {
          return (1, path ? [j, j+3, j+6] : []); // Player X wins
        } else if (smallGrid[0][j] == 0) {
          return (0, path ? [j, j+3, j+6] : []); // Player O wins
        }
      }
    }

    // Check diagonals
    if (smallGrid[0][0] == smallGrid[1][1] && smallGrid[1][1] == smallGrid[2][2]) {
      if (smallGrid[0][0] == 1) {
        return (1, path ? [0, 4, 8] : []); // Player X wins
      } else if (smallGrid[0][0] == 0) {
        return (0, path ? [0, 4, 8] : []); // Player O wins
      }
    }

    if (smallGrid[0][2] == smallGrid[1][1] && smallGrid[1][1] == smallGrid[2][0]) {
      if (smallGrid[0][2] == 1) {
        return (1, path ? [2, 4, 6] : []); // Player X wins
      } else if (smallGrid[0][2] == 0) {
        return (0, path ? [2, 4, 6] : []); // Player O wins
      }
    }

    // Check for a draw
    bool isDraw = spotsRemaining(index: gridIndex) == 0;

    if (isDraw) return (2, []); // It's a draw

    // If no winner or draw yet
    return (-1, []);
  }

  (GameWinner, List<int>) _checkWinnerClassic({bool path = true}) {
    // Check rows, columns, and diagonals for a winner

    // Check rows
    for (int i = 0; i < 3; i++) {
      if (grid[i][0] == grid[i][1] && grid[i][1] == grid[i][2]) {
        if (grid[i][0] == 1) {
          return (GameWinner.x, path ? [i*3, i*3+1, i*3+2] : []); // Player X wins
        } else if (grid[i][0] == 0) {
          return (GameWinner.o, path ? [i*3, i*3+1, i*3+2] : []); // Player O wins
        }
      }
    }

    // Check columns
    for (int j = 0; j < 3; j++) {
      if (grid[0][j] == grid[1][j] && grid[1][j] == grid[2][j]) {
        if (grid[0][j] == 1) {
          return (GameWinner.x, path ? [j, j+3, j+6] : []); // Player X wins
        } else if (grid[0][j] == 0) {
          return (GameWinner.o, path ? [j, j+3, j+6] : []); // Player O wins
        }
      }
    }

    // Check diagonals
    if (grid[0][0] == grid[1][1] && grid[1][1] == grid[2][2]) {
      if (grid[0][0] == 1) {
        return (GameWinner.x, path ? [0, 4, 8] : []); // Player X wins
      } else if (grid[0][0] == 0) {
        return (GameWinner.o, path ? [0, 4, 8] : []); // Player O wins
      }
    }

    if (grid[0][2] == grid[1][1] && grid[1][1] == grid[2][0]) {
      if (grid[0][2] == 1) {
        return (GameWinner.x, path ? [2, 4, 6] : []); // Player X wins
      } else if (grid[0][2] == 0) {
        return (GameWinner.o, path ? [2, 4, 6] : []); // Player O wins
      }
    }

    // Check for a draw
    bool isDraw = spotsRemaining() == 0;

    if (isDraw) return (GameWinner.draw, []); // It's a draw

    // If no winner or draw yet
    return (GameWinner.none, []);
  }

  dynamic setManualMove((int, int) loc, {bool myPlay = true}){

    if (grid[loc.$1][loc.$2] == Const.nullCell){

      grid[loc.$1][loc.$2] = myPlay ? _myIndex : (1-_myIndex);
      _lastMove = loc;
      _myTurn = !_myTurn;

      if (isNine){
        if (myPlay) notifyListeners();
        return myPlay ? requestNineMoveConfirmation(loc.$1, loc.$2) : true;
      }else{
        if (myPlay) notifyListeners();
        return myPlay ? requestClassicMoveConfirmation((loc.$1 * 3) + loc.$2) : true;
      }

    }
    return myPlay ? null : false;
  }

  // gameWinner? setAiMove({required bool isO}){
  //
  //   final pos = bestMove(isO);
  //   if (pos.$1 != -1){
  //     return setManualMove((pos.$1, pos.$2), isO: isO);
  //   }
  //   return null;
  //
  // }


  // resetGame(){
  //   for (int i=0; i < grid.length; i++) {
  //     for (int j = 0; j < grid[i].length; j++) {
  //       grid[i][j] = -1;
  //     }
  //   }
  //   _xTurn = true;
  //   winningPath = [];
  //   notifyListeners();
  // }
  Map<String, dynamic> requestNineMoveConfirmation(int grid, int move){
    final hash = hashGrid();
    return {
      'type': 'nineAction',
      'grid': grid,
      'move': move,
      'hash': hash,
      'roomId': roomInfo.id,
      'userId': uid
    };
  }

  Map<String, dynamic> requestClassicMoveConfirmation(int moveIndex){
    return {
      'type': 'classicAction',
      'move': moveIndex,
      'hash': hashGrid(),
      'roomId': roomInfo.id,
      'userId': uid
    };
  }

  Map<String, dynamic> validateMove(int moveIndex, String hash, {int? grid}){
    late dynamic resp;
    if (grid != null && isNine){
      resp = setManualMove((grid, moveIndex), myPlay: false);
    }else{
      resp = setManualMove((moveIndex ~/ 3, moveIndex % 3), myPlay: false);
    }

    if (resp == true){
      final generatedHash = hashGrid();
      if (hash == generatedHash){
        roomInfo.lastHash = hash;
        notifyListeners();
        return {
          'type': isNine ? 'nineValidation' : 'classicValidation',
          'success': true,
          'hash': hash,
          'roomId': roomInfo.id
        };
      }else{
        undoLastMove();
        return {
          'type': isNine ? 'nineValidation' : 'classicValidation',
          'success': false,
          'hash': generatedHash,
          'roomId': roomInfo.id
        };
      }
    }else{
      return {
        'type': isNine ? 'nineValidation' : 'classicValidation',
        'success': false,
        'hash': 'no_hash',
        'roomId': roomInfo.id
      };
    }
  }

  Map<String, dynamic> rejoin(){

    return {
      'roomId': roomInfo.id,
      'hash': hashGrid(),
      'userId': uid
    };
  }

  moveValidated({Map<String, dynamic>? data, bool tournament = false}){
    if (data != null) roomInfo.lastHash = data['hash'];
    _winCheck(notify: true);
    if (_iWon && tournament){
      return _tournamentWinRequest();
    }
  }

  gotOffline(){
    _myConnection = GameConn.offline;
    _currentState.value = GameState.paused;
    notifyListeners();
  }

  getBackOnline(bool? otherConnected){
    _myConnection = GameConn.online;
    _currentState.value = GameState.started;
    if (otherConnected != null && otherConnected == true) _oppConnection = GameConn.online;
    notifyListeners();
  }

  setOppConnection(GameConn conn, {String? clientId}){
    _oppConnection = conn;
    if (conn == GameConn.online && clientId != null) opponent.clientId = clientId;
    if (_currentState.value == GameState.started) {
      _currentState.value =
          conn == GameConn.offline ? GameState.paused : GameState.started;
      notifyListeners();
    }
  }

  GameState setState(GameState state){
    _currentState.value = state;
    notifyListeners();
    return state;
  }

  Map<String, dynamic>? playRandom({int? nextGrid}){
    if (isMyTurn){
      if (nextGrid != null && isNine){
        final remaining = remainingGrids();
        int? grid;

        if (remaining.contains(nextGrid)){
          grid = nextGrid;
        }else{
          grid = remaining[Random().nextInt(remaining.length)];
        }

        if (spotsRemaining(index: grid) > 0){
          Map<String, dynamic>? ret;
          List<int> full = List<int>.generate(9, (index) => index);
          do{
            int move = Random().nextInt(full.length);
            ret = setManualMove((grid, full[move]));
            if (ret == null) full.removeAt(move);
          }while(ret == null);
          notifyListeners();
          return ret;
        }

      }else{
        if (spotsRemaining() > 0){
          Map<String, dynamic>? ret;
          List<int> full = List<int>.generate(9, (index) => index);
          do{
            int move = Random().nextInt(full.length);
            ret = setManualMove((full[move] ~/ 3, full[move] % 3));
            if (ret == null) full.removeAt(move);
          }while(ret == null);
          notifyListeners();
          return ret;
        }
      }
    }
    return null;
  }

  List<int> remainingGrids(){
    List<int> remaining = [];
    for (int i = 0; i < nineWins.length ; i++){
      if (nineWins[i] == -1){
        remaining.add(i);
      }
    }
    return remaining;
  }

  setTimeout(){
    if (isNine){
      _roundTimeout = DateTime.now().add(const Duration(seconds: Const.nineRoundDuration));
    }else{
      if (speedMatch){
        _roundTimeout = DateTime.now().add(const Duration(seconds: 3));
      }else{
        _roundTimeout = DateTime.now().add(const Duration(seconds: Const.classicRoundDuration));
      }

    }

    notifyListeners();
  }


  (bool, dynamic) endGameDueConnection(Map<String, dynamic> data, {bool tournament = false}){
    final hash = data['hash'];
    if (hash != null && hash == roomInfo.lastHash){
      _gameWinner = GameWinner.values[_myIndex];
      _iWon = true;
      _currentState.value = GameState.ended;
      notifyListeners();
      return (true, !tournament ? null : _tournamentWinRequest());
    }
    return (false, !tournament ? null : _tournamentWinRequest());
  }


  Map<String, dynamic> _tournamentWinRequest(){
    final opp = opponent;
    return {
      'type': 'gameEnded',
      'lastHash': roomInfo.lastHash,
      'opponentId': opp.userId,
      'opponentClientId': opp.clientId,
      'roomId': roomInfo.id,
      'tournamentId': roomInfo.tournamentId
    };
  }


  undoLastMove(){
    if (_lastMove != null){
      grid[_lastMove!.$1][_lastMove!.$2] = -1;
      _lastMove = null;
      _myTurn = !_myTurn;
    }

  }

  String hashGrid({(int, int)? future}) {
    List<int> arr = [];
    for (int i=0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        arr.add(grid[i][j]);
      }
    }



    final jsonString = jsonEncode(arr);
    final hash = sha256.convert(utf8.encode(jsonString));
    return hash.toString();
  }

 @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

}