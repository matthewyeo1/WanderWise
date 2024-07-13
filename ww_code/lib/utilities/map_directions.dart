import 'package:dio/dio.dart';
import 'package:ww_code/utilities/directions_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsRepository {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  final Dio _dio;

  DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final response = await _dio.get(
      _baseUrl,
      queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': "AIzaSyB3dkvAT_hUG51l98FOsmqE0FVS5xwqCcI",
      },
    );

    // Check if response is successful
    if (response.statusCode == 200) {
      return Directions.fromMap(response.data);
    }
    return Directions(
        bounds: LatLngBounds(
          northeast: const LatLng(0, 0),
          southwest: const LatLng(0, 0)
        ),
        polylinePoints: [],
        totalDistance: '',
        totalDuration: '',
        walkingDuration: '',
      );
  }
}