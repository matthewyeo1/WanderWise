import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'aesthetics/splashscreen.dart';
import 'aesthetics/themes.dart';
import 'login_screen.dart';
import 'menu_page.dart';
import 'create_account.dart';
import 'forgot_password.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase and Firebase App Check
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate();
  
  // Set Firestore settings
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  // Get the current user
  User? user = FirebaseAuth.instance.currentUser;

  // Initialize ThemeNotifier
  ThemeNotifier themeNotifier = ThemeNotifier(user?.uid ?? '', isDarkMode: false);

  // Load theme preference if user is authenticated
  if (user != null) {
    try {
      await themeNotifier.loadThemePreference();
    } catch (e) {
      // Handle any errors that occur during theme preference loading
      print('Error loading theme preference: $e');
    }
  }

  // Run app and set the theme according to the user's preference
  runApp(
    ChangeNotifierProvider(
      create: (context) => themeNotifier,
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'WanderWise App',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeNotifier.getThemeMode(),
          home: const SplashScreen(),
          routes: {
            '/login': (context) => const MyHomePage(title: 'Login'),
            '/menu': (context) => const MenuPage(),
            '/create_account': (context) => const CreateAccountPage(),
            '/forgot_password': (context) => const ForgotPasswordPage(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
