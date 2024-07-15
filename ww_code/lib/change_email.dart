import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'aesthetics/textfield_style.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  ChangeEmailPageState createState() => ChangeEmailPageState();
}

class ChangeEmailPageState extends State<ChangeEmailPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _changeEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String newEmail = emailController.text.trim();
      String password = passwordController.text.trim();

      if (user != null) {
        if (user.providerData.any((info) => info.providerId == 'google.com')) {
          // If user is signed in with Google, show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Google users cannot change their email. Please change your email on the official site')),
          );
          return;
        }
        if (user.providerData.any((info) => info.providerId == 'password')) {
          // Reauthenticate with email and password
          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Re-authenticating...')),
          );
          await user.reauthenticateWithCredential(credential);
        } else if (user.providerData
            .any((info) => info.providerId == 'google.com')) {
          // Reauthenticate with Google
          GoogleSignIn googleSignIn = GoogleSignIn();
          GoogleSignInAccount? googleUser = await googleSignIn.signIn();
          if (googleUser == null) {
            // If user cancelled the sign-in
            return;
          }
          GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Re-authenticating with Google...')),
          );
          await user.reauthenticateWithCredential(credential);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Re-authentication successful!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unsupported sign-in method')),
          );
          return;
        }

        // Update email and send verification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updating email to: $newEmail')),
        );

        await user.updateEmail(newEmail);
        await user.sendEmailVerification();
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        CollectionReference users = firestore.collection('Users');
        await users.doc(user.uid).update({'email': newEmail});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Email successfully changed. Please verify your new email address.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to change email: $e')),
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
        title: const Text('Change Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            TextField(
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              decoration: TextFieldConfig.buildInputDecoration(
                hintText: 'Email',
                
                prefixIcon: const Icon(Icons.email, color: Colors.black45),
              ),
              controller: emailController,
            ),
            const SizedBox(height: 10),
            TextField(
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              decoration: TextFieldConfig.buildInputDecoration(
                hintText: 'Password',
                controller: passwordController,
                prefixIcon: const Icon(Icons.password, color: Colors.black45),
              ),
              controller: passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _changeEmail,
              child: const Text('Change Email'),
            ),
            const SizedBox(height: 20),
            Text(
              'For normal sign-in only. For Google users, please change your email on the official site.',
              style: TextStyle(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
