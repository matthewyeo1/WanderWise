import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'utilities/utils.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings Page Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ChangePasswordPage(),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ChangePasswordPageState createState() => ChangePasswordPageState();
}

class ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  var auth = FirebaseAuth.instance;
  var currentUser = FirebaseAuth.instance.currentUser;

  Future<void> changePassword(
      {required String currentPassword, required String newPassword}) async {
    try {
      var cred = EmailAuthProvider.credential(
          email: currentUser!.email!, password: currentPassword);
      await currentUser!.reauthenticateWithCredential(cred);
      await currentUser!.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed successfully")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${error.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 134, 134, 134),
        title: const Text('Change Password'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: currentPasswordController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                isDense: true,
                alignLabelWithHint: true,
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPasswordController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                isDense: true,
                alignLabelWithHint: true,
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmNewPasswordController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                isDense: true,
                alignLabelWithHint: true,
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (!(isValidEmail(newPasswordController.text)) ||
                    isValidPassword(confirmNewPasswordController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            "Password is not 12 to 20 characters long or does not contain special characters")),
                  );
                }
                if (newPasswordController.text ==
                    confirmNewPasswordController.text) {
                  await changePassword(
                    currentPassword: currentPasswordController.text,
                    newPassword: newPasswordController.text,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("New passwords do not match")),
                  );
                }
              },
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }
}
