import 'package:flutter/material.dart';

Widget createInteractiveMap({
  required double latitude,
  required double longitude,
  required int zoom,
  required String selectedLayer,
  bool showRiskZone = false,
  bool showAltRoute = false,
}) {
  // Native mobile fallback — show a placeholder (geolocator-based map plugins
  // would be added here for a production mobile release)
  return Container(
    color: const Color(0xFFEDF4FF),
    child: const Center(
      child: Icon(Icons.map_rounded, color: Color(0xFF4F46E5), size: 48),
    ),
  );
}
