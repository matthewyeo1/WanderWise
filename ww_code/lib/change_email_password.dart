import 'package:flutter/material.dart';

class ChangeEmailPasswordPage extends StatelessWidget {
  const ChangeEmailPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Email/Password'),
      ),
      body: const Center(
        child: Text('Change Email/Password Page'),
      ),
    );
  }
}
