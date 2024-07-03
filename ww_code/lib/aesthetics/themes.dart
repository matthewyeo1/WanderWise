import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class CustomColors {
  final Color circularProgressIndicatorLight;
  final Color circularProgressIndicatorDark;

  const CustomColors({
    required this.circularProgressIndicatorLight,
    required this.circularProgressIndicatorDark,
  });
}

extension CustomTheme on ThemeData {
  CustomColors get customColors => const CustomColors(
        circularProgressIndicatorLight: Colors.lightBlue,
        circularProgressIndicatorDark: Colors.white,
      );
}

// Intialize user theme upon login
class ThemeNotifier with ChangeNotifier {
  late bool isDarkMode;
  late String? userId;

  ThemeNotifier(userId, {required this.isDarkMode});

   void initialize(String userId, bool isDarkMode) {
    this.userId = userId;
    this.isDarkMode = isDarkMode;
    notifyListeners();
  }

  ThemeData getTheme() => isDarkMode ? darkTheme : lightTheme;

  Future<void> toggleTheme() async {
    isDarkMode = !isDarkMode;
    notifyListeners();
    await _saveThemePreference();
  }

  Future<void> _saveThemePreference() async {
    if (userId != null) {
      await FirebaseFirestore.instance.collection('Users').doc(userId).set({
        'darkMode': isDarkMode,
      }, SetOptions(merge: true));
    }
  }

  Future<void> loadThemePreference() async {
    if (userId != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      if (doc.exists && doc.data() != null) {
        bool? darkMode = doc['darkMode'];
        if (darkMode != null) {
          isDarkMode = darkMode;
          notifyListeners();
        }
      }
    }
  }

  ThemeMode getThemeMode() {
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}


final lightTheme = ThemeData(
  brightness: Brightness.light,
  inputDecorationTheme: const InputDecorationTheme(
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.lightBlue),
    ),
  ),
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: const Color.fromARGB(255, 229, 224, 224),
  canvasColor: Colors.transparent,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF00A6DF),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    headlineMedium: TextStyle(color: Colors.black),
    headlineSmall: TextStyle(color: Colors.black),
    titleSmall: TextStyle(color: Colors.black),
    bodySmall: TextStyle(color: Colors.black),
    labelSmall: TextStyle(color: Colors.black),
    displaySmall: TextStyle(color: Colors.black),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    elevation: 0.0,
    selectedItemColor: Color(0xFF00A6DF),
    unselectedItemColor: Colors.grey,
  ),
  iconTheme: const IconThemeData(
    color: Colors.black45,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.lightBlue,
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Colors.black54,
    contentTextStyle: TextStyle(color: Colors.white),
  ),
  
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  inputDecorationTheme: const InputDecorationTheme(
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    ),
  ),
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: const Color.fromARGB(255, 9, 9, 63),
  canvasColor: Colors.transparent,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF191970),
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white),
    headlineMedium: TextStyle(color: Colors.white),
    headlineSmall: TextStyle(color: Colors.white),
    titleSmall: TextStyle(color: Colors.white),
    bodySmall: TextStyle(color: Colors.white),
    labelSmall: TextStyle(color: Colors.white),
    displaySmall: TextStyle(color: Colors.white),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF191970),
    elevation: 0.0,
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.grey,
  ),
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF191970),
      foregroundColor: Colors.white,
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Colors.black54,
    contentTextStyle: TextStyle(color: Colors.white),
  ),
  
);
