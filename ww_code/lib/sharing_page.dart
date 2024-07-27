import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:ww_code/user/user_class.dart';
import 'package:ww_code/aesthetics/themes.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'localization/locales.dart';

class ShareWithUsersPage extends StatefulWidget {
  final String itineraryId;
  final String userId;

  const ShareWithUsersPage(
      {Key? key, required this.itineraryId, required this.userId})
      : super(key: key);

  @override
  ShareWithUsersPageState createState() => ShareWithUsersPageState();
}

class ShareWithUsersPageState extends State<ShareWithUsersPage> {
  late Future<List<UserClass>> friendsFuture;
  late User currentUser;
  List<String> selectedFriends = [];

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!;
    friendsFuture = _getFriends();
    initializeNotifications();
  }

  void initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        print('Notification received: ${details.payload}');

        if (details.payload != null) {}
      },
    );
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
        String friendId = doc.id;
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

      List<String> invitedUsernames =
          []; // List to store usernames of invited friends

      for (String friendId in selectedFriends) {
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

        // Get the current itinerary details (only if not already set)
        DocumentSnapshot friendItinerarySnapshot =
            await friendItineraryRef.get();

        // Get the current itinerary details
        if (!friendItinerarySnapshot.exists) {
          DocumentSnapshot itinerarySnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc(widget.userId)
              .collection('Itineraries')
              .doc(widget.itineraryId)
              .get();

          String updatedTitle =
              '${itinerarySnapshot['title']} (shared by ${currentUser.displayName})';

          // Set the friend's itinerary with the same details
          batch.set(friendItineraryRef, {
            'ownerId': widget.userId,
            'title': updatedTitle,
            'startDate': itinerarySnapshot['startDate'],
            'endDate': itinerarySnapshot['endDate'],
            'description': itinerarySnapshot['description'],
          });
        }

        // Retrieve friend's username
        DocumentSnapshot friendDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.userId)
            .collection('FriendsOfUser')
            .doc(friendId)
            .get();

        if (friendDoc.exists) {
          String username = friendDoc[
              'friendDisplayName']; // Assuming username is a field in UserClass
          invitedUsernames.add(username);
          _sendNotification(friendId, username);
        }
      }

      await batch.commit();

      String invitedUsersText =
          invitedUsernames.join(', '); // Join usernames with commas
      String snackbarMessage = context.formatString(LocaleData.shared, [invitedUsersText]);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snackbarMessage)),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error inviting friends: $e');
      
    }
  }

  void _sendNotification(String friendId, String friendUsername) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Fetch the recipient's display name (user B's display name)
    DocumentSnapshot recipientSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(friendId)
        .get();

    String recipientName = recipientSnapshot['displayName'];

    await flutterLocalNotificationsPlugin.show(
      0,
      LocaleData.sharedTitle.getString(context),
      context.formatString(LocaleData.sharedMessage, [recipientName]),
      platformChannelSpecifics,
      payload: 'ID:${widget.itineraryId}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleData.shareWithFriends.getString(context)),
        actions: [
          if (selectedFriends.isNotEmpty)
            TextButton(
              onPressed: _inviteFriends,
              child: Text(LocaleData.shareButton.getString(context)),
            ),
        ],
      ),
      body: FutureBuilder<List<UserClass>>(
        future: friendsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
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
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(LocaleData.noFriends.getString(context)));
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
