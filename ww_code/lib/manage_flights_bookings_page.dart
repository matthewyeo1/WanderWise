import 'package:flutter/material.dart';

class ManageFlightsBookingsPage extends StatelessWidget {
  const ManageFlightsBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Manage Flights/Bookings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  // Handle map button pressed
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal, // Set background color here
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: const Text('Flights'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  // Handle itinerary button pressed
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal, // Set background color here
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: const Text('Hotel Bookings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

