import 'package:flutter/material.dart';

class ManageFlightsBookingsPage extends StatefulWidget {
  const ManageFlightsBookingsPage({super.key});

  @override
  ManageFlightsBookingsPageState createState() => ManageFlightsBookingsPageState();
}

class ManageFlightsBookingsPageState extends State<ManageFlightsBookingsPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // navigate to flight info
        break;
      case 1:
        // navigate to hotel bookings
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Manage Flights/Bookings'),
      ),
      body: Center(
        child: Text(
          _selectedIndex == 0? '<insert flight info>' : '<insert hotel bookings>',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.airplanemode_active),
            label: 'Flights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel),
            label: 'Accommodation',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}