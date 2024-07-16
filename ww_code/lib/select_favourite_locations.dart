import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ww_code/aesthetics/themes.dart';
import 'dart:async';
import 'package:flutter/services.dart'; // Add this import for clipboard functionality

class SelectFavouriteLocations extends StatefulWidget {
  const SelectFavouriteLocations({super.key});

  @override
  SelectFavouriteLocationsState createState() =>
      SelectFavouriteLocationsState();
}

class SelectFavouriteLocationsState extends State<SelectFavouriteLocations> {
  Stream<QuerySnapshot>? _locationsStream;
  String? userId;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
        _locationsStream = FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('Favourite_Locations')
            .snapshots();
      });
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _copyLocation(DocumentSnapshot location) {
    // Extract the location name from the location document
    String locationName =
        location['location']; // Assuming 'location' field exists

    // Copy the location name to the clipboard
    Clipboard.setData(ClipboardData(text: locationName));

    // Pop with the copied location name
    Navigator.pop(context, locationName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose from Favourite Locations'),
      ),
      body: _locationsStream == null
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).brightness == Brightness.light
                      ? Theme.of(context)
                          .customColors
                          .circularProgressIndicatorLight
                      : Theme.of(context)
                          .customColors
                          .circularProgressIndicatorDark,
                ),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: _locationsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).brightness == Brightness.light
                            ? Theme.of(context)
                                .customColors
                                .circularProgressIndicatorLight
                            : Theme.of(context)
                                .customColors
                                .circularProgressIndicatorDark,
                      ),
                    ),
                  );
                }

                List<DocumentSnapshot> locations = snapshot.data!.docs;

                if (locations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'images/favourite_locations.png',
                          height: 250,
                        ), 
                        const SizedBox(height: 20),
                        const Text(
                          'Copy & paste your favourite places to your itinerary!',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot location = locations[index];
                    String locationName = location[
                        'location']; // Assuming 'location' field exists

                    return ListTile(
                      title: Text(locationName),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Location copied to clipboard!'),
                            ),
                          );
                          _copyLocation(location);
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
