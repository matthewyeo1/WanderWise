import 'package:flutter/material.dart';

class DarkModeSettingsPage extends StatelessWidget {
  const DarkModeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dark Mode Settings'),
      ),
      body: const Center(
        child: Text('Dark Mode Settings Page'),
      ),
    );
  }
}
