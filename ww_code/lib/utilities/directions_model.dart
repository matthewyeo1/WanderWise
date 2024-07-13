import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions {
  final LatLngBounds bounds;
  final List<PointLatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;
  final String walkingDuration;

  const Directions({
    required this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
    required this.walkingDuration,
  });

  factory Directions.fromMap(Map<String, dynamic> map) {
    // Check if route is not available
    if ((map['routes'] as List).isEmpty) {
      return Directions(
        bounds: LatLngBounds(
            northeast: const LatLng(0, 0), southwest: const LatLng(0, 0)),
        polylinePoints: [],
        totalDistance: '',
        totalDuration: '',
        walkingDuration: '',
      );
    }

    final data = Map<String, dynamic>.from(map['routes'][0]);

    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      northeast: LatLng(northeast['lat'], northeast['lng']),
      southwest: LatLng(southwest['lat'], southwest['lng']),
    );

    String distance = '';
    String duration = '';
    String timeToWalk = '';

    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];

      final distanceValue = leg['distance']['value']; // Distance in meters

      const walkingSpeed = 1.4; // Average walking speed in meters per second
      final walkingTimeInSeconds = (distanceValue / walkingSpeed).round();

      final walkingDurationDuration = Duration(seconds: walkingTimeInSeconds);
      final hours = walkingDurationDuration.inHours;
      final minutes = walkingDurationDuration.inMinutes.remainder(60);

      if (hours > 0 && minutes > 0) {
        timeToWalk = '$hours hours $minutes minutes';
      } else if (hours > 0) {
        timeToWalk = '$hours hours';
      } else {
        timeToWalk = '$minutes minutes';
      }
    }

    return Directions(
      bounds: bounds,
      polylinePoints:
          PolylinePoints().decodePolyline(data['overview_polyline']['points']),
      totalDistance: distance,
      totalDuration: duration,
      walkingDuration: timeToWalk,
    );
  }
}
