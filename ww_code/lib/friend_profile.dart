import 'package:flutter/material.dart';
import 'package:ww_code/user/user_class.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendProfilePage extends StatefulWidget {
  final UserClass friend;

  const FriendProfilePage({Key? key, required this.friend}) : super(key: key);

  @override
  FriendProfilePageState createState() => FriendProfilePageState();
}

class FriendProfilePageState extends State<FriendProfilePage> {
  late User? currentUser;
  bool isFriend = false;
  bool isRequestSent = false;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _checkIfFriend();
    _checkIfRequestSent();
  }

  Future<Map<String, dynamic>> _getFriendData(String userId) async {
    DocumentSnapshot docSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    return docSnapshot.data() as Map<String, dynamic>;
  }

  Future<int> _getFriendsCount(String userId) async {
    QuerySnapshot friendsSnapshot = await FirebaseFirestore.instance
        .collection('Friends')
        .where('userId', isEqualTo: userId)
        .get();
    return friendsSnapshot.size;
  }

Future<void> _addFriend() async {
  try {
    // Check if a friend request already exists
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('FriendRequests')
        .where('senderId', isEqualTo: currentUser!.uid)
        .where('recipientId', isEqualTo: widget.friend.uid)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // If no request exists, send a new friend request
      DocumentReference friendRequestRef =
          FirebaseFirestore.instance.collection('FriendRequests').doc();

      // Create the friend request document
      await friendRequestRef.set({
        'senderId': currentUser!.uid,
        'senderDisplayName': currentUser!.displayName ?? '',
        'recipientId': widget.friend.uid,
        'recipientDisplayName': widget.friend.displayName,
        'status': 'pending',
        'timestamp': DateTime.now(),
      });

      // Add the friend request to recipient's PendingInvites
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.friend.uid)
          .collection('PendingInvites')
          .doc(friendRequestRef.id)
          .set({
        'senderId': currentUser!.uid,
        'senderDisplayName': currentUser!.displayName ?? '',
        'status': 'pending',
        'timestamp': DateTime.now(),
      });

      setState(() {
        isRequestSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request already sent!')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error sending friend request: $e')),
    );
  }
}


  Future<void> _checkIfFriend() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Friends')
          .where('userId', isEqualTo: currentUser!.uid)
          .where('friendId', isEqualTo: widget.friend.uid)
          .where('status', isEqualTo: 'accepted')
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          isFriend = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking friendship status: $e')),
      );
    }
  }

  Future<void> _checkIfRequestSent() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('FriendRequests')
          .where('senderId', isEqualTo: currentUser!.uid)
          .where('recipientId', isEqualTo: widget.friend.uid)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          isRequestSent = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking friend request status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.friend.displayName}'s profile"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getFriendData(widget.friend.uid),
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
              future: _getFriendsCount(widget.friend.uid),
              builder: (context, countSnapshot) {
                if (countSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (countSnapshot.hasError) {
                  return const Center(
                      child: Text('Error loading friends count'));
                } else {
                  int friendsCount = countSnapshot.data ?? 0;
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: profileImageUrl != null
                              ? NetworkImage(profileImageUrl)
                              : null,
                          child: profileImageUrl == null
                              ? const Icon(Icons.person,
                                  size: 60, color: Colors.black45)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.friend.displayName,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (bio != null)
                          Text(
                            bio,
                            style: const TextStyle(
                                fontSize: 16, fontStyle: FontStyle.italic),
                          ),
                        const SizedBox(height: 16),
                        Text(
                          'Friends: $friendsCount',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        if (!isFriend && !isRequestSent)
                          ElevatedButton(
                            onPressed: _addFriend,
                            child: const Text('Add Friend'),
                          )
                        else if (isFriend)
                          const Text(
                            'Already a friend',
                            style: TextStyle(color: Colors.green, fontSize: 16),
                          )
                        else if (isRequestSent)
                          const Text(
                            'Friend request sent',
                            style:
                                TextStyle(color: Colors.orange, fontSize: 16),
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
