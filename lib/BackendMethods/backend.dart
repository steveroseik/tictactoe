import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tictactoe/Authentication/authentication.dart';

enum RequestStatus { accepted, rejected }

class Backend {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<http.Response> mainQuery(
      {required String query, Map<String, dynamic>? variables}) async {
    // Make HTTP POST request
    Uri url = Uri.parse('http://192.168.100.2:3002/graphql');
    try {
      final response = await http.post(
        url,
        body: jsonEncode({'query': query, 'variables': variables}),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Success
        print('Main Query executed successfully');
      } else {
        // Failure
        print('Failed to execute main query. Error: ${response.body}');
      }
      return response;
    } catch (e) {
      print('Error executing main query: $e');
      throw e;
    }
  }

  // Method to check if user is in DB
  Future<bool> isUserInDB() async {
    User? currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      const query = '''
      query findUser(\$id: String!) {
        user(id: \$id) {
          id
        }
      }
    ''';
      try {
        var res = await mainQuery(
            query: query,
            variables: {'id': FirebaseAuth.instance.currentUser!.uid});

        // Parsing the response
        var data = jsonDecode(res.body);
        var userData = data['data']['user'];

        // Check if user exists by verifying user data is not null
        bool userFound = userData != null;

        print("User Found: $userFound");
        return userFound;
      } catch (e) {
        print(e);
        return false;
      }
    }
    return false;
  }

  // Method to fetch user email if username is in DB
  Future<String> getEmail({required String username}) async {
    try {
      var res = await mainQuery(
        query: '''
        query findUser(\$username: String!) {
          userEmail(username: \$username) {
            email
          }
        }
      ''',
        variables: {'username': username},
      );

      // Parsing the response
      var data = jsonDecode(res.body);
      var userEmail = data['data']['userEmail']['email'];
      return userEmail;
    } catch (e) {
      print(e);
      return '';
    }
  }

  // Method to complete user sign up process
  Future<void> completeSignUp({
    required String username,
    required String name,
    bool isMale = false,
    String? birthdate,
    String? city,
    String? country,
  }) async {
    User? currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      try {
        // Start the transaction-like block
        await performTransaction([
          () => createUserMutation(username, name, isMale, birthdate),
          () => createNineScoreMutation(),
          () => createClassicScoreMutation(),
          () => createPowersScoreMutation(),
        ]);
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> performTransaction(List<Function> mutations) async {
    var transactionCompleted = false;

    // Execute each mutation function
    for (var mutation in mutations) {
      try {
        await mutation();
      } catch (e) {
        // If any mutation fails, rollback the transaction
        print('Rollback the transaction due to: $e');
        throw e;
      }
    }

    // If all mutations succeed, mark the transaction as completed
    transactionCompleted = true;

    if (transactionCompleted) {
      print('Transaction completed successfully');
    }
  }

  Future<void> createUserMutation(
      String username, String name, bool isMale, String? birthdate) async {
    final query = '''
    mutation {
      createUser(createUserInput: {
        id: "${FirebaseAuth.instance.currentUser!.uid}",
        email: "${FirebaseAuth.instance.currentUser!.email}",
        name: "$name",
        username: "$username",
        provider: "${FirebaseAuth.instance.currentUser!.providerData[0].providerId}",
        isMale: $isMale,
        birthdate: "$birthdate"
      }) 
    }
  ''';

    var res = await mainQuery(query: query);
  }

  Future<void> createNineScoreMutation() async {
    final query = '''
    mutation {
      createNineScore(createNineScoreInput: {
        userId: "${FirebaseAuth.instance.currentUser!.uid}"
      }) 
    }
  ''';

    var res = await mainQuery(query: query);
    print(res.body);
  }

  Future<void> createClassicScoreMutation() async {
    final query = '''
    mutation {
      createClassicScore(createClassicScoreInput: {
        userId: "${FirebaseAuth.instance.currentUser!.uid}"
      }) 
    }
  ''';

    var res = await mainQuery(query: query);
  }

  Future<void> createPowersScoreMutation() async {
    final query = '''
    mutation {
      createPowersScore(createPowersScoreInput: {
        userId: "${FirebaseAuth.instance.currentUser!.uid}"
      }) 
    }
  ''';

    var res = await mainQuery(query: query);
  }

  // Method to add a friend using username
  Future<void> addFriendByUsername({required String username}) async {
    try {
      final receiverUser = await getUserId(username: username);
      final query = '''
      mutation {
        createRequest(createRequestInput: {
          requestType: friendRequest,
          senderId: "${FirebaseAuth.instance.currentUser!.uid}",
          receiverId: "$receiverUser",
        }) 
      }
      ''';
      var res = await mainQuery(query: query);
      print(res);
    } catch (e) {
      print(e);
    }
  }

// Helper method to get user id by username
  Future<String> getUserId({required String username}) async {
    try {
      var res = await mainQuery(
        query: '''
        query findUserByUsername(\$username: String!) {
  userEmail(username: \$username) {
    id
  }
}

      ''',
        variables: {'username': username},
      );

      // Parsing the response
      var data = jsonDecode(res.body);
      if (data['data'] != null && data['data']['userEmail'] != null) {
        var userId = data['data']['userEmail']['id'];
        print("biekdsfff              " + userId);
        return userId;
      } else {
        throw Exception('User not found or response format is incorrect');
      }
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<dynamic> GetGameFriends() async {
    try {
      var gameFriends = await GetGameFriendsFromBackend();

      // Check if the provider is Facebook
      if (FirebaseAuth.instance.currentUser != null &&
          FirebaseAuth.instance.currentUser!.providerData.isNotEmpty &&
          FirebaseAuth.instance.currentUser!.providerData[0].providerId ==
              'facebook.com') {
        var accessToken = await Authentication().getFacebookAccessToken();
        if (accessToken != null) {
          var facebookFriends =
              await getFacebookFriends(token: accessToken.token);
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

  Future<List<dynamic>> GetGameFriendsFromBackend() async {
    try {
      var res = await mainQuery(
        query: '''
          query {
            FindFriends(inputId: "${FirebaseAuth.instance.currentUser!.uid}") {
              id
              username    
            }
          }
        ''',
      );

      // Parsing the response
      var data = jsonDecode(res.body);
      var userData = data['data']['FindFriends'];
      return userData;
    } catch (e) {
      print('Error getting game friends from backend: $e');
      throw e;
    }
  }

  Future<List<dynamic>> getFacebookFriends(
      {required String token, String afterCursor = ''}) async {
    final limit = 25; // Number of friends per page

    // Construct the URL with the endpoint and necessary parameters
    final url = Uri.parse(
        'https://graph.facebook.com/v18.0/me/friends?limit=$limit&access_token=$token${afterCursor.isNotEmpty ? '&after=$afterCursor' : ''}');

    try {
      // Fetch friends data from the API
      final response = await http.get(url);
      final data = json.decode(response.body);

      final friendsList = data['data'];

      // Check if there are more pages of data
      if (data['paging'] != null && data['paging']['next'] != null) {
        final nextUrl = Uri.parse(data['paging']['next']);
        final after = nextUrl.queryParameters['after']!;

        // Fetch the next page recursively
        friendsList
            .addAll(await getFacebookFriends(token: token, afterCursor: after));
      }

      return friendsList;
    } catch (error) {
      print('Error fetching Facebook friends data: $error');
      return [];
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

  // Method to get friends requests
  // Future<String> getPendingRequests() async {
  //   try {
  //     var res = await mainQuery(query: '''
  //       query {
  //         findPendingFriendRequests(id: "${FirebaseAuth.instance.currentUser!.uid}") {
  //           id
  //         senderId
  //         }
  //       }

  //     ''');

  //     // Parsing the response
  //     var data = jsonDecode(res.body);
  //     if (data['data'] != null && data['data']['findPendingFriendRequests'] != null) {
  //       var senderId = data['data']['findPendingFriendRequests']['senderId'];

  //       return senderId;
  //     } else {
  //       throw Exception('User not found or response format is incorrect');
  //     }
  //   } catch (e) {
  //     print(e);
  //     throw e;
  //   }
  // }

  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    try {
      var res = await mainQuery(query: '''
      query {
        findPendingFriendRequests(id: "${FirebaseAuth.instance.currentUser!.uid}") {
          id
          senderId
        }
      }
    ''');

      // Parsing the response
      var data = jsonDecode(res.body);
      if (data['data'] != null &&
          data['data']['findPendingFriendRequests'] != null) {
        List<Map<String, dynamic>> pendingRequests = [];
        for (var request in data['data']['findPendingFriendRequests']) {
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
  // ask steven about enums for now 0 is rejected 1 is accepted

  Future<void> updateRequest({required RequestStatus status, required int id}) async {
    try {
      // Convert enum to String
      String statusString =
          status == RequestStatus.rejected ? 'rejected' : 'accepted';

      var res = await mainQuery(
        query: '''
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

      print (res.body);
     
    } catch (e) {
      print(e);
      throw e;
    }
  }
}
