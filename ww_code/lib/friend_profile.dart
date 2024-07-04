import 'package:flutter/material.dart';
import 'package:ww_code/auth/user_class.dart';

class FriendProfilePage extends StatelessWidget {
  final UserClass friend;

  const FriendProfilePage({Key? key, required this.friend}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(friend.displayName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Friend Profile Page',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            Text('Friend ID: ${friend.uid}'),
            // Add more details about the friend as needed
          ],
        ),
      ),
    );
  }
}
