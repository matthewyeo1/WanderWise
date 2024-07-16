import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'location_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(1.3521, 103.8198),
          zoom: 11.0,
        ),
        markers: locationProvider.origin != null ? {locationProvider.origin!} : {},
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.search),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.favorite),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      persistentFooterButtons: [
        TextButton(
          onPressed: () {
            // Set an origin marker when this button is pressed
            locationProvider.setOriginMarker(
              const Marker(
                markerId:  MarkerId('origin'),
                position:  LatLng(1.3521, 103.8198),
                infoWindow:  InfoWindow(title: 'Origin'),
              ),
            );
          },
          child: const Text('ORIGIN'),
        ),
      ],
    );
  }
}
