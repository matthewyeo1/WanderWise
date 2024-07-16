import 'location_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RealLocationProvider extends LocationProvider {
  Marker? _origin;

  @override
  Marker? get origin => _origin;

  @override
  void setOriginMarker(Marker marker) {
    _origin = marker;
    notifyListeners();
  }
}
