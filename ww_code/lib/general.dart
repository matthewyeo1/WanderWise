import 'package:flutter/material.dart';
import 'change_email_password.dart';
import 'dark_mode.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
              title: const Text('Change Email/Password',
              style: TextStyle(fontSize: 20)
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChangeEmailPasswordPage()));
              },
            ),
            const SizedBox(height: 50),
            _buildSectionHeader('Display'),
            ListTile(
              title: const Text('Dark Mode',
              style: TextStyle(fontSize: 20)
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DarkModeSettingsPage()));
              },
            ),
            const SizedBox(height: 50),
            _buildSectionHeader('Account'),
            ListTile(
              title: const Text('Delete Account',
              style: TextStyle(
                fontSize: 20,
                color: Colors.red,
                )
              ),
              onTap: () {
                _deleteAccountDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.black45),
      ),
    );
  }

  Future<void> _deleteAccountDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text("Are you sure you want to delete your account?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: const Text("No",
              style: TextStyle(color: Color(0xFF00A6DF))
              ),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.currentUser?.delete();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false); // Redirect to login page
              },
              child: const Text("Yes",
              style: TextStyle(color: Color(0xFF00A6DF))
              ),
            ),
          ],
        );
      },
    );
  }
}
