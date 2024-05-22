import 'package:flutter/material.dart';

class ManageFlightsBookingsPage extends StatelessWidget {
  const ManageFlightsBookingsPage({super.key});
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
