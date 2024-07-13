import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ww_code/aesthetics/themes.dart';
import 'package:ww_code/utilities/directions_model.dart';
import 'package:ww_code/utilities/map_directions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _lastOriginPosition;

  CameraPosition get _initialCameraPosition {
    return CameraPosition(
      target: _lastOriginPosition ??
          const LatLng(1.3521, 103.8198), // Default location: Singapore
      zoom: 11.5,
    );
  }

  bool isLoading = true;
  GoogleMapController? mapController;
  Marker? _origin;
  Marker? _destination;
  bool _showOriginButton = false;
  bool _showDestinationButton = false;
  Directions? _info;
  late String? userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        loadMapCoordinates(userId!);
      });
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> loadMapCoordinates(String userI) async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('Map')
          .doc('map_data')
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        GeoPoint originPosition = data['origin_position'];
        //GeoPoint? destinationPosition = data['destination_position'];

        setState(() {
          _origin = Marker(
            markerId: const MarkerId('origin'),
            infoWindow: const InfoWindow(title: 'Origin'),
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
      }
    } catch (e) {
      print('Error getting coordinates: $e');
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

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
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
              if (_destination != null) _destination!
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
                child: const Text('ORIGIN'),
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
                child: const Text('DEST'),
              ),
            ),
        ],
      ),
      floatingActionButton:
          _origin != null && _destination != null && _info != null
              ? FloatingActionButton(
                  onPressed: () {
                    if (_info != null) {
                      mapController?.animateCamera(
                        CameraUpdate.newLatLngBounds(_info!.bounds, 100.0),
                      );
                    }
                  },
                  child: const Icon(Icons.center_focus_strong),
                )
              : null,
    );
  }

  void _addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
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
    } else {
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destination'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        );
        _showDestinationButton = true;
        updateMapCoordinates();
      });
      if (_origin != null) {
        final directions = await DirectionsRepository()
            .getDirections(origin: _origin!.position, destination: pos);
        setState(() => _info = directions);
      }
    }
  }
}
