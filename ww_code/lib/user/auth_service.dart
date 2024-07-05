import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthServiceLogin {
  final Logger _logger = Logger('AuthServiceLogin');
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<UserCredential?> login(String email, String password) async {
    _logger.info('Attempting login with email: $email');
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _logger.warning('Failed to sign in: $e');
      rethrow;
    }
  }

  Future<UserCredential?> handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      _logger.warning('Failed to sign in with Google: $e');
      rethrow;
    }
  }
}

class AuthServiceItinerary {
  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> updateUserData(User user) async {
    try {
      final String? displayName = user.displayName;
      final String? email = user.email;

      Map<String, dynamic> userData = {
        'Username': displayName ?? '',
        'email': email ?? '',
        'UsernameLowerCase': displayName != null ? displayName.toLowerCase() : '',
      };

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      
      rethrow;
    }
  }
}
