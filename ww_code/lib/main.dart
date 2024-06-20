import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'aesthetics/splashscreen.dart';
import 'aesthetics/themes.dart';
import 'login_screen.dart';
import 'menu_page.dart';
import 'create_account.dart';
import 'forgot_password.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate();
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

  final themeNotifier = ThemeNotifier();

  runApp(
    ChangeNotifierProvider(
      create: (context) => themeNotifier,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
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
      ),
    );
  }
}
