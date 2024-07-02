import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgot_password.dart';
import 'create_account.dart';
import 'utilities/utils.dart';
import 'aesthetics/themes.dart';
import 'package:ww_code/auth/auth_service.dart';
import 'package:ww_code/aesthetics/themes_service.dart';
import 'aesthetics/textfield_style.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

// Handle UI Rendering
class MyHomePageState extends State<MyHomePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final AuthServiceLogin authService = AuthServiceLogin();
  final ThemeService themeService = ThemeService();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> login() async {
    String email = emailController.text;
    String password = passwordController.text;

    if (isValidEmail(email) && isValidPassword(password)) {
      try {
        UserCredential? userCredential = await authService.login(email, password);
        if (userCredential != null) {
          String userId = userCredential.user!.uid;
          await themeService.loadUserThemePreference(
            userId,
            Provider.of<ThemeNotifier>(context, listen: false),
          );
          Navigator.pushReplacementNamed(context, '/menu').then((_) {
            emailController.clear();
            passwordController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Logged in as $userId'),
              ),
            );
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign in: $e'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email or password.'),
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      UserCredential? userCredential = await authService.handleGoogleSignIn();
      if (userCredential != null) {
        String userId = userCredential.user!.uid;
        await themeService.loadUserThemePreference(
          userId,
          Provider.of<ThemeNotifier>(context, listen: false),
        );
        Navigator.pushReplacementNamed(context, '/menu');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to sign in with Google.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in with Google: $e'),
        ),
      );
    }
  }

  void _navigateToForgotPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
  }

  void _navigateToCreateAccount(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateAccountPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 16),
                Image.asset(
                  'images/login.png',
                  height: MediaQuery.of(context).size.height * 0.3,
                ),
                const SizedBox(height: 1),
                const Text(
                  'Hello, Wanderer!',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Sign in with your email & password:',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                const SizedBox(height: 16),
                TextField(
                  cursorColor: Colors.black,
                  controller: emailController,
                  focusNode: emailFocusNode,
                  style: const TextStyle(color: Colors.black),
                  decoration: TextFieldConfig.buildInputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.person, color: Colors.black45),
                    focusNode: emailFocusNode,
                    controller: emailController,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  cursorColor: Colors.black,
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  style: const TextStyle(color: Colors.black),
                  decoration: TextFieldConfig.buildInputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock, color: Colors.black45),
                    focusNode: passwordFocusNode,
                    controller: passwordController,
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => _navigateToForgotPassword(context),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey[700],
                        thickness: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'or',
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Divider(
                        color: Colors.grey[700],
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _handleGoogleSignIn,
                  icon: Image.asset(
                    'images/google_logo.png',
                    height: 18,
                    width: 18,
                  ),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.black),
                    ),
                    TextButton(
                      onPressed: () => _navigateToCreateAccount(context),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
