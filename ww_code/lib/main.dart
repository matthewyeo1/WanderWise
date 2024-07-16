import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ww_code/find_users_page.dart';
import 'package:ww_code/map_trips_page.dart';
import 'aesthetics/splashscreen.dart';
import 'aesthetics/themes.dart';
import 'login_screen.dart';
import 'menu_page.dart';
import 'create_account.dart';
import 'forgot_password.dart';
import 'help_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:ww_code/utilities/const.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:ww_code/notif_service.dart';


void main() async {
  // Load the .env file
  try {
    await dotenv.load();
    String apiKey = dotenv.env['API_KEY']!;
    print('API Key: $apiKey');
  } catch (e) {
    print('Error loading environment variables: $e');
  }
  // Load Gemini API Key
  Gemini.init(
    apiKey: GEMINI_API_KEY,
  );

  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().iniNotification();
  tz.initializeTimeZones();

  // Initialize Firebase and Firebase App Check
  await Firebase.initializeApp();
  //await FirebaseAppCheck.instance.activate();

  // Set Firestore settings
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

  // Get the current user
  User? user = FirebaseAuth.instance.currentUser;

  // Initialize ThemeNotifier
  ThemeNotifier themeNotifier =
      ThemeNotifier(user?.uid ?? '', isDarkMode: false);

  // Load theme preference if user is authenticated
  if (user != null) {
    try {
      themeNotifier.userId = user.uid;
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
              '/login': (context) => const MyHomePage(),
              '/menu': (context) => const MenuPage(),
              '/create_account': (context) => const CreateAccountPage(),
              '/forgot_password': (context) => const ForgotPasswordPage(),
              '/help': (context) => const HelpPage(),
              '/trips': (context) => const MapItineraryPage(),
              '/socials': (context) => const FriendsPage(),
            },
            debugShowCheckedModeBanner: false,
          );
      },
    );
  }
}
