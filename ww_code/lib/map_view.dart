import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ww_code/utilities/directions_model.dart';
import 'package:ww_code/utilities/map_directions.dart';
import 'package:ww_code/aesthetics/themes.dart';
import 'package:ww_code/location_autocomplete.dart';
import 'package:ww_code/favourite_locations_page.dart';
import 'localization/locales.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

// Initialize camera position for new users
class _MapScreenState extends State<MapScreen> {
  LatLng? _lastOriginPosition;
  bool isLoading = true;
  GoogleMapController? mapController;
  Marker? _origin;
  Marker? _destination;
  bool _showOriginButton = true;
  bool _showDestinationButton = false;
  Directions? _info;
  final Set<Marker> _markers = {};
  late String? userId;
  late BitmapDescriptor? customPin;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
    _loadCustomPin();
  }

  Future<void> _initializeUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
        loadMapCoordinates(userId!);
      });
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // Arbitrarily-set pin for landmark demarcation
  Future<void> _loadCustomPin() async {
    customPin = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'images/map_pin.png',
    );
    setState(() {}); // Reload page when initializing custom pin
  }

  Future<void> loadMapCoordinates(String userId) async {
    try {
      DocumentSnapshot documentSnapshotOrigin = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('Map')
          .doc('map_data')
          .get();

      if (documentSnapshotOrigin.exists) {
        Map<String, dynamic> dataOrigin =
            documentSnapshotOrigin.data() as Map<String, dynamic>;

        GeoPoint originPosition = dataOrigin['origin_position'];

        // Retrieve pinned locations from Firestore
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('Pinned_Locations')
            .get();

        querySnapshot.docs.forEach((doc) {
          GeoPoint position = doc['location_position'];
          String locationName = doc['location'];

          setState(() {
            _markers.add(
              Marker(
                markerId: MarkerId(doc.id), // Use document ID as marker ID
                position: LatLng(position.latitude, position.longitude),
                infoWindow: InfoWindow(
                  title: locationName,
                  snippet: LocaleData.manageLocation.getString(context),
                  onTap: () {
                    _showCustomMarkerDialog(
                        LatLng(position.latitude, position.longitude), userId);
                  },
                ),
                icon: customPin ??
                    BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
              ),
            );
          });
        });

        setState(() {
          _origin = Marker(
            markerId: const MarkerId('origin'),
            infoWindow: InfoWindow(title: LocaleData.origin.getString(context)),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            position: LatLng(originPosition.latitude, originPosition.longitude),
          );

          _lastOriginPosition = _origin!.position;
        });

        // Center the camera on the origin marker
        if (mapController != null) {
          mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target:
                    LatLng(originPosition.latitude, originPosition.longitude),
                zoom: 14.5,
                tilt: 50.0,
              ),
            ),
          );
        }
      } else {
        setState(() {
          _origin = Marker(
            markerId: const MarkerId('origin'),
            infoWindow: InfoWindow(title: LocaleData.origin.getString(context)),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            position:
                const LatLng(1.3521, 103.8198), // Default location: Singapore
          );

          _lastOriginPosition = _origin!.position;
        });

        // Center the camera on the default origin marker
        if (mapController != null) {
          mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              const CameraPosition(
                target: LatLng(1.3521, 103.8198), // Singapore coordinates
                zoom: 11.5,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error getting coordinates: $e');
    }
  }

  Future<void> _savePinnedLocation(
      LatLng pos, String userId, String locationName) async {
    try {
      final CollectionReference pinnedLocations = _firestore
          .collection('Users')
          .doc(userId)
          .collection('Pinned_Locations');

      await pinnedLocations.add({
        'location_position': GeoPoint(pos.latitude, pos.longitude),
        'location': locationName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Location added to pinned locations successfully!');
    } catch (e) {
      print('Error adding location to pinned locations: $e');
    }
  }

  Future<void> _addToFavourites(
      LatLng pos, String userId, String locationName) async {
    try {
      final CollectionReference pinnedLocations = _firestore
          .collection('Users')
          .doc(userId)
          .collection('Favourite_Locations');

      await pinnedLocations.add({
        'location_position': GeoPoint(pos.latitude, pos.longitude),
        'location': locationName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Location added to favourites successfully!');
    } catch (e) {
      print('Error adding location to favourites: $e');
    }
  }

  Future<void> updateMapCoordinates() async {
    if (_origin != null || _destination != null) {
      try {
        await _firestore
            .collection('Users')
            .doc(userId)
            .collection('Map')
            .doc('map_data')
            .set({
          'origin_position': _origin != null
              ? GeoPoint(
                  _origin!.position.latitude, _origin!.position.longitude)
              : null,
          'destination_position': _destination != null
              ? GeoPoint(_destination!.position.latitude,
                  _destination!.position.longitude)
              : null,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Error updating coordinates: $e');
      }
    }
  }

  Future<void> _searchLocation(String countryName) async {
    try {
      List<Location> locations = await locationFromAddress(countryName);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        setState(() {
          _lastOriginPosition = _origin!.position;

          // Center the camera on the searched location
          mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(location.latitude, location.longitude),
                zoom: 19.0,
                tilt: 50.0,
              ),
            ),
          );
        });
      } else {
        print('Location not found for $countryName');
      }
    } catch (e) {
      print('Error searching location: $e');
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _navigateToFavouriteLocations() async {
    LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FavouriteLocationsPage(),
      ),
    );

    if (selectedLocation != null) {
      // Update the camera position on the map
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: selectedLocation,
            zoom: 14.5,
            tilt: 50.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition? initialCameraPosition;

    if (isLoading) {
      initialCameraPosition = const CameraPosition(
        target: LatLng(1.3521, 103.8198), // Default to Singapore
        zoom: 11.5,
      );
    } else {
      initialCameraPosition = CameraPosition(
        target: _lastOriginPosition ??
            const LatLng(1.3521,
                103.8198), // Use last origin position or default to Singapore
        zoom: 14.5,
        tilt: 50.0,
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: initialCameraPosition,
            onMapCreated: (controller) {
              mapController = controller;
              setState(() {
                isLoading = false;
              });
              if (userId != null) {
                loadMapCoordinates(userId!);
              }
            },
            markers: {
              if (_origin != null) _origin!,
              if (_destination != null) _destination!,
              ..._markers
            },
            onTap: (LatLng) {
              _placeCustomMarker(LatLng);
            },
            polylines: {
              if (_info != null)
                Polyline(
                  polylineId: const PolylineId('overview_polyline'),
                  color: Colors.blue,
                  width: 5,
                  points: _info!.polylinePoints
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                ),
            },
            onLongPress: _addMarker,
          ),
          if (_destination != null && _info != null)
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.yellowAccent,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 6.0,
                        )
                      ],
                    ),
                    child: Text(
                      '${_info!.totalDistance}, Drive: ${_info!.totalDuration}, Walk: ${_info!.walkingDuration}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (isLoading)
            Center(
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
            ),
          if (_showOriginButton)
            Positioned(
              top: 60.0,
              right: 16.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: _origin!.position,
                      zoom: 14.5,
                      tilt: 50.0,
                    ),
                  ),
                ),
                child: Text(LocaleData.origin.getString(context)),
              ),
            ),
          if (_showDestinationButton)
            Positioned(
              top: 110.0,
              right: 16.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: _destination!.position,
                      zoom: 14.5,
                      tilt: 50.0,
                    ),
                  ),
                ),
                child: Text(LocaleData.dest.getString(context)),
              ),
            ),
          Positioned(
            bottom: 30.0,
            left: 16.0,
            child: FloatingActionButton(
              backgroundColor:
                  Theme.of(context).floatingActionButtonTheme.backgroundColor,
              foregroundColor:
                  Theme.of(context).floatingActionButtonTheme.foregroundColor,
              onPressed: () => _countrySelector(context),
              child: const Icon(Icons.search),
            ),
          ),
          Positioned(
            bottom: 100.0,
            left: 16.0,
            child: FloatingActionButton(
              backgroundColor:
                  Theme.of(context).floatingActionButtonTheme.backgroundColor,
              foregroundColor:
                  Theme.of(context).floatingActionButtonTheme.foregroundColor,
              onPressed: () => _navigateToFavouriteLocations(),
              child: const Icon(Icons.favorite),
            ),
          ),
          if (_origin != null && _destination != null && _info != null)
            Positioned(
              bottom: 170.0,
              left: 16.0,
              child: FloatingActionButton(
                onPressed: () {
                  if (_info != null) {
                    mapController?.animateCamera(
                      CameraUpdate.newLatLngBounds(_info!.bounds, 100.0),
                    );
                  }
                },
                child: const Icon(Icons.center_focus_strong),
              ),
            ),
        ],
      ),
    );
  }

  void _addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: InfoWindow(title: LocaleData.origin.getString(context)),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: pos,
        );
        _destination = null; // Reset destination when new origin is added
        _showOriginButton = true;
        _showDestinationButton = false;
        _info = Directions(
          bounds: LatLngBounds(
            northeast: const LatLng(0, 0),
            southwest: const LatLng(0, 0),
          ),
          polylinePoints: [],
          totalDistance: '',
          totalDuration: '',
          walkingDuration: '',
        );
        _lastOriginPosition = pos;
        updateMapCoordinates();
      });

      await _fetchPlaceDetails(pos, 'origin');
    } else {
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: InfoWindow(title: LocaleData.dest.getString(context)),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        );
        _showDestinationButton = true;
        updateMapCoordinates();
      });

      await _fetchPlaceDetails(pos, 'destination');

      if (_origin != null) {
        final directions = await DirectionsRepository()
            .getDirections(origin: _origin!.position, destination: pos);
        setState(() => _info = directions);
      }
    }
  }

  Future<void> _fetchPlaceDetails(LatLng pos, String markerType) async {
    const String apiKey = "AIzaSyB3dkvAT_hUG51l98FOsmqE0FVS5xwqCcI";
    final String nearbySearchUrl =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${pos.latitude},${pos.longitude}&radius=50&key=$apiKey";

    try {
      final nearbyResponse = await http.get(Uri.parse(nearbySearchUrl));
      if (nearbyResponse.statusCode == 200) {
        final nearbyData = json.decode(nearbyResponse.body);
        if (nearbyData['results'].isNotEmpty) {
          final place = nearbyData['results'][0];
          final String placeId = place['place_id'];

          final String detailsUrl =
              "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=name,formatted_address,photo&key=$apiKey";

          final detailsResponse = await http.get(Uri.parse(detailsUrl));

          if (detailsResponse.statusCode == 200) {
            final detailsData = json.decode(detailsResponse.body);
            final String name = detailsData['result']['name'];
            final String address = detailsData['result']['formatted_address'];

            setState(() {
              if (markerType == 'origin') {
                _origin = Marker(
                  markerId: const MarkerId('origin'),
                  infoWindow: InfoWindow(
                    title: name,
                    snippet: address,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                  position: pos,
                );
              } else if (markerType == 'destination') {
                _destination = Marker(
                  markerId: const MarkerId('destination'),
                  infoWindow: InfoWindow(
                    title: name,
                    snippet: address,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen),
                  position: pos,
                );
              } else if (markerType == 'custom') {
                _markers.add(
                  Marker(
                    markerId: MarkerId(pos.toString()),
                    infoWindow: InfoWindow(
                      title: name,
                      snippet: address,
                      onTap: () {
                        _showCustomMarkerDialog(pos, address);
                      },
                    ),
                    icon: customPin ??
                        BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed),
                    position: pos,
                  ),
                );
                _savePinnedLocation(pos, userId!, name);
              }
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching place details: $e');
    }
  }

  void _placeCustomMarker(LatLng pos) async {
    _fetchPlaceDetails(pos, 'custom');
  }

  void _removeCustomMarker(LatLng pos, String userId) async {
    String? markerIdToRemove;

    _markers.forEach((marker) {
      if (marker.position == pos) {
        markerIdToRemove = marker.infoWindow.title;
      }
    });

    if (markerIdToRemove != null) {
      setState(() {
        _markers.removeWhere((marker) => marker.position == pos);
      });

      try {
        final querySnapshotPinned = await _firestore
            .collection('Users')
            .doc(userId)
            .collection('Pinned_Locations')
            .where('location', isEqualTo: markerIdToRemove)
            .get();

        final querySnapshotFavourite = await _firestore
            .collection('Users')
            .doc(userId)
            .collection('Favourite_Locations')
            .where('location', isEqualTo: markerIdToRemove)
            .get();

        for (final doc in querySnapshotPinned.docs) {
          await doc.reference.delete();
        }

        for (final doc in querySnapshotFavourite.docs) {
          await doc.reference.delete();
        }

        print('Pinned location removed from Firestore!');
      } catch (e) {
        print('Error removing marker from Firestore: $e');
      }
    }
  }

  void _showCustomMarkerDialog(LatLng pos, String locationName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(LocaleData.removeMarkerText.getString(context),
              style: const TextStyle(color: Colors.black)),
          content: Text(LocaleData.removeMarkerTitle.getString(context),
              style: const TextStyle(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              child: Text(LocaleData.cancel.getString(context),
                  style: const TextStyle(color: Colors.lightBlue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(LocaleData.removeButton.getString(context),
                  style: const TextStyle(color: Colors.lightBlue)),
              onPressed: () {
                _removeCustomMarker(pos, userId!);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(LocaleData.addToFavouritesButton.getString(context),
                  style: const TextStyle(color: Colors.lightBlue)),
              onPressed: () {
                _addToFavourites(pos, userId!, locationName);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(LocaleData.addedToFavouritesSnackBar.getString(context)),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _countrySelector(BuildContext context) async {
    final String? countryName = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationAutoComplete()),
    );

    if (countryName != null) {
      _searchLocation(countryName);
    }
  }
}
