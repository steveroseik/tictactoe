import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tictactoe/BackendMethods/backend.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupCompletionPage extends StatefulWidget {
  const SignupCompletionPage({Key? key}) : super(key: key);

  @override
  State<SignupCompletionPage> createState() => _SignupCompletionPageState();
}

class _SignupCompletionPageState extends State<SignupCompletionPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Backend backend= Backend();
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
    User? currentUser = _firebaseAuth.currentUser;
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

  // void _completeSignUp() {
  //   // Create user in db
  //   User? currentUser = _firebaseAuth.currentUser;
  // // String email,
  // // required String name,
  // // required String username,
  // // required bool isMale,
  // // required DateTime birthdate,
  // // required String provider,
  // // required DateTime createdAt,
  // // required DateTime lastModified,
  // // required String facebookId,
  // // String country = "",
  // // String city = "",
  //
  //   // createUser(currentUser.email, currentUser.displayName, currentUser.providerData,currentUser.phoneNumber)
  //   print("Created successfully");
  // }

  void _completeSignUp() async {
    User? currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {

      final query = '''
          mutation q{
                  createUser(createUserInput: {
                      id: "${FirebaseAuth.instance.currentUser!.uid}",
                      email: "${currentUser.email}",
                      name: "${_usernameController.text}",
                      username: "${_usernameController.text}",
                      provider: "${FirebaseAuth.instance.currentUser!.providerData[0].providerId}"
                      isMale: $_isMale,
                      birthdate: "1990-11-11",
                      createdAt: "1990-11-11"
                      lastModified: "1990-11-11"
                  })
                }
          ''';

      print(query);
      // Make HTTP POST request
      Uri url = Uri.parse('http://172.20.10.2:3000/graphql');
      try {
        print('trying');
        final response = await http.post(
          url,
          body: jsonEncode({'query' : query }),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        print(response.body);

        if (response.statusCode == 200) {
          // Success
          print('User created successfully');
        } else {
          // Failure
          print('Failed to create user. Error: ${response.body}');
        }
      } catch (e) {
        print('Error creating user: $e');
      }
    }
  }
}
