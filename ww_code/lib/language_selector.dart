import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class LanguageSelector extends StatefulWidget {
  @override
  State<LanguageSelector> createState() => LanguageSelectorState();
}

class LanguageSelectorState extends State<LanguageSelector> {
  late FlutterLocalization _flutterLocalization;
  late String _currentLocale;

  @override
  void initState() {
    super.initState();
    _flutterLocalization = FlutterLocalization.instance;
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
             dropdownColor: isDarkMode
              ? const Color(0xFF191970) 
              : Colors.white,
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
  void _setLocale(String? value) {
    if (value == null) {
      return;
    }
    if (value == "en") {
      _flutterLocalization.translate("en");
    } else if (value == 'zh') {
      _flutterLocalization.translate("zh");
    } else if (value == 'es') {
      _flutterLocalization.translate("es");
    }
    setState(() {
      _currentLocale = value;
      _flutterLocalization.translate(value);
    });
  }
}
