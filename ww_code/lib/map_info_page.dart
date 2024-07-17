import 'package:flutter/material.dart';

class MapInfoPage extends StatelessWidget {
  const MapInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Information'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How to Use WanderWise Maps \n(by Google Maps)',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            const Text(
              '1. To zoom in and out, use the pinch gesture or the zoom buttons on the screen.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 50),
            const Text(
              '2. To move around the map, simply drag with one finger.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 50),
            const Text(
              '3. Tap on a marker/pin to see more information about that location.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 50),
            Image.asset(
              'images/map_info_3.png',
              height: 500,
              width: 500,
            ),
            const SizedBox(height: 50),
            const Text(
              '4. Use the search bar at the bottom left corner of the screen to quickly find a specific location.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 50),
            Image.asset(
              'images/map_info_4.png',
              height: 500,
              width: 500,
            ),
            const SizedBox(height: 10),
            Image.asset(
              'images/map_info_4.1.png',
              height: 500,
              width: 500,
            ),
            const SizedBox(height: 50),
            const Text(
              '5. Find a route to your destination by long-pressing on the screen: the first is for the origin marker and the second for the destination marker.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 50),
            Image.asset(
              'images/map_info_6.png',
              height: 500,
              width: 500,
            ),
          ],
        ),
      ),
    );
  }
}
