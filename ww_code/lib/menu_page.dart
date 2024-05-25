import 'package:flutter/material.dart';
import 'dart:async';
import 'map_itinerary_page.dart';
import 'manage_flights_bookings_page.dart';
import 'settings_page.dart';
import 'help_page.dart';
import 'aesthetics/colour_gradient.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class MenuPage extends StatefulWidget {
  final String? username;
  const MenuPage({Key? key, this.username}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final List<String> _images = [
    'images/borealis.png',
    'images/guanmingdeng.png',
    'images/japan2.png',
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
      MaterialPageRoute(builder: (context) => const MapItineraryPage()),
    );
  }

  void _navigateToManageFlightsBookings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const ManageFlightsBookingsPage()),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  void _navigateToHelp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HelpPage()),
    );
  }

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
            backgroundColor: Colors.lightBlue,
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white),
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

  Future<void> _logout() async {
    try {
      await firebase_auth.FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      print("Logout error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout error'),
        ),
      );
    }
  }

  Future<bool?> _showLogoutConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              await _logout();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF13438B),
        title: const Text('Menu'),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            bool? confirmed = await _showLogoutConfirmationDialog();
            if (confirmed != null && confirmed) {
              await _logout();
            }
          },
        ),
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: getAppGradient(),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedSwitcher(
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
                                child: Text(
                                  'Where will you go next?',
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
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildExpandedButton(context, 'Map/Itinerary'),
                        const SizedBox(width: 16),
                        _buildExpandedButton(
                            context, 'Manage Flights/Bookings'),
                      ],
                    ),
                    const SizedBox(height: 30),
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
      ),
    );
  }
}
