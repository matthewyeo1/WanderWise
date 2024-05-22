import 'package:flutter/material.dart';

class MapItineraryPage extends StatelessWidget {
  const MapItineraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map/Itinerary'),
      ),
      body: const Center(
        child: Text('Map and Itinerary Page'),
      ),
    );
  }
}
