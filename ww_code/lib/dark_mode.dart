import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'aesthetics/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DarkModeSettingsPage extends StatefulWidget {
  const DarkModeSettingsPage({super.key});

  @override
  _DarkModeSettingsPageState createState() => _DarkModeSettingsPageState();
}

class _DarkModeSettingsPageState extends State<DarkModeSettingsPage> {
  late String? userId;
  bool isLoading = true;
  bool userDarkModePreference = false;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      await _getUserDarkModePreference();
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _getUserDarkModePreference() async {
    try {
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      if (doc.exists) {
        setState(() {
          userDarkModePreference = doc.get('darkMode') ?? false;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error getting user preference: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveUserDarkModePreference(bool darkMode) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .set({'darkMode': darkMode}, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user preference: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dark Mode Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Consumer<ThemeNotifier>(
                builder: (context, themeNotifier, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 100),
                      SwitchListTile(
                        title: Text(
                          'Enable Dark Mode',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        value: userDarkModePreference,
                        onChanged: (value) {
                          setState(() {
                            themeNotifier.toggleTheme();
                            userDarkModePreference = value;
                          });
                          _saveUserDarkModePreference(value);
                        },
                        activeTrackColor: const Color.fromARGB(255, 54, 54, 114),
                        activeColor: userDarkModePreference
                            ? Colors.white
                            : Colors.black45,
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Toggle dark mode',
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
