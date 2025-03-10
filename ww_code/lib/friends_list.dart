import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ww_code/user/user_class.dart';
import 'package:ww_code/view_friend_page.dart';
import 'package:ww_code/aesthetics/themes.dart';

class FriendsListPage extends StatefulWidget {
  final String userId;

  const FriendsListPage({Key? key, required this.userId}) : super(key: key);

  @override
  FriendsListPageState createState() => FriendsListPageState();
}

class FriendsListPageState extends State<FriendsListPage> {
  late User currentUser;
  late Future<List<UserClass>> friendsFuture;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!;
    friendsFuture = _getFriends();
  }

  Future<List<UserClass>> _getFriends() async {
    try {
      QuerySnapshot friendsSnapshot = await FirebaseFirestore.instance
          .collection('Friends')
          .where('userId', isEqualTo: widget.userId)
          .get();

      List<UserClass> friends = [];
      for (QueryDocumentSnapshot doc in friendsSnapshot.docs) {
        String friendId = doc['friendId'];
        DocumentSnapshot friendDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(friendId)
            .get();

        if (friendDoc.exists) {
          UserClass friend = UserClass.fromSnapshot(friendDoc);
          friends.add(friend);
        }
      }
      return friends;
    } catch (e) {
      print('Error fetching friends: $e');
      return [];
    }
  }

   Future<void> _refreshFriends() async {
    setState(() {
      friendsFuture = _getFriends();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends List'),
      ),
      body: FutureBuilder<List<UserClass>>(
        future: _getFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context)
                        .customColors
                        .circularProgressIndicatorLight
                    : Theme.of(context)
                        .customColors
                        .circularProgressIndicatorDark,
              ),
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('You have no friends yet.'));
          } else {
            List<UserClass> friends = snapshot.data!;
            return ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                UserClass friend = friends[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black45,
                    backgroundImage: friend.profileImageUrl != null
                        ? NetworkImage(friend.profileImageUrl!)
                        : null,
                    child: friend.profileImageUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(friend.displayName),
                  onTap: () async {
                    final bool result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewFriendPage(
                          friendUid: friend.uid,
                          
                        ),
                      ),
                    );
                    if (result) {
                      setState(() {
                        _refreshFriends();
                      });
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
