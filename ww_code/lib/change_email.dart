import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
        if (user.providerData.any((info) => info.providerId == 'password')) {
          // Reauthenticate with email and password
          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changing email...')),
          );
          await user.reauthenticateWithCredential(credential);
        } else if (user.providerData.any((info) => info.providerId == 'google.com')) {
          // Reauthenticate with Google
          GoogleSignIn googleSignIn = GoogleSignIn();
          GoogleSignInAccount? googleUser = await googleSignIn.signIn();
          if (googleUser == null) {
            // If user cancelled the sign-in
            return;
          }
          GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Re-authenticating with Google')
            ),
          );
          await user.reauthenticateWithCredential(credential);
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Re-authentication successful!')
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unsupported sign-in method')),
          );
          return;
        }

        // Update email
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Updating email to: $newEmail')),
          );
        await user.verifyBeforeUpdateEmail(newEmail);
        await FirebaseAuth.instance.currentUser?.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email successfully changed. Please verify your new email address.')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Email'),
      ),
      body:  Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
           const SizedBox(height: 100),
            TextField(
              cursorColor: Colors.black,
              controller: emailController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(255, 208, 208, 208),
                prefixIcon: Icon(Icons.email, color: Colors.black45),
                hintText: 'New Email',
                    hintStyle: TextStyle(color: Colors.black45),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              cursorColor: Colors.black,
              controller: passwordController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(255, 208, 208, 208),
                prefixIcon: Icon(Icons.password, color: Colors.black45),
                hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.black45),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height:10),
            ElevatedButton(
              onPressed: _changeEmail,
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    ); 
  }
}