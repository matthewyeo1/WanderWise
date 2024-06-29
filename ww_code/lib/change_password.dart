import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'utilities/utils.dart';
import 'aesthetics/textfield_style.dart';

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

  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> changePassword(
      {required String currentPassword, required String newPassword}) async {
    try {
      if (currentUser == null) {
        throw FirebaseAuthException(
          code: 'no-current-user',
          message: 'No user is currently signed in.',
        );
      }
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: currentPassword,
      );
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.updatePassword(newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed successfully!")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${error.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
                 TextFormField(
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              decoration: TextFieldConfig.buildInputDecoration(
                hintText: 'Current Password',
                 controller: currentPasswordController,
              ),
            ),
            const SizedBox(height: 10),
             TextField(
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              decoration: TextFieldConfig.buildInputDecoration(
                hintText: 'New Password',
                obscureText: true,
                controller: newPasswordController,
              ),
            ),
            const SizedBox(height: 10),
             TextField(
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              decoration: TextFieldConfig.buildInputDecoration(
                hintText: 'Confirm New Password',
                obscureText: true,
                controller: confirmNewPasswordController,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (!isValidPassword(newPasswordController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Password must be 12 to 20 characters long and contain special characters"),
                    ),
                  );
                  return;
                }
                // Check if old and new passwords match
                if (currentPasswordController.text == newPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("New password cannot be the same as the current password")),
                  );
                  return;
                }
                // Check if new passwords match
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
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Text(
                'Remember your new password once you have created it!',
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
