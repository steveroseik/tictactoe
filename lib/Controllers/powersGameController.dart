import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/PowersGame/Characters/core.dart';
import 'package:tictactoe/PowersGame/core.dart';
import 'package:tictactoe/objects/powerRoomObject.dart';
import '../Configurations/constants.dart';
import '../PowersGame/powerCell.dart';
import '../objects/classicObjects.dart';
import '../Configurations/constants.dart';

const gridLen = 7;
class PowersGameController extends ChangeNotifier{
  List<List<PowerCell>> grid = List.generate(gridLen, (row) => List.generate(gridLen, (col) =>  PowerCell()));

  List<int> winningPath = [];

  late bool _myTurn;

  late int _myIndex;

  int _roundCount = 0;

  bool _roundSpellPlayed = false;
  bool _roundSinglePlayed = false;


  PowersRoom roomInfo;

  late PowerClient opponent;

  GameWinner _gameWinner = GameWinner.none;

  GameConn _myConnection = GameConn.online;

  GameConn _oppConnection = GameConn.online;

  late ValueNotifier<GameState> _currentState;

  bool _iWon = false;

  (int, int)? _lastMove;

  String uid;

  DateTime? _roundTimeout;

  late Character myCharacter;

  late Character oppCharacter;

  bool sameAvatar = false;

  get isMyTurn => _myTurn;
  get state => _currentState.value;
  get myConnection => _myConnection;
  get oppConnection => _oppConnection;
  DateTime? get timeout => _roundTimeout;
  GameWinner get winner => _gameWinner;
  get myIndex => _myIndex;
  get iWon => _iWon;
  get roundAt => _roundCount;
  get canPlayMove => ((_myTurn && !_roundSinglePlayed));
  get canPlaySpell => (_myTurn && !_roundSpellPlayed);

  Power get first => myCharacter.firstPower;
  Power get second => myCharacter.secondPower;

  Power get oppFirst => oppCharacter.firstPower;
  Power get oppSecond => oppCharacter.secondPower;

  PowersGameController({required this.roomInfo,
    required ValueNotifier<GameState> currentState,
    required this.uid}){

    for (var i in roomInfo.users){
      if (i.userId == uid){
        myCharacter = i.character;
      }else{
        opponent = i;
        oppCharacter = i.character;
      }
    }

    if (myCharacter.type == oppCharacter.type){
      if ((myCharacter.power1Level + myCharacter.power2Level) ==
          (oppCharacter.power1Level + oppCharacter.power2Level)){
        sameAvatar = true;
      }
    }
    _currentState = currentState;
    _roundTimeout = DateTime.now().add(const Duration(seconds: 32));
    if (roomInfo.userTurn == opponent.userId){
      _myIndex = Const.oCell;
      _myTurn = false;
    }else{
      _myIndex = Const.xCell;
      _myTurn = true;
    }

  }

  int genCount = 0;


