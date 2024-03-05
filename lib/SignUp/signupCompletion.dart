import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/BackendMethods/backend.dart';
import 'package:tictactoe/Controllers/mainController.dart';
import 'package:tictactoe/UIUX/customWidgets.dart';

class SignupCompletionPage extends StatefulWidget {
  const SignupCompletionPage({Key? key}) : super(key: key);

  @override
  State<SignupCompletionPage> createState() => _SignupCompletionPageState();
}

class _SignupCompletionPageState extends State<SignupCompletionPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Backend backend = Backend();
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
        body: Consumer<MainController>(
          builder:
              (BuildContext context, MainController engine, Widget? child) {
            return Stack(
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
            );
          },
        ),
      ),
    );
  }

  void _completeSignUp() async {
    if (_gender.isNotEmpty && _birthdate != null) {
      backend.completeSignUp(
        name: _usernameController.text,
        username: _usernameController.text,
        isMale: _gender == 'Male',
        birthdate: _birthdate!.toString(),
        country: _countryController.text,
        city: _cityController.text,
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Incomplete Information'),
            content: const Text('Please select gender and birthdate.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
