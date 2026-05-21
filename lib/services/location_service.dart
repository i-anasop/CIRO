// CIRO — Location Service
// Uses dart:html navigator.geolocation directly on web (not geolocator)
// because geolocator's timeLimit is ignored on web and silently times out.
// Falls back to Geolocator on native platforms (Android/iOS).
// Always returns a typed LocationResult — never throws.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import '../models/location_result.dart';

// Web-only imports via conditional import
import 'location_service_web.dart'
    if (dart.library.io) 'location_service_native.dart' as platform;

class LocationService {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final LocationService instance = LocationService._();
  LocationService._();

  /// Request permission and fetch current position.
  /// On web: uses browser navigator.geolocation directly.
  /// On native: uses geolocator package.
  Future<LocationResult> getCurrentLocation() async {
    if (kIsWeb) {
      return platform.getCurrentLocationPlatform();
    }
    return _getNativeLocation();
  }

  Future<LocationResult> _getNativeLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _fallback('Location services are disabled on this device.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _fallback('Location permission denied.');
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(milliseconds: 2000),
        ),
      );

      return LocationResult(
        latitude:  pos.latitude,
        longitude: pos.longitude,
        isMock:    false,
        isSuccess: true,
      );
    } catch (e) {
      return _fallback('Native GPS error: $e');
    }
  }

  LocationResult _fallback(String reason) {
    return LocationResult(
      latitude:     33.6428,
      longitude:    72.9730,
      address:      'H-13, Islamabad, Pakistan',
      area:         'H-13',
      city:         'Islamabad',
      country:      'Pakistan',
      isMock:       true,
      isSuccess:    true,
      errorMessage: reason,
    );
  }

  /// Returns mock Islamabad G-10 coordinates instantly.
  LocationResult getMockLocation() => LocationResult.mockIslamabad();
}
