import 'package:flutter/material.dart';
import 'aesthetics/colour_gradient.dart';

class MapItineraryPage extends StatefulWidget {
  const MapItineraryPage({super.key});

  @override
  MapItineraryPageState createState() => MapItineraryPageState();
}

class MapItineraryPageState extends State<MapItineraryPage> {
  int _selectedIndex = 0;

  final Color _unselectedItemColor = Colors.white;
  final Color _selectedItemColor = Colors.white;

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

  Widget _buildIcon(IconData icon, int index) {
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(_selectedIndex == index ? 12 : 8), 
        decoration: BoxDecoration(
          color: _selectedIndex == index ? _selectedItemColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: _unselectedItemColor, 
          size: 24,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF13438B),
        title: const Text('Map/Itinerary'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: getAppGradient(), 
        ),
        child: Center(
          child: Text(
            _selectedIndex == 0 ? '<google maps>' : '<insert itinerary>',
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
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
        selectedItemColor: Colors.white,
        backgroundColor: const Color(0xFF10CFF9), 
        elevation: 0.0,
        onTap: _onItemTapped,
      ),
    );
  }
}