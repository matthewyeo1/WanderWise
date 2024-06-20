import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  bool isDarkMode = false;

  ThemeData getTheme() => isDarkMode ? darkTheme : lightTheme;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  ThemeMode getThemeMode() {
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}

final lightTheme = ThemeData(
  inputDecorationTheme: const InputDecorationTheme(
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.lightBlue),
    ),
  ),
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
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
);

final darkTheme = ThemeData(
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
);
