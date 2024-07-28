import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LanguageSelector extends StatefulWidget {
  @override
  State<LanguageSelector> createState() => LanguageSelectorState();
}

class LanguageSelectorState extends State<LanguageSelector> {
  late FlutterLocalization _flutterLocalization;
  late String _currentLocale;
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  User? _user;

  @override
  void initState() {
    super.initState();
    _flutterLocalization = FlutterLocalization.instance;
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _user = _auth.currentUser;
    _currentLocale = _flutterLocalization.currentLocale!.languageCode;

    
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Selector'),
        actions: [
          DropdownButton<String>(
            dropdownColor: isDarkMode ? const Color(0xFF191970) : Colors.white,
            value: _currentLocale,
            items: const [
              DropdownMenuItem<String>(
                value: "en",
                child: Text("English"),
              ),
              DropdownMenuItem<String>(
                value: "zh",
                child: Text("Chinese"),
              ),
              DropdownMenuItem<String>(
                value: "es",
                child: Text("Spanish"),
              ),
            ],
            onChanged: (value) {
              _setLocale(value);
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/lang.png',
              height: 200,
              width: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'Select a language from the dropdown',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _setLocale(String? value) async {
    if (value == null) {
      return;
    }
    _flutterLocalization.translate(value);
    if (_user != null) {
      await _firestore.collection('Users').doc(_user!.uid).update({'locale': value});
    }
    setState(() {
      _currentLocale = value;
    });
  }
}
