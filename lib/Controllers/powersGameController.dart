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


  GameRoom roomInfo;

  late ClientObject opponent;

  GameWinner _gameWinner = GameWinner.none;

  GameConn _myConnection = GameConn.online;

  GameConn _oppConnection = GameConn.online;

  late ValueNotifier<GameState> _currentState;

  bool _iWon = false;

  (int, int)? _myLastMove;
  (int, int)? _oppLastMove;

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

  Map<String, dynamic>? get winRequest => (_iWon) ? _tournamentWinRequest() : null;

  PowersGameController({required this.roomInfo,
    required ValueNotifier<GameState> currentState,
    required this.uid}){

    for (var i in roomInfo.users){
      print(i.toJson());
      print('$uid :: ${i.userId}');
      if (i.userId == uid){
        print('MY $uid :: ${i.userId}');
        myCharacter = i.character!;
      }else{
        print('OP $uid :: ${i.userId}');
        opponent = i;
        oppCharacter = i.character!;
      }
    }

    if (myCharacter.type == oppCharacter.type){
      if ((myCharacter.power1Level + myCharacter.power2Level) ==
          (oppCharacter.power1Level + oppCharacter.power2Level)){
        sameAvatar = true;
      }
    }

    _currentState = currentState;
    _roundTimeout = DateTime.now().add(const Duration(seconds: Const.powersRoundDuration));
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

  int count = 0;
  _winCheck({bool notify = true}){
    print('checking === == == == ==');
    // late (GameWinner, List<int>) data;
    final data = (GameWinner.draw, <int>[]);//_checkWinner(); //
    // if (count == 3){
    //   data = (GameWinner.draw, <int>[]);//_checkWinner(); //
    // }else{
    //   count++;
    //   data = _checkWinner(); //(GameWinner.draw, <int>[]);//
    // }
    winningPath = data.$2;
    _gameWinner = data.$1;

    _setIfIWon();

    if (_gameWinner != GameWinner.none) {
      _roundTimeout = null;
      _currentState.value = GameState.ended;
    }
    print('${_currentState.value}');

    if (notify && _gameWinner != GameWinner.none) notifyListeners();
  }

  didIWin(int winIndex, {bool tournament = false}){
    if (_currentState.value == GameState.coinToss){
      _gameWinner = GameWinner.values[winIndex];
      _setIfIWon();
      _currentState.value = GameState.ended;

      if (hasListeners) notifyListeners();
      if (_iWon && tournament){
        return _tournamentWinRequest();
      }
    }
  }

  _setIfIWon(){
    switch (_gameWinner){
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
  }

  (GameWinner, List<int>) _checkWinner({bool path = true}) {
    // Check rows, columns, and diagonals for a winner
    bool emptyCells = false;
    // Check rows
    for (int i = 0; i < gridLen; i++) {
      for (int j = 0; j <= gridLen - 5; j++) {
        int countO = 0;
        int countX = 0;
        for (int k = 0; k < 5; k++) {
          if (grid[i][j + k].resultVal == Const.oCell) {
            countX = 0;
            countO++;
          } else if (grid[i][j + k].resultVal == Const.xCell) {
            countO = 0;
            countX++;
          } else if (grid[i][j + k].resultVal == Const.qCell) {
            countO++;
            countX++;
          }else{
            emptyCells = true;
          }
          if (countO >= 5 ) {
            return (GameWinner.o, List<int>.generate(5, (index) => (i*gridLen) + (j + k - index)));
          }
          if (countX >= 5 ) {
            return (GameWinner.x, List<int>.generate(5, (index) => (i*gridLen) + (j + k - index)));
          }
        }

      }
    }

    // Check columns
    for (int j = 0; j < gridLen; j++) {
      for (int i = 0; i <= gridLen - 5; i++) {
        int countO = 0;
        int countX = 0;
        for (int k = 0; k < 5; k++) {
          if (grid[i + k][j].resultVal == Const.oCell) {
            countX = 0;
            countO++;
          } else if (grid[i + k][j].resultVal == Const.xCell) {
            countX++;
            countO = 0;
          } else if (grid[i + k][j].resultVal == Const.qCell) {
            countX++;
            countO++;
          }
          if (countO >= 5 ) {
            return (GameWinner.o, List<int>.generate(5, (index) => ((i + k - index)*gridLen) + j));
          }
          if (countX >= 5 ) {
            return (GameWinner.x, List<int>.generate(5, (index) => ((i + k - index)*gridLen) + j));
          }
        }
      }
    }

    // Check diagonals
    for (int i = 0; i <= gridLen - 5; i++) {
      for (int j = 0; j <= gridLen - 5; j++) {
        int countO = 0;
        int countX = 0;
        for (int k = 0; k < 5; k++) {
          if (grid[i + k][j + k].resultVal == Const.oCell) {
            countX = 0;
            countO++;
          } else if (grid[i + k][j + k].resultVal == Const.xCell) {
            countX++;
            countO = 0;
          } else if (grid[i + k][j + k].resultVal == Const.qCell) {
            countX++;
            countO++;
          }
          if (countO >= 5 ) {
            return (GameWinner.o, List<int>.generate(5, (index) => ((i + k - index)*gridLen) + (j + k - index)));
          }
          if (countX >= 5 ) {
            return (GameWinner.x, List<int>.generate(5, (index) => ((i + k - index)*gridLen) + (j + k - index)));
          }
        }
      }
    }

    // Check anti-diagonals
    for (int i = 4; i < gridLen; i++) {
      for (int j = 0; j <= gridLen - 5; j++) {
        int countO = 0;
        int countX = 0;
        for (int k = 0; k < 5; k++) {
          if (grid[i - k][j + k].resultVal == Const.oCell) {
            countX = 0;
            countO++;
          } else if (grid[i - k][j + k].resultVal == Const.xCell) {
            countX++;
            countO = 0;
          } else if (grid[i - k][j + k].resultVal == Const.qCell) {
            countX++;
            countO++;
          }
          if (countO >= 5 ) {
            return (GameWinner.o, List<int>.generate(5, (index) => ((i - k - index)*gridLen) + (j + k - index)));
          }
          if (countX >= 5 ) {
            return (GameWinner.x, List<int>.generate(5, (index) => ((i - k + index)*gridLen) + (j + k - index)));
          }
        }
      }
    }

    // No winner found
    return emptyCells ? (GameWinner.none, []) : (GameWinner.draw, []);
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
      final response = spellEffect(grid[loc.$1][loc.$2], myPlay ? _myIndex : (1-_myIndex));
      print('manual response: $response');
      if ( response == CellOut.trapped){
        return false;

      }else if (response == CellOut.blocked){
        return null;

      }else{

        grid[loc.$1][loc.$2].value = myPlay ? _myIndex : (1-_myIndex);

        if (myPlay){
          _myLastMove = loc;
        }else{
          _oppLastMove = loc;
        }

        if (myPlay && hasListeners) notifyListeners();
        return true;
      }
    }
    return null;
  }

  Map<int, Spell>? setSpellMove({required bool firstPower, required List<int> cells, bool myPlay = true}){

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
    return newSpells;

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

  List<int> organizeCells(Map<int, Spell> spells){
    List<int> keys = spells.keys.toList();
    List<int> cells = [];
    for (int i = 0; i < keys.length ; i++){
      if (spells[keys[i]]!.effect == CellEffect.hidden ||
          spells[keys[i]]!.effect == CellEffect.hiddenTrap){
        cells.add(keys[i]);
        break;
      }
    }

    cells.addAll(keys.where((e) => !cells.contains(e)));
    return cells;
  }


  Map<String, dynamic> validateSpell(Map<int, Spell> spells, bool firstPower, String hash){
    final keys = organizeCells(spells);
    final resp = setSpellMove(cells: keys, myPlay: false, firstPower: firstPower);

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

  moveValidated({Map<String, dynamic>? data}){
    print(data);
    if (data != null) roomInfo.lastHash = data['hash'];

    if (!canPlayMove && !canPlaySpell) return sendEndRound();

    return null;
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
    if (hasListeners) notifyListeners();
    return state;
  }

  List<(int, int)> remainingRandoms(){
    List<(int, int)> remaining = [];
    for (int i = 0; i < gridLen ; i++){
      for ( int j = 0; j < gridLen; j++){
       if (grid[i][j].value == -1 && grid[i][j].spell == null){
         remaining.add((i, j));
       }
      }
    }
    return remaining;
  }

  Map<String, dynamic>? playRandom(){
    if (isMyTurn){
      final rem = remainingRandoms();
      if (rem.isNotEmpty){
        bool? ret;
        do{
          int random = Random().nextInt(rem.length);
          ret = setManualMove(rem[random]);
          if (ret == null) rem.removeAt(random);
        }while(ret == null);
        return requestMoveConfirmation((gridLen * _myLastMove!.$1) + _myLastMove!.$2);
      }
    }
    return null;
  }

  setTimeout(){
    _roundTimeout = DateTime.now().add(const Duration(seconds: Const.powersRoundDuration));
    // notifyListeners();
  }


  (bool, dynamic) endGameDueConnection(Map<String, dynamic> data, {bool tournament = false}){
    final hash = data['hash'];
    if (hash != null && hash == roomInfo.lastHash){
      _gameWinner = GameWinner.values[_myIndex];
      _iWon = true;
      _currentState.value = GameState.ended;
      if (hasListeners) notifyListeners();
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

  sendEndRound(){

    if (!_myTurn) return;

    return {
      'type': 'powersEndRound',
      'roomId': roomInfo.id,
      'userId': uid
    };
  }

  Map<String, dynamic>? endMyRound({bool tournament = false}){
    _myTurn = false;
    _winCheck(notify: true);
    if (_gameWinner == GameWinner.none){
      decrementPowers(myPowers: false);
      setTimeout();
      notifyListeners();
    }else{
      if (_iWon && tournament) return _tournamentWinRequest();
    }
    return null;
  }

  Map<String, dynamic>? setMyRound(Map<String, dynamic> data,
  {bool tournament = false}){

    final userId = data['userId'];
    if (userId != null && userId == opponent.userId){
      _winCheck(notify: true);
      if (_gameWinner == GameWinner.none){
        decrementPowers();
        _myTurn = true;
        _roundSpellPlayed = false;
        _roundSinglePlayed = false;

        setTimeout();
        notifyListeners();
      }else{
        if (_iWon && tournament) return _tournamentWinRequest();
      }
    }
    return null;
  }

  decrementPowers({bool myPowers = true}){
    for (int i = 0; i < gridLen; i++){
      for (int j = 0; j < gridLen; j++){
        final cell = grid[i][j];
        if (cell.spell != null){
          cell.decrementSpell(myPowers ? _myIndex : (1-_myIndex));
        }
      }
    }
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
  void notifyListeners() {
    if (hasListeners) super.notifyListeners();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}