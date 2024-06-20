import 'package:flutter/material.dart';
import 'change_email_password.dart';
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
          ListTile(
            title: Text(
              'Change Email/Password',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 20),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangeEmailPasswordPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 50),
          _buildSectionHeader('Display', theme),
          ListTile(
            title: Text(
              'Dark Mode',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 20),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DarkModeSettingsPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 50),
          _buildSectionHeader('Account', theme),
          ListTile(
            title: Text(
              'Delete Account',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 20,
                color: Colors.red,
              ),
            ),
            onTap: () {
              _deleteAccountDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(fontSize: 16),
      ),
    );
  }

  Future<void> _deleteAccountDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        return AlertDialog(
          title: Text(
            "Delete Account",
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black),
          ),
          content: Text(
            "WARNING: Your content will be lost forever!",
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "No",
                style: TextStyle(color: Color(0xFF00A6DF)),
              ),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.currentUser?.delete();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text(
                "Yes",
                style: TextStyle(color: Color(0xFF00A6DF)),
              ),
            ),
          ],
        );
      },
    );
  }
}
