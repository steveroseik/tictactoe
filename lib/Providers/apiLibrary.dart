import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/Providers/getIt.dart';
import 'package:tictactoe/objects/leaderboardObjects.dart';
import 'package:tictactoe/objects/userObject.dart';
import 'package:http/http.dart' as http;

import 'authentication.dart';
import 'sessionProvider.dart';

final apiLibrary = Provider<ApiLibrary>((ref) => ApiLibrary(ref));

class ApiLibrary {
  ProviderRef<ApiLibrary> ref;

  Authentication get auth => ref.read(authProvider);
  SessionProvider get session => ref.read(sessionProvider);
  ApiLibrary(this.ref);

  // User Service Methods:
  // Method to create user
  Future<bool> createNewUser(
      {required String email,
      required String username,
      required String name,
      required DateTime birthdate,
      required bool isMale}) async {
    final query = '''
          mutation q{
                  createUser(createUserInput: {
                      id: "${FirebaseAuth.instance.currentUser!.uid}",
                      email: "$email",
                      name: "$name",
                      username: "$username",
                      provider: "${FirebaseAuth.instance.currentUser!.providerData[0].providerId}"
                      isMale: $isMale,
                      birthdate: "${birthdate.toIso8601String()}",
                  })
                }
          ''';

    try {
      final resp = await sendGraphql(query);
      if (resp?['createUser'] ?? false) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Method that returns user data given id
  Future<UserObject?> user() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;
      final query = '''
    query a{
      user(id: "$uid"){
       id,
        name,
        birthdate,
        isMale,
        country,
        city,
        bronzeCoins,
        silverCoins,
        goldCoins,
        provider,
        email,
        username,
        facebookId,
        classicScore{
          score,
          wins,
          loses,
          tournamentWins,
          createdAt,
          lastModified
        },
        powersScore{
          score,
          wins,
          loses,
          tournamentWins,
          createdAt,
          lastModified
        },
        nineScore{
          score,
          wins,
          loses,
          tournamentWins,
          createdAt,
          lastModified
        },
        createdAt,
        lastModified
      }
}''';

      final resp = await sendGraphql(query);
      if (resp != null) {
        return UserObject.fromJson(resp['user']);
      }
    } catch (e) {
      print('getUserError: $e');
    }
  }

  // Method that return a user email given username
  Future<String> getEmail({required String username}) async {
    try {
      final res = await sendGraphql(
        '''
        query findUser(\$username: String!) {
          userEmail(username: \$username) {
            email
          }
        }
      ''',
        variables: {'username': username},
      );

      if (res != null) {
        var userEmail = res['userEmail']['email'];
        return userEmail;
      }

      return '';
    } catch (e) {
      print(e);
      return '';
    }
  }

  //TODO:: check for guide mmkn

