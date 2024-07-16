import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class LocationProvider extends ChangeNotifier {
  Marker? get origin;
  void setOriginMarker(Marker marker);
}
