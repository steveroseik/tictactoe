import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/Providers/getIt.dart';
import 'package:tictactoe/objects/userObject.dart';
import 'package:http/http.dart' as http;

import '../Authentication/authentication.dart';
import '../Authentication/sessionProvider.dart';



final apiLibrary = Provider<ApiLibrary>(
        (ref) => ApiLibrary(ref));
class ApiLibrary{


  ProviderRef<ApiLibrary> ref;

  Authentication get auth => ref.read(authProvider);
  SessionProvider get session => ref.read(sessionProvider);


  ApiLibrary(this.ref);

  Future<bool> createNewUser(
      {
        required String email,
        required String username,
        required String name,
        required DateTime birthdate,
        required bool isMale}) async{
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

    try{
      final resp = await sendGraphql(query);
      if (resp?['createUser']?? false){
        return true;
      }
      return false;
    }catch (e){

      return false;
    }
  }

  Future<UserObject?> user() async{
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
    if (resp != null){
      return UserObject.fromJson(resp['user']);
    }

    try{

    }catch(e) {
      print('getUserError: $e');
      return null;
    }

  }

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

      if (res != null){
        var userEmail = res['userEmail']['email'];
        return userEmail;
      }

      return '';

    } catch (e) {
      print(e);
      return '';
    }
  }

  Future<void> addFriendByUsername({required String username}) async {
    try {
      final query = '''
      mutation {
        createRequest(createRequestInput: {
          requestType: friendRequest,
          senderId: "${FirebaseAuth.instance.currentUser!.uid}",
          receiverId: "$username",
        }) 
      }
      ''';
      var res = await sendGraphql(query);
      print(res);
    } catch (e) {
      print(e);
    }
  }

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

      if (res != null){
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


      if (res != null &&
          res['findPendingFriendRequests'] != null) {
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
  // ask steven about enums for now 0 is rejected 1 is accepted

  Future<void> updateRequest({required RequestStatus status, required int id}) async {
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


  Future<Map<String, dynamic>?> sendGraphql(
      String query, {Map<String, dynamic>? variables}) async{

    try{
      final response = await http.post(
        Uri.parse(Const.graphqlUrl),
        body: jsonEncode({'query' : query }),
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
    }catch (e){
      print('gqlRequestError: $e');
      return null;
    }
  }
}