import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Configurations/extensions.dart';
import 'package:tictactoe/UIUX/customWidgets.dart';

import '../Providers/apiLibrary.dart';
import '../Providers/sessionProvider.dart';

class SignupCompletionPage extends ConsumerStatefulWidget {
  const SignupCompletionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupCompletionPage> createState() => _SignupCompletionPageState();
}

class _SignupCompletionPageState extends ConsumerState<SignupCompletionPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  String _gender = '';
  DateTime? _birthdate;
  String _country = '';
  String _city = '';

  @override
  void initState() {
    super.initState();
    User? currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      _emailController.text = currentUser.email ?? '';
      _country = ''; // Fetch country from user profile if available
      _city = ''; // Fetch city from user profile if available
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepOrange,
                    Colors.deepOrange,
                    Colors.deepPurple.shade800
                  ],
                ),
              ),
            ),
            const BackgroundScroller(),
            AppBar(
              excludeHeaderSemantics: true,
              backgroundColor: Colors.transparent,
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextFormField(
                    controller: _usernameController,
                    decoration:
                    const InputDecoration(labelText: 'Username'),
                  ),
                  TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(labelText: 'Country'),
                  ),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                  CheckboxListTile(
                    title: const Text('Gender'),
                    value: _gender == 'Male',
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _gender = value ? 'Male' : 'Female';
                        });
                      }
                    },
                  ),
                  // Add birthdate picker
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null && pickedDate != _birthdate) {
                        setState(() {
                          _birthdate = pickedDate;
                        });
                      }
                    },
                    child: const Text('Select Birthdate'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // Create User
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
          ],
        ),
      ),
    );
  }

  void _completeSignUp() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String? fbId;
      if (currentUser.providerData[0].providerId == 'facebook.com'){
        fbId = currentUser.providerData[0].uid;
      }
      try{
        final resp = await ref.read(apiProvider).createNewUser(
            email: _emailController.text,
            // TODO:: separate username from name fields
            username: _usernameController.text,
            name: _usernameController.text,
            //TODO:: add facebookId
            // facebookId: fbId,
            isMale: _gender == 'male' ? true: false,
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