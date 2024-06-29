import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ww_code/aesthetics/themes.dart';

// Load user's theme preference upon login
class ThemeService {
  Future<void> loadUserThemePreference(String userId, ThemeNotifier themeNotifier) async {
    bool isDarkMode = false;
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      if (doc.exists && doc['darkMode'] != null) {
        isDarkMode = doc['darkMode'];
      }
    } catch (e) {
      print('Error loading theme preference: $e');
    }
    themeNotifier.initialize(userId, isDarkMode);
  }

  Future<bool> getUserDarkModePreference(User user) async {
    try {
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        return doc.get('darkMode') ?? false;
      }
    } catch (e) {
      print('Error getting user preference: $e');
    }
    return false;
  }
}

