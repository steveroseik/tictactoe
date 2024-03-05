import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart'; 
import 'dart:async';

import 'package:tictactoe/Providers/sessionProvider.dart';



final authProvider = Provider<Authentication>((ref) => Authentication(ref));

class Authentication {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? facebookToken;
  ProviderRef<Authentication> ref;


  SessionProvider get session => ref.read(sessionProvider);

  Authentication(this.ref);

  // Normal sign up method
  Future<User?> signUpWithEmailAndPassword({required String email, required String password,required BuildContext context}) async {
    try {

      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return _firebaseAuth.currentUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('The password provided is too weak.')));
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('The email address is badly formatted.')));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('The account already exists for that email.')));
      } else {
        throw Exception(e.code);
      }
    } catch (err) {
      print("An error occurred: $err");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unknown error')));
      return null;
    }
  }

  // Verifying user
  Future<bool> verifyUser({required BuildContext context}) async {
    bool isEmailVerified = false;

    try {
      // Reload the user to get the latest information
      await _firebaseAuth.currentUser?.reload();

      // Check if the email is verified
      isEmailVerified = _firebaseAuth.currentUser?.emailVerified ?? false;

      if (isEmailVerified) {
        // Successfully verified
        print("Email is verified: $isEmailVerified");

        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email Successfully Verified")));
      }
    } catch (e) {
      print("Error in email verification: $e");
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("An error occurred while verifying the email")));
    } finally {
      return isEmailVerified;
    }
  }


  // Normal sign in method
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      ref.read(sessionProvider).updateFirebaseAuth(userData: _firebaseAuth.currentUser);
    } on FirebaseAuthException catch (e) {
      // Handle sign-in errors
      throw Exception(e.message ?? 'An error occurred during sign-in.');
    }
    return null;
  }
  // Normal signout


  // Google sign in method
  Future<User?> signInWithGoogle() async {
    try {
      print("Attempting Google Sign-In");
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount == null) return null;

      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult = await _firebaseAuth.signInWithCredential(credential);
      final User? user = authResult.user;
      print("Google Sign-In successful");
      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Google sign out method
  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  // Apple Sign in 
  Future<User?> _signInWithApple() async {
    try {
      final result = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final credential = OAuthProvider("apple.com").credential(
        accessToken: result.identityToken,
        idToken: result.identityToken,
      );

      UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      return authResult.user;
    } catch (error) {
      print(error);
      return null;
    }
  }

  // Apple Sign out

  // Facebook access token

  Future<AccessToken?> getFacebookAccessToken() async{
    final token = await FacebookAuth.instance.accessToken;

    return token?? (await getFacebookLoginResult())?.accessToken;
  }

  // Facebook Login Result

  Future<LoginResult?> getFacebookLoginResult() async{
    final LoginResult loginResult = await FacebookAuth.i.login(
        permissions: ['email', 'public_profile', 'user_birthday', 'user_friends', 'user_gender']
    );
    if (loginResult.status == LoginStatus.cancelled) {
      return null;
    }
    return loginResult;
  }

  // Facebook Sign in 
  Future<User?> signInWithFacebook() async {
    try {

      final loginResult = await getFacebookLoginResult();


      final OAuthCredential facebookAuthCredential =
      FacebookAuthProvider.credential(loginResult!.accessToken!.token);


      await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

      print("facebook sign in successful");
      // Return the current user
      return _firebaseAuth.currentUser;


    } catch (e) {
      // Handle Facebook sign-in errors
      print('Facebook sign-in error: $e');
      return null;
    }
  }

  // get facebook data
  getFacebookData() async{
    try{
      final userData = await FacebookAuth.i.getUserData(
        fields: "name,email,picture.width(200),birthday,friends,gender",
      );
      userData.forEach((key, value) => print('$key : $value'));
    }catch (e){
      print('fbDataError: $e');
    }
  }

  // Facebook Sign out
  Future<void> signOutFromFacebook() async {
  try {
    // Sign out from Facebook
    await FacebookAuth.instance.logOut();

    // Sign out from Firebase
    await _firebaseAuth.signOut();
  } catch (e) {
    // Handle sign-out errors
    print('Error signing out from Facebook: $e');
  }
}

  // Fetch user friends with pagination

  Future<List<dynamic>> getFacebookFriends({required String token, String afterCursor = ''}) async {

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
        friendsList.addAll(await getFacebookFriends(token: token, afterCursor: after));
      }

      return friendsList;
    } catch (error) {
      print('Error fetching friends data: $error');
      return [];
    }
  }

  bool isFbAuthenticated(){
    if (_firebaseAuth
        .currentUser?.providerData[0]
        .providerId == 'facebook') return true;

    if (session.currentUser?.facebookId != null) return true;

    return false;
  }

  static bool isEmailVerified(User userData){
      if (userData.providerData.isNotEmpty){
        if (userData.providerData[0].providerId == 'facebook.com') return true;
        return userData.emailVerified;
      }
      return false;
  }

}




