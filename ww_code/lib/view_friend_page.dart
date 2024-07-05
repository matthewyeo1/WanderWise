import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewFriendPage extends StatefulWidget {
  final String friendUid;
  final String friendDisplayName;

  const ViewFriendPage({
    Key? key,
    required this.friendUid,
    required this.friendDisplayName,
  }) : super(key: key);

  @override
  ViewFriendPageState createState() => ViewFriendPageState();
}

class ViewFriendPageState extends State<ViewFriendPage> {
  String? _profileImageUrl;
  String? _bio;
  int _friendsCount = 0;
  bool _isFriend = true;

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
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading friend profile'),
        ),
      );
    }
  }

  Future<void> _checkFriendStatus() async {
  User currentUser = FirebaseAuth.instance.currentUser!;
  
  // Check if currentUser's UID is in friend's document
  DocumentSnapshot currentUserFriendDoc = await FirebaseFirestore.instance
      .collection('Friends')
      .doc('${widget.friendUid}_${currentUser.uid}')
      .get();

  // Check if friend's UID is in currentUser's document
  DocumentSnapshot friendUserFriendDoc = await FirebaseFirestore.instance
      .collection('Friends')
      .doc('${currentUser.uid}_${widget.friendUid}')
      .get();

  setState(() {
    _isFriend = currentUserFriendDoc.exists && friendUserFriendDoc.exists;
  });
}


  Future<void> _removeFriend() async {
    User currentUser = FirebaseAuth.instance.currentUser!;
    try {
      // Show confirmation dialog
      bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Remove Friend'),
            content: const Text('Are you sure you want to remove this friend?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
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
        DocumentReference friendDoc1 = FirebaseFirestore.instance
            .collection('Friends')
            .doc('${currentUser.uid}_${widget.friendUid}');
        DocumentReference friendDoc2 = FirebaseFirestore.instance
            .collection('Friends')
            .doc('${widget.friendUid}_${currentUser.uid}');
        
        batch.delete(friendDoc1);
        batch.delete(friendDoc2);

        // Update friends count
        DocumentReference userDoc = FirebaseFirestore.instance.collection('Users').doc(currentUser.uid);
        DocumentReference friendDoc = FirebaseFirestore.instance.collection('Users').doc(widget.friendUid);
        
        batch.update(userDoc, {'friendsCount': FieldValue.increment(-1)});
        batch.update(friendDoc, {'friendsCount': FieldValue.increment(-1)});
        
        await batch.commit();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend removed')),
        );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.friendDisplayName}'s Profile"),
      ),
      body: Padding(
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
                  ? const Icon(Icons.person, size: 60, color: Colors.black45) 
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              widget.friendDisplayName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_bio != null)
              Text(
                _bio!,
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            const SizedBox(height: 16),
            Text(
              'Friends: $_friendsCount',
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
