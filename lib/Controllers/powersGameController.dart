import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:tictactoe/PowersGame/Characters/core.dart';
import 'package:tictactoe/PowersGame/core.dart';
import '../Configurations/constants.dart';
import '../objects/classicObjects.dart';
import 'constants.dart';

const powersGridLength = 7;
class PowersGameController extends ChangeNotifier{
  // List<List<PowerCell>> grid = List.generate(powersGridLength, (row) => List.filled(powersGridLength, PowerCell()));
  //
  // List<int> winningPath = [];
  //
  // late bool _myTurn;
  //
  // late int _myIndex;
  //
  // ClassicRoom roomInfo;
  //
  // GameWinner _gameWinner = GameWinner.none;
  //
  // GameConn _myConnection = GameConn.online;
  //
  // GameConn _oppConnection = GameConn.online;
  //
  // late ValueNotifier<GameState> _currentState;
  //
  // bool _iWon = false;
  //
  // (int, int)? _lastMove;
  //
  // String uid;
  //
  // DateTime? _roundTimeout;
  //
  // Character myCharacter;
  //
  // get isMyTurn => _myTurn;
  // get state => _currentState.value;
  // get myConnection => _myConnection;
  // get oppConnection => _oppConnection;
  // DateTime? get timeout => _roundTimeout;
  // GameWinner get winner => _gameWinner;
  // get myIndex => _myIndex;
  // get iWon => _iWon;
  //
  // ClientObject get opponent => roomInfo.users.firstWhere((e) => e.userId != uid);
  //
  // PowersGameController({required this.roomInfo,
  //   required ValueNotifier<GameState> currentState, required this.uid, required this.myCharacter}){
  //
  //   _currentState = currentState;
  //   _roundTimeout = DateTime.now().add(const Duration(seconds: 32));
  //   if (roomInfo.userTurn == opponent.userId){
  //     _myIndex = Const.oCell;
  //     _myTurn = false;
  //   }else{
  //     _myIndex = Const.xCell;
  //     _myTurn = true;
  //   }
  // }
  //
  // int genCount = 0;
  //
  //
  // int spotsRemaining(){
  //   int count = 0;
  //   for (int i=0; i < grid.length; i++) {
  //     for (int j = 0; j < grid[i].length; j++) {
  //       if (grid[i][j].value == Const.nullCell) count++;
  //     }
  //   }
  //   return count;
  // }
  //
  // _winCheck({bool notify = true}){
  //   final data = _checkWinner();
  //   winningPath = data.$2;
  //   _gameWinner = data.$1;
  //   switch (data.$1){
  //     case GameWinner.o:
  //       if (_myIndex == 0){
  //         _iWon = true;
  //       }
  //       break;
  //     case GameWinner.x:
  //       if (_myIndex != 0){
  //         _iWon = true;
  //       }
  //       break;
  //     default: // nothing
  //   }
  //   if (_gameWinner != GameWinner.none) {
  //     _roundTimeout = null;
  //     _currentState.value = GameState.ended;
  //   }else{
  //     setTimeout();
  //   }
  //
  //   if (notify) notifyListeners();
  // }
  //
  // (GameWinner, List<int>) _checkWinner({bool path = true}) {
  //   // Check rows, columns, and diagonals for a winner
  //
  //   // Check rows
  //   for (int i = 0; i < 3; i++) {
  //     if (grid[i][0] == grid[i][1] && grid[i][1] == grid[i][2]) {
  //       if (grid[i][0] == 1) {
  //         return (GameWinner.x, path ? [i*3, i*3+1, i*3+2] : []); // Player X wins
  //       } else if (grid[i][0] == 0) {
  //         return (GameWinner.o, path ? [i*3, i*3+1, i*3+2] : []); // Player O wins
  //       }
  //     }
  //   }
  //
  //   // Check columns
  //   for (int j = 0; j < 3; j++) {
  //     if (grid[0][j] == grid[1][j] && grid[1][j] == grid[2][j]) {
  //       if (grid[0][j] == 1) {
  //         return (GameWinner.x, path ? [j, j+3, j+6] : []); // Player X wins
  //       } else if (grid[0][j] == 0) {
  //         return (GameWinner.o, path ? [j, j+3, j+6] : []); // Player O wins
  //       }
  //     }
  //   }
  //
  //   // Check diagonals
  //   if (grid[0][0] == grid[1][1] && grid[1][1] == grid[2][2]) {
  //     if (grid[0][0] == 1) {
  //       return (GameWinner.x, path ? [0, 4, 8] : []); // Player X wins
  //     } else if (grid[0][0] == 0) {
  //       return (GameWinner.o, path ? [0, 4, 8] : []); // Player O wins
  //     }
  //   }
  //
  //   if (grid[0][2] == grid[1][1] && grid[1][1] == grid[2][0]) {
  //     if (grid[0][2] == 1) {
  //       return (GameWinner.x, path ? [2, 4, 6] : []); // Player X wins
  //     } else if (grid[0][2] == 0) {
  //       return (GameWinner.o, path ? [2, 4, 6] : []); // Player O wins
  //     }
  //   }
  //
  //   // Check for a draw
  //   bool isDraw = spotsRemaining() == 0;
  //
  //   if (isDraw) return (GameWinner.draw, []); // It's a draw
  //
  //   // If no winner or draw yet
  //   return (GameWinner.none, []);
  // }
  //
  // dynamic setManualMove((int, int) loc, bool firstPower, {bool myPlay = true}){
  //
  //   // final index = (powersGridLength* loc.$1) + loc.$2;
  //   // final response;
  //   //
  //   // if (firstPower) myCharacter.firstPower.setSpell(cells: cells, grid: grid)
  //   //
  //   // if (grid[loc.$1][loc.$2] == -1){
  //   //
  //   //   grid[loc.$1][loc.$2] = myPlay ? _myIndex : (1-_myIndex);
  //   //   _lastMove = loc;
  //   //   _myTurn = !_myTurn;
  //   //   if (myPlay) notifyListeners();
  //   //   return myPlay ? requestMoveConfirmation((loc.$1 * 3) + loc.$2) : true;
  //   // }
  //   // return myPlay ? null : false;
  // }
  //
  // Map<String, dynamic> requestMoveConfirmation(int moveIndex){
  //   return {
  //     'type': 'classicAction',
  //     'move': moveIndex,
  //     'hash': hashGrid(),
  //     'roomId': roomInfo.id,
  //     'userId': uid
  //   };
  // }
  //
  // Map<String, dynamic> validateMove(int moveIndex, String hash){
  //   final resp = setManualMove((moveIndex ~/ 3, moveIndex % 3), myPlay: false);
  //
  //   if (resp == true){
  //     final generatedHash = hashGrid();
  //     if (hash == generatedHash){
  //       roomInfo.lastHash = hash;
  //       notifyListeners();
  //       return {
  //         'type': 'classicValidation',
  //         'success': true,
  //         'hash': hash,
  //         'roomId': roomInfo.id
  //       };
  //     }else{
  //       undoLastMove();
  //       return {
  //         'type': 'classicValidation',
  //         'success': false,
  //         'hash': generatedHash,
  //         'roomId': roomInfo.id
  //       };
  //     }
  //   }else{
  //     undoLastMove();
  //     return {
  //       'type': 'classicValidation',
  //       'success': false,
  //       'hash': 'no_hash',
  //       'roomId': roomInfo.id
  //     };
  //   }
  // }
  //
  // Map<String, dynamic> rejoin(){
  //
  //   return {
  //     'roomId': roomInfo.id,
  //     'hash': hashGrid(),
  //     'userId': uid
  //   };
  // }
  //
  // moveValidated({Map<String, dynamic>? data, bool tournament = false}){
  //   if (data != null) roomInfo.lastHash = data['hash'];
  //   _winCheck(notify: true);
  //   if (_iWon && tournament){
  //     return _tournamentWinRequest();
  //   }
  // }
  //
  // gotOffline(){
  //   _myConnection = GameConn.offline;
  //   _currentState.value = GameState.paused;
  //   notifyListeners();
  // }
  //
  // getBackOnline(bool? otherConnected){
  //   _myConnection = GameConn.online;
  //   _currentState.value = GameState.started;
  //   if (otherConnected != null && otherConnected == true) _oppConnection = GameConn.online;
  //   notifyListeners();
  // }
  //
  // setOppConnection(GameConn conn){
  //   _oppConnection = conn;
  //   _currentState.value = conn == GameConn.offline ? GameState.paused : GameState.started;
  //   notifyListeners();
  // }
  //
  // GameState setState(GameState state){
  //   _currentState.value = state;
  //   notifyListeners();
  //   return state;
  // }
  //
  // Map<String, dynamic>? playRandom(){
  //   if (isMyTurn){
  //     if (spotsRemaining() > 0){
  //       Map<String, dynamic>? ret;
  //       do{
  //         int r = Random().nextInt(8);
  //         ret = setManualMove((r ~/ 3, r % 3));
  //       }while(ret == null);
  //       notifyListeners();
  //       return ret;
  //     }
  //   }
  //   return null;
  // }
  //
  // setTimeout(){
  //   _roundTimeout = DateTime.now().add(const Duration(seconds: 30));
  //   notifyListeners();
  // }
  //
  //
  // (bool, dynamic) endGameDueConnection(Map<String, dynamic> data, {bool tournament = false}){
  //   final hash = data['hash'];
  //   if (hash != null && hash == roomInfo.lastHash){
  //     _gameWinner = GameWinner.values[_myIndex];
  //     _iWon = true;
  //     _currentState.value = GameState.ended;
  //     notifyListeners();
  //     return (true, !tournament ? null : _tournamentWinRequest());
  //   }
  //   return (false, !tournament ? null : _tournamentWinRequest());
  // }
  //
  //
  // Map<String, dynamic> _tournamentWinRequest(){
  //   final opp = opponent;
  //   return {
  //     'type': 'gameEnded',
  //     'lastHash': roomInfo.lastHash,
  //     'opponentId': opp.userId,
  //     'opponentClientId': opp.clientId,
  //     'roomId': roomInfo.id,
  //     'tournamentId': roomInfo.tournamentId
  //   };
  // }
  //
  //
  // undoLastMove(){
  //   if (_lastMove != null){
  //     grid[_lastMove!.$1][_lastMove!.$2] = -1;
  //     _lastMove = null;
  //     _myTurn = !_myTurn;
  //   }
  //
  // }
  //
  // String hashGrid({(int, int)? future}) {
  //   List<int> arr = [];
  //   for (int i=0; i < grid.length; i++) {
  //     for (int j = 0; j < grid[i].length; j++) {
  //       arr.add(grid[i][j]);
  //     }
  //   }
  //
  //   final jsonString = jsonEncode(arr);
  //   final hash = sha256.convert(utf8.encode(jsonString));
  //   return hash.toString();
  // }
  //
  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  // }
}