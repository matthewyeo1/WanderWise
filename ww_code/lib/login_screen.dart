import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ww_code/aesthetics/themes_service.dart';
import 'forgot_password.dart';
import 'create_account.dart';
import 'utilities/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'aesthetics/themes.dart';
import 'package:provider/provider.dart';

typedef LoginCallback = void Function(String? errorMessage);

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, 
  
  });
  

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Logger _logger = Logger('MyHomePage');
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ThemeService themeService = ThemeService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
Future<UserCredential> _authenticate(String email, String password) async {
  UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  return userCredential;
}


 Future<void> _login(BuildContext context, LoginCallback callback) async {
    String email = _emailController.text;
    String password = _passwordController.text;
    print('Attempting login with email: $email and $password');

    if (!isValidEmail(email) || !isValidPassword(password)) {
      callback('Invalid email or password.');
      return;
    }

    await _authenticate(email, password).then((UserCredential userCredential) {
      String userId = userCredential.user!.uid;
      bool isDarkMode = false;
      String? username;

     FirebaseFirestore.instance
    .collection('Users')
    .doc(userId)
    .get()
    .then((DocumentSnapshot doc) {
  if (doc.exists) {
    var data = doc.data() as Map<String, dynamic>;
    username = data['Username'];

    if (data.containsKey('darkMode')) {
      isDarkMode = data['darkMode'];
    } else {
      isDarkMode = false;
      // Update the document to add the darkMode field with the default value
      FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'darkMode': isDarkMode,
      });
    }
  }

        Provider.of<ThemeNotifier>(context, listen: false)
            .initialize(userId, isDarkMode);

        Navigator.pushReplacementNamed(context, '/menu', arguments: username)
            .then((_) {
          _emailController.clear();
          _passwordController.clear();
        });
      }).catchError((e) {
        callback('Error loading theme preference: $e');
      });
    }).catchError((e) {
      _logger.warning('Failed to sign in: $e');
      callback('Failed to sign in: $e');
    });
  }

  Future<void> loadUserProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        String? displayName = user.displayName;
        String? email = user.email;
        String username = displayName ?? email?.split('@')[0] ?? '';

        await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
          'Email': email,
          'Username': username,
          'profileImageUrl': null,
          'bio': '',
          'UsernameLowerCase': username.toLowerCase(),
          'friendsCount': 0,
        });
      } else {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          if (data['Username'] == null || data['Username'].isEmpty) {
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .update({
              'Username': user.displayName ?? user.email?.split('@')[0],
            });
          }
        }
      }
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

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          final DocumentReference userDocRef =
              FirebaseFirestore.instance.collection('Users').doc(user.uid);
          final DocumentSnapshot userDoc = await userDocRef.get();

          if (!userDoc.exists) {
            String username =
                user.displayName ?? user.email?.split('@')[0] ?? '';
            await userDocRef.set({
              'Email': user.email,
              'Username': username,
              'profileImageUrl': null,
              'bio': "",
              'UsernameLowerCase': username.toLowerCase(),
              'friendsCount': 0,
            });
          } else {
            Map<String, dynamic> userData =
                userDoc.data() as Map<String, dynamic>;
            if (userData['Username'] == null || userData['Username'].isEmpty) {
              userData['Username'] =
                  user.displayName ?? user.email?.split('@')[0];
            }
            await userDocRef.update(userData);
          }
          await themeService.loadUserThemePreference(
            user.uid,
            Provider.of<ThemeNotifier>(context, listen: false),
          );
        }
        Navigator.pushReplacementNamed(context, '/menu');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to sign in with Google.'),
          ),
        );
      }
    } catch (e) {
      _logger.warning('Failed to sign in with Google: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in with Google: $e'),
        ),
      );
    }
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
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 208, 208, 208),
                    prefixIcon: Icon(Icons.person, color: Colors.black45),
                    hintText: 'Email',
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
                const SizedBox(height: 16),
                TextField(
                  cursorColor: Colors.black,
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 208, 208, 208),
                    prefixIcon: Icon(Icons.lock, color: Colors.black45),
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
                  onPressed: () => _login(context, (errorMessage) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text(errorMessage ?? 'Unknown error occurred')),
                    );
                  }),
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
