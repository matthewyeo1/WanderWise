import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'menu_page.dart';

void main() {
  _setupLogging();
  runApp(const MyApp());
}

void _setupLogging() {
  // Configure the logging framework
  Logger.root.level = Level.ALL; // Set the root logger level to ALL
  Logger.root.onRecord.listen((LogRecord record) {
  print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

bool _isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

bool _isValidUsername(String username) {
  return username.length >= 4 && username.length <= 15;
}

bool _isValidPassword(String password) {
  return password.length >= 12 && password.length <= 20 && RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
}
//main widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WanderWise App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Login'),
      debugShowCheckedModeBanner: false,
    );
  }
}
//login screen
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
//username and password text fields for login(), forgotpassword(), creataccount() & the UI rendering (build)
class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Logger _logger = Logger('MyHomePage');
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isLoginButtonVisible = true;

  @override
  void initState() {
    super.initState();
    _usernameFocusNode.addListener(_toggleLoginButtonVisibility);
    _passwordFocusNode.addListener(_toggleLoginButtonVisibility);
  }

  @override
  void dispose() {
    _usernameFocusNode.removeListener(_toggleLoginButtonVisibility);
    _passwordFocusNode.removeListener(_toggleLoginButtonVisibility);
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _toggleLoginButtonVisibility() {
    setState(() {
      _isLoginButtonVisible = !(_usernameFocusNode.hasFocus || _passwordFocusNode.hasFocus);
    });
  }

  void _login() {
    String username = _usernameController.text;
    String password = _passwordController.text;
    _logger.info('Attempting login with username: $username and password: $password');

    if(_isValidUsername(username) && _isValidPassword(password)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MenuPage()),
      ).then((_) {
        _usernameController.clear();
        _passwordController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid username or password.'),
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
              'Enter your username & password:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: TextField(
                controller: _usernameController,
                focusNode: _usernameFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Username',
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


class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();  
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  String message = '';

  void resetPassword(){
    String email = emailController.text;
    if(!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter valid email."),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Password reset email sent to $email."),
      ),
    );
    print('Password reset email sent to $email.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Forgot Password'),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Enter your email to reset your password:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: resetPassword,
                child: const Text('Reset Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateAccountPage extends StatelessWidget {
  const CreateAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    void createAccount() {
      String username = usernameController.text;
      String password = passwordController.text;
      String email = emailController.text;
      
      if(!_isValidEmail(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid email.'),
          ),
        );
        return;
      }

      if(!_isValidUsername(username)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username must be between 4-15 characters.'),
          ),
        );
        return;
      }

      if(!_isValidPassword(password)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password must be between 12-20 characters and must contain at least one special character.'),
          ),
        );
        return;
      }

      print('Creating account for username: $username, email: $email, password: $password');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Create New Account'),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Enter your details to create a new account:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: createAccount,
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
