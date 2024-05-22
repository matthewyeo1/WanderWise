import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Menu'),
      ),
      backgroundColor: Colors.teal, 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end, // Align to the bottom
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, // Align to the bottom
                children: [
                  Row(
                    children: [
                      _buildExpandedButton(context, 'Map/Itinerary'),
                      const SizedBox(width: 16),
                      _buildExpandedButton(context, 'Manage Flights/Bookings'),
                    ],
                  ),
                  const SizedBox(height: 36), 
                  Row(
                    children: [
                      _buildExpandedButton(context, 'Settings'),
                      const SizedBox(width: 16), 
                      _buildExpandedButton(context, 'Help'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedButton(BuildContext context, String text) {
    return Expanded(
      child: SizedBox(
        height: 100, 
        child: ElevatedButton(
          onPressed: () {
            // navigation logic will be added here later
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.white, 
            foregroundColor: Colors.black, 
          ),
          child: Text(
            text,
            textAlign: TextAlign.center, 
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

