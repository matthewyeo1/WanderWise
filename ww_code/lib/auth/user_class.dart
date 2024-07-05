// Class for user info when finding/adding friends
class UserClass {
  final String uid;
  final String displayName;
  final String? profileImageUrl;
  final String? bio;

  UserClass({
    required this.uid,
    required this.displayName,
    this.profileImageUrl,
    this.bio,
  });
}
