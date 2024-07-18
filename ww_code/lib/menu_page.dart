import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ww_code/find_users_page.dart';
import 'map_trips_page.dart';
import 'upload_docs.dart';
import 'settings_page.dart';
import 'help_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class MenuPage extends StatefulWidget {
  final String? username;

  const MenuPage({super.key, this.username});

  @override
  MenuPageState createState() => MenuPageState();
}

class MenuPageState extends State<MenuPage> {
  final PageController pageController = PageController();
  late Timer _timer;
  DateTime _currentTime = DateTime.now().toLocal();

  int currentIndex = 0;
  final List<String> _images = [
    'images/borealis.png',
    'images/torii_gates.png',
    'images/rome.jpg',
    'images/taj_mahal.jpg',
    'images/eiffel_tower.jpg',
    'images/maldives.jpg',
  ];

  late String _selectedImage = 'images/borealis.png'; // Default wallpaper

  @override
  void initState() {
    super.initState();
    _loadSelectedImage();
    _currentTime = DateTime.now().toLocal();
    _timer = Timer.periodic(Duration(minutes: 1), (Timer t) {
      setState(() {
        _currentTime = DateTime.now().toLocal();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadSelectedImage() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);
    final docSnapshot = await userDoc.get();
    if (docSnapshot.exists && docSnapshot.data() != null) {
      final data = docSnapshot.data();
      if (data != null && data.containsKey('backgroundImage')) {
        setState(() {
          _selectedImage = data['backgroundImage'];
        });
      }
    }
  }

  Future<void> _updateBackgroundImage(String imageUrl) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('Users').doc(userId).update({
      'backgroundImage': imageUrl,
    });
    setState(() {
      _selectedImage = imageUrl;
    });
  }

  // Menu page UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            _selectedImage,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          PageView.builder(
            itemCount: _images.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _updateBackgroundImage(_images[index]);
                },
                child: Image.asset(
                  _images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              );
            },
          ),
          Positioned(
            top: 60.0,
            left: 16.0,
            right: 16.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 400.0,
                  maxHeight: 50.0,
                ),
                
                child: Center(
                  child: StreamBuilder<DateTime>(
                    stream: Stream.periodic(
                        const Duration(minutes: 1), (_) => DateTime.now().toLocal()),
                    initialData: _currentTime,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        _currentTime = snapshot.data!;
                        String formattedTime =
                            DateFormat('EEE, HH:mm').format(_currentTime);
                        return Text(
                          formattedTime,
                          style: const TextStyle(
                            fontSize: 24.0,
                           
                            color: Colors.white,
                          ),
                        );
                      } else {
                        return const CircularProgressIndicator(
                          color: Colors.white,
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 280.0,
            left: 16.0,
            right: 16.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '        Activity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                  child: FutureBuilder<int>(
                    future: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('PendingInvites')
                        .get()
                        .then((querySnapshot) => querySnapshot.size),
                    builder: (context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          constraints: const BoxConstraints(
                            maxWidth: 400.0,
                            maxHeight: 50.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data == 0) {
                        return Container(
                          constraints: const BoxConstraints(
                            maxWidth: 400.0,
                            maxHeight: 50.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'No actions to be taken',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return Container(
                        constraints: const BoxConstraints(
                          maxWidth: 400.0,
                          maxHeight: 50.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'Friend Requests: ${snapshot.data}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 400.0,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 400.0,
                      maxHeight: 150.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('Reminders')
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No upcoming events',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                  snapshot.data!.docs.length, (index) {
                                var reminder = snapshot.data!.docs[index];
                                DateTime scheduleTime =
                                    (reminder['scheduleTime'] as Timestamp)
                                        .toDate();
                                String formattedTime =
                                    "${scheduleTime.day}/${scheduleTime.month}/${scheduleTime.year}, ${scheduleTime.hour}:${scheduleTime.minute}";

                                // Determine if reminder has been triggered
                                bool isTriggered =
                                    scheduleTime.isBefore(DateTime.now());

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Scheduled for: $formattedTime',
                                          style: TextStyle(
                                            color: isTriggered
                                                ? Colors.red
                                                : Colors
                                                    .white, // Change color to red if triggered
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            FirebaseFirestore.instance
                                                .collection('Users')
                                                .doc(FirebaseAuth
                                                    .instance.currentUser!.uid)
                                                .collection('Reminders')
                                                .doc(reminder.id)
                                                .delete()
                                                .then((value) => print(
                                                    'Reminder deleted successfully'))
                                                .catchError((error) => print(
                                                    'Failed to delete reminder: $error'));
                                          },
                                          child: const Text(
                                            'Dismiss',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ListTile(
                                      title: Text(
                                        reminder['title'],
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      subtitle: Text(
                                        reminder['description'],
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                      await _logout(context);
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
              top: 180.0,
              left: 0,
              right: 0,
              child: Center(
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
              color: Colors.black.withOpacity(0.5),
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

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      // Simulate sign out for GoogleSignIn (if applicable)
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      await _googleSignIn.signOut();

      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      print("Logout error: $e");
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
              await _logout(context);
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

  void _navigateToFriendsPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const FriendsPage()));
  }
}
