import 'package:flutter/material.dart';
import 'change_email.dart';
import 'change_password.dart';
import 'dark_mode.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
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
          _buildListTile(
            context,
            'Dark Mode',
            const DarkModeSettingsPage(),
            theme,
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
                                    content: Text('Account deleted successfully!'),
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
