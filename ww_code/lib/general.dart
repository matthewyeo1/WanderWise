import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'change_email.dart';
import 'change_password.dart';
import 'aesthetics/themes.dart';

class GeneralSettingsPage extends StatefulWidget {
  const GeneralSettingsPage({super.key});

  @override
  _GeneralSettingsPageState createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage> {
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

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<ThemeNotifier>(
              builder: (context, themeNotifier, _) {
                return ListView(
                  children: [
                    const SizedBox(height: 50),
                    _buildSectionHeader('Security', theme),
                    _buildListTile(
                      context,
                      'Change Email',
                      const ChangeEmailPage(),
                      theme,
                    ),
                    _buildListTile(
                      context,
                      'Change Password',
                      const ChangePasswordPage(),
                      theme,
                    ),
                    const SizedBox(height: 50),
                    _buildSectionHeader('Display', theme),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SwitchListTile(
                        title: Text(
                          'Enable Dark Mode',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        value: userDarkModePreference,
                        onChanged: (value) {
                          setState(() {
                            themeNotifier.toggleTheme();
                            userDarkModePreference = value;
                          });
                          _saveUserDarkModePreference(value);
                        },
                        activeTrackColor:
                            const Color.fromARGB(255, 54, 54, 114),
                        activeColor: userDarkModePreference
                            ? Colors.white
                            : Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 50),
                    _buildSectionHeader('Account', theme),
                    _buildListTile(
                      context,
                      'Delete Account',
                      null,
                      theme,
                      isDestructive: true,
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(fontSize: 16),
      ),
    );
  }

  Widget _buildListTile(
      BuildContext context, String title, Widget? page, ThemeData theme,
      {bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListTile(
        title: Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 20,
            color: isDestructive ? Colors.red : null,
          ),
        ),
        onTap: () {
          if (page != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => page,
              ),
            );
          } else {
            _deleteAccountDialog(context);
          }
        },
      ),
    );
  }

  Future<void> _deleteAccountDialog(BuildContext context) async {
    String password = '';
    bool isPasswordEntered = false;
    bool isPasswordCorrect = false;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                "Delete Account",
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black),
              ),
              contentPadding: const EdgeInsets.all(40),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "WARNING: Your content will be lost forever!",
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.black),
                  ),
                  TextField(
                    cursorColor: Colors.lightBlue,
                    onChanged: (value) {
                      setState(() {
                        password = value;
                        isPasswordEntered = password.isNotEmpty;
                      });
                    },
                    style: const TextStyle(color: Colors.black),
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.black45),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "No",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: isPasswordEntered
                      ? () async {
                          try {
                            final User? user =
                                FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              final credential = EmailAuthProvider.credential(
                                email: user.email!,
                                password: password,
                              );
                              await user
                                  .reauthenticateWithCredential(credential);

                              isPasswordCorrect = true;

                              if (isPasswordCorrect) {
                                await FirebaseAuth.instance.currentUser
                                    ?.delete();
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/login', (route) => false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Account deleted successfully!'),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User not found'),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Incorrect password'),
                              ),
                            );
                            print("Error: $e");
                          }
                        }
                      : null,
                  child: Text(
                    "Yes",
                    style: TextStyle(
                        color: isPasswordEntered ? Colors.red : Colors.grey),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