  int spotsRemaining(){
    int count = 0;
    for (int i=0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        if (grid[i][j].value == Const.nullCell) count++;
      }
    }
    return count;
  }

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

  List<PowerCell> linearizedGrid(){
    List<PowerCell> linear = [];
    for (var i in grid){
      linear.addAll(i);
    }
    return linear;
  }

  bool? setManualMove((int, int) loc, {bool myPlay = true}){

    if (grid[loc.$1][loc.$2].value == -1){
      print('${grid[loc.$1][loc.$2].value} :{}');
      final response = spellEffect(grid[loc.$1][loc.$2], myPlay ? _myIndex : (1-_myIndex));
      print('response: $response');
      if ( response == CellOut.trapped){
        return false;

      }else if (response == CellOut.blocked){
        return null;

      }else{

        grid[loc.$1][loc.$2].value = myPlay ? _myIndex : (1-_myIndex);

        if (myPlay) notifyListeners();
        return true;
      }
    }
    return null;
  }

  dynamic setSpellMove({required bool firstPower, required List<int> cells, bool myPlay = true}){

    print('the cells: $cells');
    Map<int, Spell>? newSpells = firstPower ?
    (myPlay) ? first.setSpell(cells: cells, grid: linearizedGrid()) : oppFirst.setSpell(cells: cells, grid: linearizedGrid()) :
    (myPlay) ? second.setSpell(cells: cells, grid: linearizedGrid()) : oppSecond.setSpell(cells: cells, grid: linearizedGrid());

    if (newSpells == null) return null;
    for (var entry in newSpells.entries){
      final i = entry.key;
      grid[i ~/ gridLen][i % gridLen].spell = entry.value;
    }
    notifyListeners();
    return myPlay ? requestSpellConfirmation(newSpells, firstPower) : newSpells;

  }


  requiredCell({required bool firstPower}){
    return firstPower ? first.requires() : second.requires();
  }

  Map<String, dynamic> requestMoveConfirmation(int moveIndex){
    return {
      'type': 'powersMove',
      'move': moveIndex,
      'hash': hashGrid(),
      'roomId': roomInfo.id,
      'userId': uid
    };
  }

  Map<String, dynamic> requestSpellConfirmation(Map<int, Spell> spells, bool firstPower){
    final map = Map.from(spells.map((key, value) => MapEntry(key.toString(), value.toJson())));
    print(map);
    return {
      'type': 'powersSpell',
      'spells': map,
      'firstPower': firstPower,
      'hash': hashGrid(),
      'roomId': roomInfo.id,
      'userId': uid
    };
  }


  Map<String, dynamic> validateMove(int moveIndex, String hash){
    final resp = setManualMove((moveIndex ~/ gridLen, moveIndex % gridLen), myPlay: false);
    if (resp != null){
      final generatedHash = hashGrid();
      if (hash == generatedHash){
        roomInfo.lastHash = hash;
        notifyListeners();
        return {
          'type': 'powersMoveValidation',
          'success': true,
          'hash': hash,
          'roomId': roomInfo.id
        };
      }else{
        return {
          'type': 'powersMoveValidation',
          'success': false,
          'hash': generatedHash,
          'roomId': roomInfo.id
        };
      }
    }else{
      return {
        'type': 'powersMoveValidation',
        'success': false,
        'hash': 'no_hash',
        'roomId': roomInfo.id
      };
    }
  }

  bool spellsAreEqual(Map<int, Spell> firstSet, Map<int, Spell> secondSet){
    if (firstSet.keys.length != secondSet.keys.length) return false;
    for (var i in firstSet.keys){
      if (!firstSet[i]!.isEqual(secondSet[i]!)) return false;
    }
    return true;
  }

  Map<String, dynamic> validateSpell(Map<int, Spell> spells, bool firstPower, String hash){

    final resp = setSpellMove(cells: spells.keys.toList(), myPlay: false, firstPower: firstPower);

    if (resp == null ) {
      return {
        'type': 'powersSpellValidation',
        'success': false,
        'hash': 'no_hash',
        'roomId': roomInfo.id
      };
    }

    if (spellsAreEqual(spells, resp)){
      final generatedHash = hashGrid();
      if (hash == generatedHash){
        roomInfo.lastHash = hash;
        notifyListeners();
        return {
          'type': 'powersSpellValidation',
          'success': true,
          'hash': hash,
          'roomId': roomInfo.id
        };
      }else{
        return {
          'type': 'powersSpellValidation',
          'success': false,
          'hash': generatedHash,
          'roomId': roomInfo.id
        };
      }
    }else{
      return {
        'type': 'powersSpellValidation',
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
    if (_iWon){
      if (tournament) return _tournamentWinRequest();
    }else{
      if (!canPlayMove && !canPlaySpell){
        return endMyRound();
      }
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
    _currentState.value = conn == GameConn.offline ? GameState.paused : GameState.started;
    if (conn == GameConn.online && clientId != null) opponent.clientId = clientId;
    notifyListeners();
  }

  GameState setState(GameState state){
    _currentState.value = state;
    notifyListeners();
    return state;
  }

  Map<String, dynamic>? playRandom(){
    // if (isMyTurn){
    //   if (spotsRemaining() > 0){
    //     Map<String, dynamic>? ret;
    //     do{
    //       int r = Random().nextInt(8);
    //       ret = setManualMove((r ~/ 3, r % 3));
    //     }while(ret == null);
    //     notifyListeners();
    //     return ret;
    //   }
    // }
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

  Map<String, dynamic>? endMyRound(){

    if (!_myTurn) return null;
    _myTurn = false;
    notifyListeners();
    return {
      'type': 'powersEndRound',
      'roomId': roomInfo.id,
      'userId': uid
    };
  }

  bool setMyRound(Map<String, dynamic> data){
    final userId = data['userId'];
    if (userId != null && userId == opponent.userId){
      _myTurn = true;
      _roundSpellPlayed = false;
      _roundSinglePlayed = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  playedSpell(){
    if (_myTurn){
      _roundSpellPlayed = true;
      notifyListeners();
    }
  }

  playedMove(){
    if (_myTurn){
      _roundSinglePlayed = true;
      notifyListeners();
    }
  }


  undoLastMove(){
    // if (_lastMove != null){
    //   grid[_lastMove!.$1][_lastMove!.$2] = -1;
    //   _lastMove = null;
    //   _myTurn = !_myTurn;
    // }

  }

  String hashGrid({(int, int)? future}) {
    List<List<int>> arr = [];
    for (int i=0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        final cell = grid[i][j];
        if (cell.spell == null){
          arr.add([cell.value, -1]);
        }else{
          arr.add([cell.value, cell.spell!.from, cell.spell!.effect.index, cell.spell!.duration]);
        }
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