  // Request Service Methods:
  // Method that send friend request given username
  Future<bool> sendRequestByUsername({required String username}) async {
    try {
      final uid = session.currentUser?.id;
      if (uid == null) return false;
      final query = '''
      mutation {
        createRequestWithUsername(input: {
          senderId: "$uid",
          receiverUsername: "$username",
          requestType: friendRequest
        })
      }
      ''';
      var res = await sendGraphql(query);
      if (res != null && res['createRequestWithUsername'] == true) return true;

      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Method that returns users
  // TODO:: should return List<UserObject>?
  Future<dynamic> getAllUserFriends() async {
    try {
      final gameFriends = await getUserFriends();

      if (gameFriends == null) return null;
      // Check if the provider is Facebook
      if (auth.isFbAuthenticated()) {
        var accessToken = await auth.getFacebookAccessToken();
        if (accessToken != null) {
          var facebookFriends =
              await auth.getFacebookFriends(token: accessToken.token);
          var allFriends = combineFriends(gameFriends, facebookFriends);
          return allFriends;
        } else {
          print("errroooooor acces token bih null");
          return gameFriends;
        }
      } else {
        return gameFriends;
      }
    } catch (e) {
      print('Error getting game friends: $e');
      throw e;
    }
  }

  // TODO:: return full user details and object
  Future<List<dynamic>?> getUserFriends() async {
    try {
      final query = '''
          query {
            FindFriends(inputId: "${FirebaseAuth.instance.currentUser!.uid}") {
              id
              username
            }
          }
        ''';

      final res = await sendGraphql(
        query,
      );

      if (res != null) {
        return res['FindFriends'];
      }
      return null;
    } catch (e) {
      print('Error getting game friends from backend: $e');
      throw e;
    }
  }

  List<dynamic> combineFriends(
      List<dynamic> gameFriends, List<dynamic> facebookFriends) {
    // Combine the friends from both sources
    var allFriends = [...gameFriends, ...facebookFriends];

    // Remove duplicates based on user ID
    var uniqueFriends = allFriends.toSet().toList();

    return uniqueFriends;
  }

  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    try {
      var res = await sendGraphql('''
      query {
        findPendingFriendRequests(id: "${FirebaseAuth.instance.currentUser!.uid}") {
          id
          senderId
        }
      }
    ''');

      if (res != null && res['findPendingFriendRequests'] != null) {
        List<Map<String, dynamic>> pendingRequests = [];
        for (var request in res['findPendingFriendRequests']) {
          pendingRequests.add({
            'id': request['id'],
            'senderId': request['senderId'],
          });
        }
        return pendingRequests;
      } else {
        throw Exception('User not found or response format is incorrect');
      }
    } catch (e) {
      print(e);
      throw e;
    }
  }

  // Method to update the request
  Future<void> updateRequest(
      {required RequestStatus status, required int id}) async {
    try {
      // Convert enum to String
      String statusString = status.toString();

      var res = await sendGraphql(
        '''
        mutation UpdateRequest(\$updateRequestInput: UpdateRequestInput!) {
          updateRequest(updateRequestInput: \$updateRequestInput) {
            id
            status
          }
        }
      ''',
        variables: {
          'updateRequestInput': {
            'id': id,
            'status': statusString,
          },
        },
      );

      res;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  // Leaderboards
  Future<List<LeaderboardObject>?> getLeaderboards(
    {required bool isGlobal, required GameType gameType}) async {
  try {
    var query = '''
      query {
        findLeaderboard(
          userId: "1Mrahq9dR5MClcSxYe2l3M6ZpuH3",
          isGlobal: $isGlobal,
          gameType: ${mapGameTypeToString(gameType)},
        ) {
          userId
          score
          dailyTournamentWins
          weeklyTournamentWins
          monthlyTournamentWins
        }
      }
    ''';
    var res = await sendGraphql(query);
    if (res != null && res['findLeaderboard'] != null) {
      List<dynamic> leaderboardList = res['findLeaderboard'];
      List<LeaderboardObject> leaderboardObjects = leaderboardList.map((item) => LeaderboardObject.fromJson(item)).toList();
      return leaderboardObjects;
    }
  } catch (e) {
    print(e);
  }
  return null;
}


  // Helper function
  String mapGameTypeToString(GameType gameType) {
    switch (gameType) {
      case GameType.classicSingleTiered:
        return 'classicSingleTiered';
      case GameType.classicSingleRandom:
        return 'classicSingleRandom';
      case GameType.nineSingleTiered:
        return 'nineSingleTiered';
      case GameType.nineSingleRandom:
        return 'nineSingleRandom';
      case GameType.powersSingleRandom:
        return 'powersSingleRandom';
      case GameType.powersSingleTiered:
        return 'powersSingleTiered';
      case GameType.classicDailyTournament:
        return 'classicDailyTournament';
      case GameType.nineDailyTournament:
        return 'nineDailyTournament';
      case GameType.powersDailyTournament:
        return 'powersDailyTournament';
      case GameType.classicWeeklyTournament:
        return 'classicWeeklyTournament';
      case GameType.nineWeeklyTournament:
        return 'nineWeeklyTournament';
      case GameType.powersWeeklyTournament:
        return 'powersWeeklyTournament';
      case GameType.classicMonthlyTournament:
        return 'classicMonthlyTournament';
      case GameType.nineMonthlyTournament:
        return 'nineMonthlyTournament';
      case GameType.powersMonthlyTournament:
        return 'powersMonthlyTournament';
    }
  }

  Future<Map<String, dynamic>?> sendGraphql(String query,
      {Map<String, dynamic>? variables}) async {
    try {
      final response = await http.post(
        Uri.parse(Const.graphqlUrl),
        body: jsonEncode({'query': query}),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        // Success
        if (data != null) return data;
      }
      throw Exception(response.body);
    } catch (e) {
      print('gqlRequestError: $e');
      return null;
    }
  }
}
