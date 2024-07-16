import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ww_code/map_testing/location_provider.dart';

class MockLocationProvider extends LocationProvider {
  Marker? _origin;

  @override
  Marker? get origin => _origin;

  @override
  void setOriginMarker(Marker marker) {
    _origin = marker;
    notifyListeners();
  }
}
