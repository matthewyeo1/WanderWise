import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'menu_page.dart';
import 'forgot_password.dart';
import 'create_account.dart';
import 'utilities/utils.dart';


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
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_toggleLoginButtonVisibility);
    _passwordFocusNode.addListener(_toggleLoginButtonVisibility);
  }

  @override
  void dispose() {
    _emailFocusNode.removeListener(_toggleLoginButtonVisibility);
    _passwordFocusNode.removeListener(_toggleLoginButtonVisibility);
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _toggleLoginButtonVisibility() {
    setState(() {
      _isLoginButtonVisible = !(_emailFocusNode.hasFocus || _passwordFocusNode.hasFocus);
    });
  }

  Future<void> _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    _logger.info('Attempting login with email: $email and password: $password');

    try {
      if (isValidEmail(email) && isValidPassword(password)) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MenuPage()),
        ).then((_) {
          _emailController.clear();
          _passwordController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password.'),
          ),
        );
      }
    } catch (e) {
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Add the logo here
            Image.asset('images/logo.png'),
            const SizedBox(height: 16), // Space between logo and text
            const Text(
              'Sign-in with your email & password:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: TextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: TextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
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
                  child: const Text('Forgot Password?'),
                ),
                TextButton(
                  onPressed: () => _navigateToCreateAccount(context),
                  child: const Text('Create Account'),
                ),
              ],
            ),
          ],
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
              child: const Icon(Icons.login),
            ),
            const SizedBox(height: 8),
            const Text('Login'),
          ],
        ),
      ),
    );
  }
}