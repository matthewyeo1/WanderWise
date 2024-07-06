import 'package:cloud_firestore/cloud_firestore.dart';

// Class for user info when finding/adding friends
class UserClass {
  final String uid;
  final String displayName;
  final String? profileImageUrl;
  final String? bio;
  final String? email;

  UserClass({
    required this.uid,
    required this.displayName,
    this.profileImageUrl,
    this.bio,
    this.email,
  });

  factory UserClass.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return UserClass(
      uid: snapshot.id,
      displayName: data['Username'] ?? '',
      email: data['email'] ?? '',
      profileImageUrl: data['profileImageUrl'],
    );
  }
}
