import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'aesthetics/themes.dart';

class ViewFriendPage extends StatefulWidget {
  final String friendUid;

  const ViewFriendPage({
    Key? key,
    required this.friendUid,
  }) : super(key: key);

  @override
  ViewFriendPageState createState() => ViewFriendPageState();
}

// View friend's data in current user's friend list in profile page
class ViewFriendPageState extends State<ViewFriendPage> {
  String? _profileImageUrl;
  String? _bio;
  int _friendsCount = 0;
  bool _isFriend = false;
  String friendDisplayName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriendData();
    _checkFriendStatus();
  }

  Future<void> _loadFriendData() async {
    try {
      DocumentSnapshot friendDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.friendUid)
          .get();

      if (friendDoc.exists) {
        Map<String, dynamic>? data = friendDoc.data() as Map<String, dynamic>?;
        setState(() {
          _profileImageUrl = data?['profileImageUrl'];
          _bio = data?['bio'];
          _friendsCount = data?['friendsCount'] ?? 0;
          friendDisplayName = data?['Username'] ?? 'Unknown User';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading friend profile'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkFriendStatus() async {
    User currentUser = FirebaseAuth.instance.currentUser!;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Friends')
        .where('userId', isEqualTo: currentUser.uid)
        .where('friendId', isEqualTo: widget.friendUid)
        .where('status', isEqualTo: 'accepted')
        .get();

    setState(() {
      _isFriend = querySnapshot.docs.isNotEmpty;
      isLoading = false;
    });
  }

  Future<void> _removeFriend() async {
    User currentUser = FirebaseAuth.instance.currentUser!;
    try {
      bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Remove Friend',
                style: TextStyle(color: Colors.black)),
            content: Text(
              'Are you sure you want to unfriend $friendDisplayName?',
              style: const TextStyle(color: Colors.black),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
                child: const Text('Remove'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );

      if (confirm) {
        // Remove friend relationship from Firestore
        WriteBatch batch = FirebaseFirestore.instance.batch();

        // Delete from Friends collection
        QuerySnapshot friendsSnapshot1 = await FirebaseFirestore.instance
            .collection('Friends')
            .where('userId', isEqualTo: currentUser.uid)
            .where('friendId', isEqualTo: widget.friendUid)
            .get();

        QuerySnapshot friendsSnapshot2 = await FirebaseFirestore.instance
            .collection('Friends')
            .where('userId', isEqualTo: widget.friendUid)
            .where('friendId', isEqualTo: currentUser.uid)
            .get();

        QuerySnapshot friendRequestSnapshot1 = await FirebaseFirestore.instance
            .collection('FriendRequests')
           .where('senderId', isEqualTo: widget.friendUid)
            .where('recipientId', isEqualTo: currentUser.uid)
            .get();
        QuerySnapshot friendRequestSnapshot2 = await FirebaseFirestore.instance
            .collection('FriendRequests')
           .where('senderId', isEqualTo: currentUser.uid)
            .where('recipientId', isEqualTo: widget.friendUid)
            .get();

        // Delete from FriendsOfUser subcollection
      QuerySnapshot friendsOfUserSnapshot1 = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('FriendsOfUser')
          .where('friendId', isEqualTo: widget.friendUid)
          .get();

      QuerySnapshot friendsOfUserSnapshot2 = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.friendUid)
          .collection('FriendsOfUser')
          .where('friendId', isEqualTo: currentUser.uid)
          .get();

        deleteFriendsOfUserDoc(friendsOfUserSnapshot1, batch);
        deleteFriendsOfUserDoc(friendsOfUserSnapshot2, batch);
        deleteFriendshipDoc(friendsSnapshot1, batch);
        deleteFriendshipDoc(friendsSnapshot2, batch);
        deleteFriendRequest(friendRequestSnapshot1, batch);
        deleteFriendRequest(friendRequestSnapshot2, batch);

        
        await batch.commit();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend removed')),
        );
        
        await _decrementFriendsCount(widget.friendUid);
        
        setState(() {
          _isFriend = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing friend: $e')),
      );
    }
  }

  Future<void> deleteFriendshipDoc(
      QuerySnapshot friendsSnapshot, WriteBatch batch) async {
    if (friendsSnapshot.size > 0) {
      friendsSnapshot.docs.forEach((doc) {
        batch.delete(doc.reference);
      });
    }
  }

  Future<void> deleteFriendRequest(
      QuerySnapshot friendRequestSnapshot, WriteBatch batch) async {
    if (friendRequestSnapshot.size > 0) {
      friendRequestSnapshot.docs.forEach((doc) {
        batch.delete(doc.reference);
      });
    }
  }

  Future<void> deleteFriendsOfUserDoc(
    QuerySnapshot friendsOfUserSnapshot, WriteBatch batch) async {
  if (friendsOfUserSnapshot.size > 0) {
      friendsOfUserSnapshot.docs.forEach((doc) {
        batch.delete(doc.reference);
      });
    }
}

  Future<void> _decrementFriendsCount(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        int currentFriendsCount = userSnapshot.get('friendsCount') ?? 0;
        await userSnapshot.reference.update({
          'friendsCount': currentFriendsCount - 1,
        });

        setState(() {
          _friendsCount = currentFriendsCount - 1;
        });
      }
    } catch (e) {
      print('Error decrementing friends count for user $userId: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context)
                        .customColors
                        .circularProgressIndicatorLight
                    : Theme.of(context)
                        .customColors
                        .circularProgressIndicatorDark,
              ),
            ))
          : Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : null,
                    child: _profileImageUrl == null
                        ? const Icon(Icons.person,
                            size: 60, color: Colors.black45)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    friendDisplayName,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_bio != null)
                    Text(
                      _bio!,
                      style: const TextStyle(
                          fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    _friendsCount == 1? '1 Friend' : '$_friendsCount Friends',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                 
                  if (_isFriend)
                    ElevatedButton(
                      onPressed: _removeFriend,
                      child: const Text('Remove Friend'),
                    )
                  else
                    const Text(
                      'Not a friend',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                ],
              ),
            ),
    );


  }
}
