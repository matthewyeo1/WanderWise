import 'package:flutter/material.dart';
import 'change_email_password.dart';
import 'dark_mode.dart';
import 'delete_account.dart';

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: ListView(
          children: [
            const SizedBox(height: 50),
            _buildSectionHeader('Security'),
            ListTile(
              title: const Text('Change Email/Password'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChangeEmailPasswordPage()));
              },
            ),
            const SizedBox(height: 50),
            _buildSectionHeader('Display'),
            ListTile(
              title: const Text('Dark Mode'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DarkModeSettingsPage()));
              },
            ),
            const SizedBox(height: 50),
            _buildSectionHeader('Account'),
            ListTile(
              title: const Text('Delete Account'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DeleteAccountPage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, color: Colors.black45),
      ),
    );
  }
}
