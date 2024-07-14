/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ww_code/find_users_page.dart';
import 'map_trips_page.dart';
import 'upload_docs.dart';
import 'settings_page.dart';
import 'help_page.dart';

class MenuPage extends StatefulWidget {
  final String? username;

  const MenuPage({super.key, this.username});

  @override
  MenuPageState createState() => MenuPageState();
}

class MenuPageState extends State<MenuPage> {
  final PageController pageController = PageController();
  int currentIndex = 0;
  final List<String> _images = [
    'images/borealis.png',
    'images/torii_gates.png',
    'images/rome.jpg',
    'images/taj_mahal.jpg',
    'images/zhongguo.jpg',
    'images/santorini.jpg',
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Menu page UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            itemCount: _images.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.asset(
                _images[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
          Positioned(
              top: 350.0,
              left: 16.0,
              right: 16.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '       Upcoming Events',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                      height: 100.0,
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20.0)),
                      child: const Padding(
                          padding: EdgeInsets.all(18.0),
                          child: Center(
                            child: Text('You have no upcoming events for now.',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                          ))),
                ],
              )),
          Positioned(
            top: 40.0,
            left: 16.0,
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    bool? confirmed = await _showLogoutConfirmationDialog();
                    if (confirmed != null && confirmed) {
                      await _logout();
                    }
                  },
                ),
                const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40.0,
            right: 16.0,
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.help, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HelpPage()),
                    );
                  },
                ),
                const Text(
                  'Help',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          const Positioned(
              top: 220.0,
              left: 0,
              right: 0,
              child: Center(
                child: Text('Where will you go next?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                    )),
              )),
          Positioned(
            bottom: 170.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicator(),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.4),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildExpandedButton(context, 'Trip Planner',
                          Icons.pin_drop, _navigateToMapItinerary),
                      _buildExpandedButton(context, 'Upload Docs',
                          Icons.upload_file, _navigateToManageFlightsBookings),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildExpandedButton(context, 'Settings', Icons.settings,
                          _navigateToSettings),
                      _buildExpandedButton(context, 'Socials', Icons.group,
                          _navigateToFriendsPage),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < _images.length; i++) {
      indicators.add(
        Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentIndex == i ? Colors.white : Colors.grey,
          ),
        ),
      );
    }
    return indicators;
  }

  // Option buttons
  Widget _buildExpandedButton(BuildContext context, String text, IconData icon,
      VoidCallback onPressed) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();
      Navigator.pushReplacementNamed(context, '/');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout successful!'),
        ),
      );
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
        backgroundColor: Colors.white,
        title: const Text('Logout', style: TextStyle(color: Colors.black)),
        content: const Text('Are you sure you want to log out?',
            style: TextStyle(color: Colors.black)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              await _logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _navigateToMapItinerary() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const MapItineraryPage()));
  }

  void _navigateToManageFlightsBookings() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const ManageFlightsBookingsPage()));
            //builder: (context) => const UploadDocumentsPage()));
  
  }


  void _navigateToSettings() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SettingsPage()));
  }

  void _navigateToFriendsPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const FriendsPage()));
  }
}
*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'map_trips_page.dart';
import 'upload_docs.dart';
import 'settings_page.dart';
import 'find_users_page.dart';
import 'help_page.dart';

class MenuPage extends StatefulWidget {
  final String? username;

  const MenuPage({super.key, this.username});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final List<String> _images = [
    'images/borealis.png',
    'images/torii_gates.png',
    'images/rome.jpg',
    'images/taj_mahal.jpg',
    'images/zhongguo.jpg',
    'images/santorini.jpg',
  ];
  int currentIndex = 0;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Menu page UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            itemCount: _images.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.asset(
                _images[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
          Positioned(
            top: 50.0,
            left: 16.0,
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    bool? confirmed = await _showLogoutConfirmationDialog();
                    if (confirmed != null && confirmed) {
                      await _logout();
                    }
                  },
                ),
                const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          Positioned(
            top: 50.0,
            right: 16.0,
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.help, color: Colors.white),
                  onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpPage()),
              );
            },
                ),
                const Text(
                  'Help',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const Center(
            child: Text('Where will you go next?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                )),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.4),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildExpandedButton(
                          context, 'Map/Trips', _navigateToMapItinerary),
                      _buildExpandedButton(context, 'Upload Documents',
                          _navigateToManageFlightsBookings),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildExpandedButton(
                          context, 'Settings', _navigateToSettings),
                      _buildExpandedButton(
                        context, 'Socials', _navigateToWendyAI),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Option buttons
  Widget _buildExpandedButton(
      BuildContext context, String text, VoidCallback onPressed) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();
      Navigator.pushReplacementNamed(context, '/');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout successful!'),
        ),
      );
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
        backgroundColor: Colors.white,
        title: const Text('Logout', style: TextStyle(color: Colors.black)),
        content: const Text('Are you sure you want to log out?',
            style: TextStyle(color: Colors.black)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              await _logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _navigateToMapItinerary() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const MapItineraryPage()));
  }

  void _navigateToManageFlightsBookings() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const ManageFlightsBookingsPage()));
  }

  void _navigateToSettings() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SettingsPage()));
  }

  void _navigateToWendyAI() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const FriendsPage()));
  }
}