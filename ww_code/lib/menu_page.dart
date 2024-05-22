import 'package:flutter/material.dart';
import 'dart:async';
import 'map_itinerary_page.dart';
import 'manage_flights_bookings_page.dart';
import 'settings_page.dart';
import 'help_page.dart';


class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

//cycle images
class _MenuPageState extends State<MenuPage> {
  final List<String> _images = [
    'images/borealis.png',
    'images/santorini.png',
    'images/alps.png',
    'images/mtfuji.png',
    'images/guanmingdeng.png',
    'images/capadocia.png',
  ];
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startImageCycle();
  }

  void _startImageCycle() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _images.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _navigateToMapItinerary(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapItineraryPage()),
    );
  }

  void _navigateToManageFlightsBookings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ManageFlightsBookingsPage()),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }
  
  void _navigateToHelp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HelpPage()),
    );
  }
  //the 4 menu buttons will share this design spec:
  Widget _buildExpandedButton(BuildContext context, String text) {
    return Expanded(
      child: SizedBox(
        height: 100, 
        child: ElevatedButton(
          onPressed: () {
            if (text == 'Map/Itinerary') {
              _navigateToMapItinerary(context);
            } else if (text == 'Manage Flights/Bookings') {
              _navigateToManageFlightsBookings(context);
            } else if (text == 'Settings') {
              _navigateToSettings(context);
            } else if (text == 'Help') {
              _navigateToHelp(context);
            }
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
          mainAxisAlignment: MainAxisAlignment.end, 
          children: <Widget>[
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(                      //fade-in fade-out effect              
                      duration: const Duration(seconds: 1),
                      child: Stack(
                        key: ValueKey<String>(_images[_currentIndex]),
                        children: [
                          Image.asset(
                            _images[_currentIndex],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          const Align(
                            alignment: Alignment.center,
                            child: Text('Where will you go next?',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 2.0,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                   ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildExpandedButton(context, 'Map/Itinerary'),                      // menu buttons
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
}

