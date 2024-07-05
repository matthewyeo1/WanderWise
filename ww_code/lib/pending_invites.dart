import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingInvitesPage extends StatefulWidget {
  final String userId;

  const PendingInvitesPage({Key? key, required this.userId}) : super(key: key);

  @override
  PendingInvitesPageState createState() => PendingInvitesPageState();
}

class PendingInvitesPageState extends State<PendingInvitesPage> {

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
        Map<String, dynamic> requestData = requestSnapshot.data() as Map<String, dynamic>;
        String senderId = requestData['senderId'];
        String recipientId = requestData['recipientId'];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request accepted!')),
        );

        await _addFriendToCollection(senderId, recipientId);
        await _addFriendToCollection(recipientId, senderId);
        
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
      // Delete the friend request
      await FirebaseFirestore.instance
          .collection('FriendRequests')
          .doc(requestId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request rejected!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting friend request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Invites'),
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
                  return const Center(child: Text('No pending invites'));
                }

                return ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot doc) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    String senderDisplayName = data['senderDisplayName'] ?? 'Unknown User';
                    String requestId = doc.id;
                    return ListTile(
                      title: Text('$senderDisplayName sent you a friend request'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              _acceptFriendRequest(context, requestId);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
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
