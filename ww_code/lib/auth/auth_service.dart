import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';

// Verify user's credentials upon login
class AuthServiceLogin {
  final Logger _logger = Logger('AuthService');
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

// Verify authenticated user in itinerary page
class AuthServiceItinerary {
  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }
}