import 'package:flutter/material.dart';

// Colour gradient for app background
LinearGradient getAppGradient() {
  return const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF13438B), 
      Color(0xFF07569E),
      Color(0xFF0069B0),
      Color(0xFF007DC1),
      Color(0xFF0091D1),
      Color(0xFF00A6DF),
      Color(0xFF00BAED),
      Color(0xFF10CFF9), 
    ],
    stops: [
      0.0,
      0.12,
      0.24,
      0.36,
      0.48,
      0.60,
      0.72,
      1.0,
    ],
  );
}

//light blue: Color(0xFF00A6DF)
//midnight blue: Color(0xFF191970)
