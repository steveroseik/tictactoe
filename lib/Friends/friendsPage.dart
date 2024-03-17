import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/Providers/apiLibrary.dart';
import 'package:tictactoe/UIUX/customWidgets.dart';

class FriendsPage extends ConsumerStatefulWidget {
  final List<String> friendNames;

  const FriendsPage({Key? key, required this.friendNames}) : super(key: key);

  @override
  ConsumerState<FriendsPage> createState() => _FriendsPageState(friendNames: friendNames);
}

class _FriendsPageState extends ConsumerState<FriendsPage> {
  final List<String> friendNames;
  final LinearGradient rowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.deepOrange,
      Colors.deepPurple.shade800,
    ],
  );

  _FriendsPageState({required this.friendNames});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
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
          SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => _showAddFriendDialog(context),
                      icon: Icon(Icons.add),
                    ),
                  ],
                ),
                Text('Friends'),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.all(5.w),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(friendNames.length, (index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              padding: EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.deepPurple.shade600,
                                    Colors.deepPurple.shade900,
                                  ],
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey.shade900,
                                    child: Text(
                                      friendNames[index][0],
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    friendNames[index],
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  ElevatedButton(
                                    onPressed: () {
                                      _showGameModeDialog(context, friendNames[index]);
                                    },
                                    child: Text('Invite'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
  TextEditingController _usernameController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add Friend'),
        content: TextField(
          controller: _usernameController,
          decoration: InputDecoration(labelText: 'Enter friend username'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              String username = _usernameController.text;
              await ref.read(apiProvider).sendRequestByUsername(username: username);
              Navigator.of(context).pop();
            },
            child: Text('Add Friend'),
          ),
        ],
      );
    },
  );
}


  void _showGameModeDialog(BuildContext context, String friendName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Modes'),
          content: Text('Select a game mode to play with $friendName:'),
          actions: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    // Implement classic game mode logic here
                    Navigator.of(context).pop();
                  },
                  child: Text('Classic Game Mode'),
                ),
                TextButton(
                  onPressed: () {
                    // Implement 9X9 game mode logic here
                    Navigator.of(context).pop();
                  },
                  child: Text('9X9 Game Mode'),
                ),
                TextButton(
                  onPressed: () {
                    // Implement power ups game mode logic here
                    Navigator.of(context).pop();
                  },
                  child: Text('Power Ups Game Mode'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
