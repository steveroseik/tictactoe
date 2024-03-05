import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/BackendMethods/apiLibrary.dart';
import 'package:tictactoe/Configurations/constants.dart';
import 'package:tictactoe/UIUX/customWidgets.dart';
import '../UIUX/themesAndStyles.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  late final Future<List<Map<String, dynamic>>> _friendRequestsFuture; 
@override
  void initState() {
    super.initState();
  }

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
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(CupertinoIcons.left_chevron),
                ),
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.all(5.w),
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _friendRequestsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        } else {
                          // Display friend requests
                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: List.generate(snapshot.data!.length,
                                  (index) {
                                // Customize the UI based on friend request data
                                return buildFriendRequestItem(snapshot.data![index]);
                              }),
                            ),
                          );
                        }
                      },
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

  Widget buildFriendRequestItem(Map<String, dynamic> request) {
    // Extract senderId from the request
    String senderId = request['senderId'];
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
            Icon(
              Icons.notifications,
              color: Colors.white,
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: Text(
                '$senderId has sent you a friend request',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            Row(
              children: [
                // Add Accept and Reject buttons here
                TextButton(
                  onPressed: () {
                    ref.read(apiLibrary).updateRequest(status: RequestStatus.accepted,id: request['id']);
                    
                  },
                  child: Text(
                    'Accept',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(apiLibrary).updateRequest(status: RequestStatus.rejected,id: request['id']);
                  },
                  child: Text(
                    'Reject',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
