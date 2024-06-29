import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'utilities/utils.dart';
import 'aesthetics/textfield_style.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  Future<void> resetPassword() async {
    String email = emailController.text;
    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid email."),
        ),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password reset email sent to $email."),
        ),
      );
      emailController.clear();
      print('Password reset email sent to $email.');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send password reset email: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.lightBlue,
        title: const Text('Forgot Password'),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'images/forgot_password.jpg',
                  height: MediaQuery.of(context).size.height * 0.4,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enter your email to reset your password:',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                const SizedBox(height: 16),
                TextField(
                  cursorColor: Colors.black,
                  style: const TextStyle(color: Colors.black),
                  decoration: TextFieldConfig.buildInputDecoration(
                    hintText: 'Email',
                    controller: emailController,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Send Password Reset Email',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
