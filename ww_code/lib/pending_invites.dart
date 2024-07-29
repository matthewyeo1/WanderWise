import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'localization/locales.dart';

class PendingInvitesPage extends StatefulWidget {
  final String userId;

  const PendingInvitesPage({Key? key, required this.userId}) : super(key: key);

  @override
  PendingInvitesPageState createState() => PendingInvitesPageState();
}

class PendingInvitesPageState extends State<PendingInvitesPage> {
  int pendingInvitesCount = 0;

  @override
  void initState() {
    super.initState();
    fetchPendingInvitesCount();
  }

  Future<void> _acceptFriendRequest(BuildContext context, String requestId) async {
    try {
      // Update status to 'accepted' in FriendRequests collection
      await FirebaseFirestore.instance
          .collection('FriendRequests')
          .doc(requestId)
          .update({'status': 'accepted'});

      // Get friend request details
      DocumentSnapshot requestSnapshot = await FirebaseFirestore.instance
          .collection('FriendRequests')
          .doc(requestId)
          .get();

      if (requestSnapshot.exists) {
        Map<String, dynamic> requestData =
            requestSnapshot.data() as Map<String, dynamic>;
        String senderId = requestData['senderId'];
        String recipientId = requestData['recipientId'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocaleData.acceptRequest.getString(context))),
        );

        await _addFriendToCollection(senderId, recipientId);
        await _addFriendToCollection(recipientId, senderId);

        // Update friendsCount for both sender and recipient
        await _incrementFriendsCount(senderId);
        await _incrementFriendsCount(recipientId);

        // Delete the friend request from recipient's PendingInvites
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.userId)
            .collection('PendingInvites')
            .doc(requestId)
            .delete();

        // Get sender's display name
        DocumentSnapshot senderSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(senderId)
            .get();

        if (senderSnapshot.exists) {
          String senderDisplayName = senderSnapshot.get('Username') ?? 'Unknown User';

          // Add sender to recipient's FriendsOfUser collection
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(recipientId)
              .collection('FriendsOfUser')
              .doc(senderId)
              .set({
                'friendId': senderId,
                'friendDisplayName': senderDisplayName,
              });
        }

        // Get recipient's display name
        DocumentSnapshot recipientSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(recipientId)
            .get();

        if (recipientSnapshot.exists) {
          String recipientDisplayName = recipientSnapshot.get('Username') ?? 'Unknown User';

          // Add recipient to sender's FriendsOfUser collection
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(senderId)
              .collection('FriendsOfUser')
              .doc(recipientId)
              .set({
                'friendId': recipientId,
                'friendDisplayName': recipientDisplayName,
              });
        }

        // Update pending invites count
        fetchPendingInvitesCount();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting friend request: $e')),
      );
    }
  }

  Future<void> _addFriendToCollection(String userId, String friendId) async {
    await FirebaseFirestore.instance.collection('Friends').add({
      'userId': userId,
      'friendId': friendId,
      'status': 'accepted',
    });
  }

  Future<void> _rejectFriendRequest(BuildContext context, String requestId) async {
    try {
      // Get the friend request details to determine the recipient
      DocumentSnapshot requestSnapshot = await FirebaseFirestore.instance
          .collection('FriendRequests')
          .doc(requestId)
          .get();

      if (!requestSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request not found!')),
        );
        return;
      }

      // Delete the friend request
      await FirebaseFirestore.instance
          .collection('FriendRequests')
          .doc(requestId)
          .delete();

      // Delete the friend request from recipient's PendingInvites
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .collection('PendingInvites')
          .doc(requestId)
          .delete();

      // Update pending invites count
      fetchPendingInvitesCount();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleData.rejectRequest.getString(context))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting friend request: $e')),
      );
    }
  }

  Future<void> fetchPendingInvitesCount() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .collection('PendingInvites')
          .get();

      setState(() {
        pendingInvitesCount = querySnapshot.size; // Update the count based on the query result
      });
    } catch (e) {
      print('Error fetching pending invites count: $e');
      
    }
  }

  Future<void> _incrementFriendsCount(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        int currentFriendsCount = userSnapshot.get('friendsCount') ?? 0;
        await userSnapshot.reference.update({
          'friendsCount': currentFriendsCount + 1,
        });
      }
    } catch (e) {
      print('Error incrementing friends count for user $userId: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleData.pendingInvitesTitle.getString(context)),
      ),
      body: widget.userId.isEmpty
          ? const Center(child: Text('User ID is empty'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('FriendRequests')
                  .where('recipientId', isEqualTo: widget.userId)
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'images/empty_pending_invites.png',
                          height: 200,
                        ),
                        const SizedBox(height: 16),
                        Text(LocaleData.backgroundText7.getString(context), style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                  );
                }

                return ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot doc) {
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;
                    String senderDisplayName =
                        data['senderDisplayName'] ?? 'Unknown User';
                    String requestId = doc.id;
                    return ListTile(
                      title:
                          Text(context.formatString(LocaleData.pendingRequest.getString(context), [senderDisplayName])),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check,
                            color: Colors.green),
                            onPressed: () {
                              _acceptFriendRequest(context, requestId);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close,
                            color: Colors.red),
                            onPressed: () {
                              _rejectFriendRequest(context, requestId);
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
