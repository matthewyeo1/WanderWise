import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Map/Itinerary'),
      ),
      body: const Center(
        child: Text('Map and Itinerary Page'),
      ),
    );
  }
}
