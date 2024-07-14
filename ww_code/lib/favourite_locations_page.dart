import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ww_code/aesthetics/themes.dart';
import 'dart:async';

class FavouriteLocationsPage extends StatefulWidget {
  const FavouriteLocationsPage({super.key});

  @override
  FavouriteLocationsPageState createState() => FavouriteLocationsPageState();
}

class FavouriteLocationsPageState extends State<FavouriteLocationsPage> {
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

  void _animateToLocation(DocumentSnapshot location) {
    // Extract latitude and longitude from the location document
    GeoPoint geoPoint = location['location_position'];
    double latitude = geoPoint.latitude;
    double longitude = geoPoint.longitude;

    // Pop with result
    Navigator.pop(context, LatLng(latitude, longitude));
  }

  Future<void> _deleteLocation(DocumentSnapshot location) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Favourite_Locations')
        .doc(location.id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite Locations'),
      ),
      body: _locationsStream == null
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).brightness == Brightness.light
                      ? Theme.of(context).customColors.circularProgressIndicatorLight
                      : Theme.of(context).customColors.circularProgressIndicatorDark,
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
                            ? Theme.of(context).customColors.circularProgressIndicatorLight
                            : Theme.of(context).customColors.circularProgressIndicatorDark,
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
                        Image.asset('images/favourite_locations.png',
                        height: 250,), // Your placeholder image
                        const SizedBox(height: 20),
                        const Text(
                          'Store & navigate to your favourite places here!',
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
                    String locationName = location['location']; // Assuming 'location' field exists

                    return ListTile(
                      title: Text(locationName),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.location_on),
                            onPressed: () {
                              _animateToLocation(location);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await _deleteLocation(location);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
