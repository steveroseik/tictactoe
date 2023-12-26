import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:flutter_login_facebook/flutter_login_facebook.dart';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart'; 
import 'dart:async';


class Authentication {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Normal sign up method
  Future<User?> signUpWithEmailAndPassword({required String email, required String password,required BuildContext context}) async {
    try {
      // Check for email if in db return error 

      UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // If a user is successfully created send email verification
      // if (credential != null) {
      //   User? user = credential.user;
      //   if (user != null) {
      //     await user.sendEmailVerification();
      //   }
      // }

      // Return the current user
      return _firebaseAuth.currentUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('The password provided is too weak.')));
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('The email address is badly formatted.')));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('The account already exists for that email.')));
      } else {
        throw Exception(e.code ?? ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unknown error'))));
      }
    } catch (err) {
      print("An error occurred: $err");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unknown error')));
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
    UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseAuthException catch (e) {
    // Handle sign-in errors
    throw Exception(e.message ?? 'An error occurred during sign-in.');
  }
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

  // Facebook Sign in 
  Future<User?> signInWithFacebook() async {
  try {
    // Trigger Facebook login
    final FacebookLoginResult loginResult = await FacebookLogin().logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);

    // Check if the user cancelled the login
    if (loginResult.status == FacebookLoginStatus.cancel) {
      return null;
    }

    // Obtain Facebook credential if the login was successful
    final FacebookAccessToken? accessToken = loginResult.accessToken;
    if (accessToken == null) {
      return null;
    }

    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(accessToken.token);

    // Sign in with Facebook credential
    await _firebaseAuth.signInWithCredential(facebookAuthCredential);
    print("facebook sign in successful");
    // Return the current user
    return _firebaseAuth.currentUser;
  } catch (e) {
    // Handle Facebook sign-in errors
    print('Facebook sign-in error: $e');
    return null;
  }
  }

  // Facebook Sign out
  Future<void> signOutFromFacebook() async {
  try {
    // Sign out from Facebook
    await FacebookLogin().logOut();

    // Sign out from Firebase
    await _firebaseAuth.signOut();
  } catch (e) {
    // Handle sign-out errors
    print('Error signing out from Facebook: $e');
  }
}

static bool isEmailVerified(User userData){
    if (userData.providerData.isNotEmpty){
      if (userData.providerData[0].providerId == 'facebook.com') return true;
      return userData.emailVerified;
    }
    return false;
}


}


