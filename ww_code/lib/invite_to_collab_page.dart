import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ww_code/user/user_class.dart';
import 'package:ww_code/aesthetics/themes.dart';


class InviteToCollabPage extends StatefulWidget {
  final String userId;

  const InviteToCollabPage ({Key? key, required this.userId}) : super(key: key);

  @override
  InviteToCollabPageState createState() => InviteToCollabPageState();
}

class InviteToCollabPageState extends State<InviteToCollabPage> {
  late Future<List<UserClass>> friendsFuture;
  late User currentUser;
  List<String> selectedFriends = [];


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
          .where('userId', isEqualTo: currentUser.uid)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Friends to Collab'),
        actions: [
          if (selectedFriends.isNotEmpty)
            TextButton(
              onPressed: () {

              },
              child: Text('Invite'),),
        ],
      ),
      body: FutureBuilder<List<UserClass>>(
        future: friendsFuture,
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
            return const Center(child: Text('You have no friends to invite'));
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
                  trailing: Checkbox(       
                    value: selectedFriends.contains(friend.uid),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          selectedFriends.add(friend.uid);
                        } else {
                          selectedFriends.remove(friend.uid);
                        }
                      });
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}