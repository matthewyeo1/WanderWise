import 'package:flutter/material.dart';

class MapItineraryPage extends StatefulWidget {
  const MapItineraryPage({super.key});

  @override
  MapItineraryPageState createState() => MapItineraryPageState();
}

class MapItineraryPageState extends State<MapItineraryPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // navigate to google maps
        break;
      case 1:
        // navigate to itinerary
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Map/Itinerary'),
      ),
      body: Center(
        child: Text(
          _selectedIndex == 0 ? '<google maps API>' : '<to be replaced with itinerary template>',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My Itinerary',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}
