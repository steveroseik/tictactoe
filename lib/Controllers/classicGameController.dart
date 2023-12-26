import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tictactoe/Controllers/constants.dart';
import 'package:tictactoe/objects/classicObjects.dart';


enum GameWinner {o, x, draw, none}

class ClassicGameController extends ChangeNotifier{

  List<List<int>> grid = List.generate(3, (row) => List.filled(3, -1));
  
  List<int> winningPath = [];

  late bool _myTurn;

  late int _myIndex;

  ClassicRoom roomInfo;

  GameWinner _gameWinner = GameWinner.none;

  GameConn _myConnection = GameConn.online;

  GameConn _oppConnection = GameConn.online;

  late ValueNotifier<GameState> _currentState;

  bool _iWon = false;

  (int, int)? _lastMove;

  String uid;

  DateTime? _roundTimeout;

  get isMyTurn => _myTurn;
  get state => _currentState.value;
  get myConnection => _myConnection;
  get oppConnection => _oppConnection;
  get timeout => _roundTimeout;
  get winner => _gameWinner;
  get myIndex => _myIndex;
  get iWon => _iWon;
  ClientObject get opponent => roomInfo.users.firstWhere((e) => e.userId != uid);
  
  ClassicGameController({required this.roomInfo,
    required ValueNotifier<GameState> currentState, required this.uid}){

    _currentState = currentState;
    _roundTimeout = DateTime.now().add(const Duration(seconds: 32));
    if (roomInfo.userTurn == opponent.userId){
      _myIndex = 0;
      _myTurn = false;
    }else{
      _myIndex = 1;
      _myTurn = true;
    }
  }

  int genCount = 0;


  int spotsRemaining(){
    int count = 0;
    for (int i=0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        if (grid[i][j] == -1) count++;
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
    final data = _checkWinner();
    winningPath = data.$2;
    _gameWinner = data.$1;
    switch (data.$1){
      case GameWinner.o:
        if (_myIndex == 0){
          _iWon = true;
        }
        break;
      case GameWinner.x:
        if (_myIndex != 0){
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

  (GameWinner, List<int>) _checkWinner({bool path = true}) {
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

    if (grid[loc.$1][loc.$2] == -1){

      grid[loc.$1][loc.$2] = myPlay ? _myIndex : (1-_myIndex);
      _lastMove = loc;
      _myTurn = !_myTurn;
      if (myPlay) notifyListeners();
      return myPlay ? requestMoveConfirmation((loc.$1 * 3) + loc.$2) : true;
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


  Map<String, dynamic> requestMoveConfirmation(int moveIndex){
    return {
      'type': 'classicAction',
      'move': moveIndex,
      'hash': hashGrid(),
      'roomId': roomInfo.id,
      'userId': uid
    };
  }

  Map<String, dynamic> validateMove(int moveIndex, String hash){
    final resp = setManualMove((moveIndex ~/ 3, moveIndex % 3), myPlay: false);

    if (resp == true){
      final generatedHash = hashGrid();
      if (hash == generatedHash){
        roomInfo.lastHash = hash;
        notifyListeners();
        return {
          'type': 'classicValidation',
          'success': true,
          'hash': hash,
          'roomId': roomInfo.id
        };
      }else{
        undoLastMove();
        return {
          'type': 'classicValidation',
          'success': false,
          'hash': generatedHash,
          'roomId': roomInfo.id
        };
      }
    }else{
      undoLastMove();
      return {
        'type': 'classicValidation',
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

  setOppConnection(GameConn conn){
    _oppConnection = conn;
    _currentState.value = conn == GameConn.offline ? GameState.paused : GameState.started;
    notifyListeners();
  }

  GameState setState(GameState state){
    _currentState.value = state;
    notifyListeners();
    return state;
  }

  Map<String, dynamic>? playRandom(){
    if (isMyTurn){
      if (spotsRemaining() > 0){
        Map<String, dynamic>? ret;
        do{
          int r = Random().nextInt(8);
          ret = setManualMove((r ~/ 3, r % 3));
        }while(ret == null);
        notifyListeners();
        return ret;
      }
    }
    return null;
  }

  setTimeout(){
    _roundTimeout = DateTime.now().add(const Duration(seconds: 30));
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