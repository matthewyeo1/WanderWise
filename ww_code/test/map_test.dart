import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ww_code/utilities/directions_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:ww_code/map_testing/map_screen.dart';
import 'package:provider/provider.dart';
import 'location_provider_mock.dart';  
import 'package:ww_code/map_testing/location_provider.dart';

void main() {
  
  group('Directions Model', () {
    test('Directions model should have correct properties', () {
      final directions = Directions(
        bounds: LatLngBounds(
          northeast: const LatLng(0, 0),
          southwest: const LatLng(0, 0),
        ),
        polylinePoints: [
          const PointLatLng(0.0, 0.0),
          const PointLatLng(1.0, 1.0),
        ],
        totalDistance: '10 km',
        totalDuration: '15 mins',
        walkingDuration: '20 mins',
      );

      expect(directions.totalDistance, '10 km');
      expect(directions.totalDuration, '15 mins');
      expect(directions.walkingDuration, '20 mins');
      expect(directions.polylinePoints.length, 2);
    });
  });

 testWidgets('MapScreen has a search button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<LocationProvider>(
          create: (context) => MockLocationProvider(),
          child: const MapScreen(),
        ),
      ),
    );

    // Verify the FloatingActionButton for search is present
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('MapScreen has a favourites button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<LocationProvider>(
          create: (context) => MockLocationProvider(),
          child: const MapScreen(),
        ),
      ),
    );

    // Verify the FloatingActionButton for favourites is present
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('MapScreen shows origin button when origin marker is set', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<LocationProvider>(
          create: (context) => MockLocationProvider(),
          child: const MapScreen(),
        ),
      ),
    );

    // Set an origin marker by simulating the user interaction or directly modifying the MockLocationProvider
    final mockProvider = Provider.of<LocationProvider>(tester.element(find.byType(MapScreen)), listen: false) as MockLocationProvider;
    mockProvider.setOriginMarker(
      const Marker(
        markerId: const MarkerId('origin'),
        position: const LatLng(1.3521, 103.8198),
        infoWindow: const InfoWindow(title: 'Origin'),
      ),
    );

    await tester.pump();

    // Verify the origin button is present
    expect(find.text('ORIGIN'), findsOneWidget);
  });
}
