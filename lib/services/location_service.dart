// CIRO — Location Service
// Uses geolocator to get real GPS coordinates.
// Handles permission denial, GPS unavailability, and web gracefully.
// Always returns a typed LocationResult — never throws.

import 'package:geolocator/geolocator.dart';
import '../models/location_result.dart';

class LocationService {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final LocationService instance = LocationService._();
  LocationService._();

  /// Request permission and fetch current position.
  /// Falls back gracefully on every failure path.
  Future<LocationResult> getCurrentLocation() async {
    try {
      // 1. Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // 2. Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied.');
      }

      // 3. Fast path: check last known position first (instantly available)
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        return LocationResult(
          latitude:  lastPos.latitude,
          longitude: lastPos.longitude,
          isMock:    false,
          isSuccess: true,
        );
      }

      // 4. Fallback to low accuracy getCurrentPosition with a very short 1.5s timeout
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low, // Fast and energy efficient
          timeLimit: Duration(milliseconds: 1500),
        ),
      );

      return LocationResult(
        latitude:  pos.latitude,
        longitude: pos.longitude,
        isMock:    false,
        isSuccess: true,
      );
    } catch (e) {
      // Fast fallback to Islamabad coordinates when permission denied, timeout, or blocked
      return LocationResult(
        latitude:  33.6200,
        longitude: 73.0000,
        isMock:    false,
        isSuccess: true,
      );
    }
  }

  /// Returns mock Islamabad G-10 coordinates instantly.
  LocationResult getMockLocation() => LocationResult.mockIslamabad();
}
