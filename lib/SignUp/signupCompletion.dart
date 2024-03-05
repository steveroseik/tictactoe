import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tictactoe/BackendMethods/apiLibrary.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/Authentication/sessionProvider.dart';
import 'package:tictactoe/Providers/socketProvider.dart';

class SignupCompletionPage extends ConsumerStatefulWidget {
  const SignupCompletionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupCompletionPage> createState() => _SignupCompletionPageState();
}

class _SignupCompletionPageState extends ConsumerState<SignupCompletionPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  bool _isMale = false;
  // DateTime? _birthdate;

  @override
  void initState() {
    super.initState();
    // Populate fields with current user data if available
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _emailController.text = currentUser.email ?? '';
      // do the same for the rest 
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up Completion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              CheckboxListTile(
                title: const Text('Gender'),
                value: _isMale,
                onChanged: (value) {
                  setState(() {
                    _isMale = value ?? false;
                  });
                },
              ),
              // Add the rest of attributes fields 

              const SizedBox(height: 16.0),

              ElevatedButton(
                onPressed: () {
                  // Create user b2a
                  _completeSignUp();
                },
                child: const Text('Complete Sign Up'),
              ),

              ElevatedButton(
                onPressed: () {
                  print('signed out');
                  FirebaseAuth.instance.signOut();
                },
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _completeSignUp() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try{
        final resp = await ref.read(apiLibrary).createNewUser(
            email: _emailController.text,
            // TODO:: separate username from name fields
            username: _usernameController.text,
            name: _usernameController.text,
            isMale: _isMale,
            //TODO:: add birthdate ui
            birthdate: DateTime.parse('1997-11-11')
        );
        if (resp) {
          ref.read(sessionProvider)
            .updateFirebaseAuth(userData: FirebaseAuth.instance.currentUser);
        }else{
          print('Failed to sign up');
        }
      } catch (e) {
        print('Error creating user: $e');
      }
    }
  }
}
