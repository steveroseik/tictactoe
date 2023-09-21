import 'dart:math';

import 'package:flutter/material.dart';

class GameEngine extends ChangeNotifier{

  List<List<int>> grid = List.generate(3, (row) => List.filled(3, -1));
  
  List<int> winningPath = [];
  
  GameEngine();

  int genCount = 0;


  int spotsRemaining(){
    int count = 0;
    for (int i=0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        if (grid[i][j] == 0) count++;
      }
    }
    return count;
  }

  (int, int) bestMove(bool maximize) {

    //placeholder for the best next move
    (int, int) move = (-1,-1);
    // placeholder for the best final score;
    int bestScore = maximize ? -999 : 999;

    //loop through empty cells and running minimax
    // algorithm on each one and getting the best score accordingly
    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        if (grid[i][j] == -1) {
          int score = 0;
          // check whether there is a blocking move or not
          // if (isBlockingMove(maximize, (i, j))) score += maximize ? 50 : -50;
          // // check whether there is a winning move or not
          // if (isBlockingMove(!maximize, (i, j))) score += !maximize ? 100 : 100;

          //check for center
          // if (i == j && j == 1 && grid[i][j] == -1) score += maximize ? 20 : -20;

          grid[i][j] = maximize ? 0 : 1;
          score += minimax(grid, 9, -999, 999, !maximize);
          print('[$i][$j]: $score');
          grid[i][j] = -1;
          if ((maximize && score > bestScore) || (!maximize && score < bestScore)) {
            bestScore = score;
            move = (i, j);
          }
        }
      }
    }
    print('==================');
    return move;
  }

  int minimax(List<List<int>> grid, int depth, int alpha, int beta, bool maximize) {
    final winner = checkWinner(grid).$1;
    if (winner != null || depth == 0){
      switch(winner) {
        case 0:
          return maximize ? (depth+1) : (depth+1);
        case 1:
          return maximize ? -(depth+1) : -(depth+1);
        default:
          return 0;
      }
    }
    int bestScore = maximize ? -999 : 999;

    bool kill = false;
    for (int i=0; i < grid.length; i++){
      for (int j=0; j < grid[i].length; j++){
        if (grid[i][j] == -1) {
          grid[i][j] = maximize ? 0 : 1;
          final score = minimax(grid, depth-1, alpha, beta, !maximize);
          grid[i][j] = -1;
          bestScore = maximize ? max(score, bestScore) : min(score, bestScore);

          // alpha beta pruning (optimization)
          // if (maximize){
          //   alpha = max(score, alpha);
          //   if (beta <= alpha){
          //     kill = true;
          //     break;
          //   }
          // }else{
          //   beta = min(score, beta);
          //   if (beta <= alpha){
          //     kill = true;
          //     break;
          //   }
          // }
        }
      }
      if (kill) break;
    }
    return bestScore;
  }

  (int?, List<int>?) checkWinner(List<List<int>> matrix, {bool? path}) {
    // Check rows, columns, and diagonals for a winner

    // Check rows
    for (int i = 0; i < 3; i++) {
      if (matrix[i][0] == matrix[i][1] && matrix[i][1] == matrix[i][2]) {
        if (matrix[i][0] == 1) {
          return (1, path??false ? [i*3, i*3+1, i*3+2] : null); // Player X wins
        } else if (matrix[i][0] == 0) {
          return (0, path??false ? [i*3, i*3+1, i*3+2] : null); // Player O wins
        }
      }
    }

    // Check columns
    for (int j = 0; j < 3; j++) {
      if (matrix[0][j] == matrix[1][j] && matrix[1][j] == matrix[2][j]) {
        if (matrix[0][j] == 1) {
          return (1, path??false ? [j, j+3, j+6] : null); // Player X wins
        } else if (matrix[0][j] == 0) {
          return (0, path??false ? [j, j+3, j+6] : null); // Player O wins
        }
      }
    }

    // Check diagonals
    if (matrix[0][0] == matrix[1][1] && matrix[1][1] == matrix[2][2]) {
      if (matrix[0][0] == 1) {
        return (1, path??false ? [0, 4, 8] : null); // Player X wins
      } else if (matrix[0][0] == 0) {
        return (0, path??false ? [0, 4, 8] : null); // Player O wins
      }
    }

    if (matrix[0][2] == matrix[1][1] && matrix[1][1] == matrix[2][0]) {
      if (matrix[0][2] == 1) {
        return (1, path??false ? [2, 4, 6] : null); // Player X wins
      } else if (matrix[0][2] == 0) {
        return (0, path??false ? [2, 4, 6] : null); // Player O wins
      }
    }

    // Check for a draw
    bool isDraw = true;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (matrix[i][j] == -1) {
          isDraw = false;
          break;
        }
      }
    }

    if (isDraw) return (-1, []); // It's a draw

    // If no winner or draw yet
    return (null, []);
  }

  bool isBlockingMove(bool maximizing, (int, int) position) {
    if (grid[position.$1][position.$2] == -1) {
      // Try placing an "O" in this empty position
      grid[position.$1][position.$2] = maximizing ? 1 : 0;

      // Check if the opponent (O) wins
      if (checkWinner(grid).$1 == (maximizing ? 1 : 0)) {
        // If placing an "O" here leads to a win for the opponent, return this position
        grid[position.$1][position.$2] = -1;
        return true;
      }
    }

      // Reset the position for further checks
    grid[position.$1][position.$2] = -1;

    // If no blocking move is found, return an invalid position
    return false;
  }

  setManualMove((int, int) loc, {required bool isO}){
    if (grid[loc.$1][loc.$2] == -1){
      grid[loc.$1][loc.$2] = isO ? 0 : 1;
      final response = checkWinner(grid, path: true);
      if (response.$1 != null) {
        if (response.$1 == -1){
          print('DRAW');
        }else{
          winningPath = response.$2!;
          print('WINNER! ${response.$1 == 0 ? 'O' : 'X'}!!');
          print(winningPath);
        }
      }
    }
    notifyListeners();
  }

  setAiMove({required bool isO}){

    final pos = bestMove(isO);
    if (pos.$1 != -1){
      setManualMove((pos.$1, pos.$2), isO: isO);
    }

  }


  resetGame(){
    for (int i=0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        grid[i][j] = -1;
      }
    }
    winningPath = [];
  }



}