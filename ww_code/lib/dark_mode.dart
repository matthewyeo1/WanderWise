import 'package:flutter/material.dart';

class DarkModeSettingsPage extends StatelessWidget {
  const DarkModeSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dark Mode Settings'),
      ),
      body: Center(
        child: Text('Dark Mode Settings Page'),
      ),
    );
  }
}
