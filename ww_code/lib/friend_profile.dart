import 'package:flutter/material.dart';
import 'package:ww_code/auth/user_class.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendProfilePage extends StatelessWidget {
  final UserClass friend;

  const FriendProfilePage({Key? key, required this.friend}) : super(key: key);

  // Retrieve friend count of user
  Future<int> _getFriendsCount(String userId) async {
    QuerySnapshot friendsSnapshot = await FirebaseFirestore.instance
        .collection('Friends')
        .where('userId', isEqualTo: userId)
        .get();
    return friendsSnapshot.size;
  }

  // Load searched user's credentials
  Future<Map<String, dynamic>> _getFriendData(String userId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get();
    return snapshot.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${friend.displayName}'s profile"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getFriendData(friend.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading profile'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available'));
          } else {
            Map<String, dynamic> friendData = snapshot.data!;
            String? profileImageUrl = friendData['profileImageUrl'];
            String? bio = friendData['bio'];
            return FutureBuilder<int>(
              future: _getFriendsCount(friend.uid),
              builder: (context, countSnapshot) {
                if (countSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (countSnapshot.hasError) {
                  return const Center(child: Text('Error loading friends count'));
                } else {
                  int friendsCount = countSnapshot.data ?? 0;
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey,
                          backgroundImage: profileImageUrl != null 
                              ? NetworkImage(profileImageUrl) 
                              : null,
                          child: profileImageUrl == null 
                              ? const Icon(Icons.person, size: 60) 
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          friend.displayName,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (bio != null)
                          Text(
                            bio,
                            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                          ),
                        const SizedBox(height: 16),
                        Text(
                          'Friends: $friendsCount',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}