import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'utilities/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'aesthetics/textfield_style.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _usernameFocusNode.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  Future<void> createAccount() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String email = _emailController.text;

    // Convert to lower case
    String usernameLowerCase = username.toLowerCase();

    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email.'),
        ),
      );
      return;
    }

    if (!isValidUsername(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username must be between 4-15 characters.'),
        ),
      );
      return;
    }

    if (!isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Password must be between 12-20 characters and must contain at least one special character.'),
        ),
      );
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(username);

      // Store user credentials in firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user?.uid)
          .set({
        'Username': username,
        'UsernameLowerCase': usernameLowerCase,
        'email': email,
        'friendsCount': 0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
        ),
      );
      Navigator.pop(context, username);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create account: $e'),
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
        title: const Text('Sign Up'),
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
                  'images/signup.png',
                  height: MediaQuery.of(context).size.height * 0.3,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enter your details to sign up:',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                const SizedBox(height: 16),
                TextField(
                  cursorColor: Colors.black,
                  style: const TextStyle(color: Colors.black),
                  decoration: TextFieldConfig.buildInputDecoration(
                    hintText: 'Username',
                    focusNode: _usernameFocusNode,
                  ),
                  controller: _usernameController,
                ),
                const SizedBox(height: 16),
                TextField(
                  cursorColor: Colors.black,
                  style: const TextStyle(color: Colors.black),
                  decoration: TextFieldConfig.buildInputDecoration(
                    hintText: 'Email',
                    focusNode: _emailFocusNode,
                  ),
                  controller: _emailController,
                ),
                const SizedBox(height: 16),
                TextField(
                  cursorColor: Colors.black,
                  style: const TextStyle(color: Colors.black),
                  decoration: TextFieldConfig.buildInputDecoration(
                    hintText: 'Password',
                    focusNode: _passwordFocusNode,
                  ),
                  controller: _passwordController,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: createAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
