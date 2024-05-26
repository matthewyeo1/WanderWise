import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgot_password.dart';
import 'create_account.dart';
import 'utilities/utils.dart';
import 'aesthetics/colour_gradient.dart';

// Login page
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Logger _logger = Logger('MyHomePage');
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isLoginButtonVisible = true;

  @override
  void initState() {   // Textfields for email & password inputs
    super.initState();
    _emailFocusNode.addListener(_toggleLoginButtonVisibility);
    _passwordFocusNode.addListener(_toggleLoginButtonVisibility);
  }

  @override
  void dispose() {    // To free up resources used 
    _emailFocusNode.removeListener(_toggleLoginButtonVisibility);
    _passwordFocusNode.removeListener(_toggleLoginButtonVisibility);
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _toggleLoginButtonVisibility() {     // Login button disappears when keyboard is accessed when entering email & password 
    setState(() {
      _isLoginButtonVisible =
          !(_emailFocusNode.hasFocus || _passwordFocusNode.hasFocus);
    });
  }

  Future<void> _login() async {        // Firebase authentication triggers when email & password is entered
    String email = _emailController.text;
    String password = _passwordController.text;
    _logger.info('Attempting login with email: $email and password: $password');

    try {                                                              
      if (isValidEmail(email) && isValidPassword(password)) {               // Navigate to menu page if there is a match...
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        Navigator.pushReplacementNamed(context, '/menu').then((_) {         // ...and clear the textfields for email and password
          _emailController.clear();
          _passwordController.clear();
        });       
      } else {                                                              // If mismatch and/or email & password do not satisfy required conditions 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password.'),
          ),
        );
      }
    } catch (e) {                                                           // Error
      _logger.warning('Failed to sign in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in: $e'),
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
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: getAppGradient(),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Add the logo here

              const SizedBox(height: 16), 
              const Text(
                'Sign-in with your email & password:',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: TextField(
                  cursorColor: Colors.white,
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: TextField(
                  cursorColor: Colors.white,
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => _navigateToForgotPassword(context),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _navigateToCreateAccount(context),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: _isLoginButtonVisible,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              tooltip: 'Login',
              onPressed: _login,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white, 
              elevation: 0, 
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login),
                  SizedBox(height: 4),
                  Text(
                    'Login',
                    style: TextStyle(
                        fontSize: 12
                    ), 
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
