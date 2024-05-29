import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';
import 'menu_page.dart';
import 'create_account.dart';
import 'forgot_password.dart';
import 'aesthetics/splashscreen.dart';

void main() async {
  _setupLogging();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
// Logging set up to monitor activity on the terminals
void _setupLogging() {
  Logger.root.level = Level.ALL; // Set the root logger level to ALL
  Logger.root.onRecord.listen((LogRecord record) {
  print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

// Main widget for app
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WanderWise App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.transparent,
        canvasColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
        ), 
      ),
      home:const SplashScreen(),     // Splashscreen with animation
      routes: {
        '/login': (context) => const MyHomePage(title: 'Login'),
        '/menu': (context) => const MenuPage(),
        '/create_account': (content) => const CreateAccountPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
      }, 
      debugShowCheckedModeBanner: false,
    );
  }
}






