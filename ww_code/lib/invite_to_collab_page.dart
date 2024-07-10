import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ww_code/user/user_class.dart'; // Adjust import based on your actual user class location
import 'package:ww_code/aesthetics/themes.dart';

class InviteToCollabPage extends StatefulWidget {
  final String itineraryId; // Added itineraryId to pass from MapItineraryPage
  final String userId;

  const InviteToCollabPage({Key? key, required this.itineraryId, required this.userId}) : super(key: key);

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
        .collection('Users')
        .doc(currentUser.uid)
        .collection('FriendsOfUser')
        .get();

    List<UserClass> friends = [];
    for (QueryDocumentSnapshot doc in friendsSnapshot.docs) {
      String friendId = doc.id; // Assuming the friendId is the document ID
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


  Future<void> _inviteFriends() async {
  try {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (String friendId in selectedFriends) {
      // Add friend as collaborator in the itinerary's Collaborators subcollection
      DocumentReference collaboratorRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .collection('Itineraries')
          .doc(widget.itineraryId)
          .collection('Collaborators')
          .doc(friendId);

      // Set collaborator document with necessary fields
      batch.set(collaboratorRef, {
        'userId': friendId,
        'invitedBy': widget.userId,
        'status': 'invited',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Add the itinerary to the friend's Itineraries subcollection
      DocumentReference friendItineraryRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(friendId)
          .collection('Itineraries')
          .doc(widget.itineraryId);

      // Get the current itinerary details
      DocumentSnapshot itinerarySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .collection('Itineraries')
          .doc(widget.itineraryId)
          .get();

      // Set the friend's itinerary with the same details
      batch.set(friendItineraryRef, {
        'ownerId': widget.userId,
        'title': itinerarySnapshot['title'],
        'startDate': itinerarySnapshot['startDate'],
        'endDate': itinerarySnapshot['endDate'],
        'description': itinerarySnapshot['description'],
      });
    }

    // Commit batch write
    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friends invited to collaborate!')),
    );

    // Navigate back or perform any other action after inviting friends
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error inviting friends: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Friends to Collaborate'),
        actions: [
          if (selectedFriends.isNotEmpty)
            TextButton(
              onPressed: _inviteFriends,
              child: const Text('Invite'),
            ),
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
