import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

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
      home: const MyHomePage(title: 'WanderWise'),
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

  void _login() {
    String username = _usernameController.text;
    String password = _passwordController.text;
    _logger.info('Attempting login with username: $username and password: $password');
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Enter your username & password:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
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
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Login',
        onPressed: _login,
        child: const Icon(Icons.login),
      ),
    );
  }
}

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    void resetPassword() {
      String email = emailController.text;
      if(!_isValidEmail(email)){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid email.'),
            ),
          );
          return;
      }
      print('Password reset email sent to $email');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Forgot Password'),
      ),
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

      if(!_isValidPassword(username)) {
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
