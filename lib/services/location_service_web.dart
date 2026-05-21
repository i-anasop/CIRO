// CIRO — Web Location Platform Implementation
// Uses package:web and dart:js_interop (modern, non-deprecated approach).
// Calls browser navigator.geolocation.getCurrentPosition directly.

import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import '../models/location_result.dart';

Future<LocationResult> getCurrentLocationPlatform() async {
  final completer = Completer<LocationResult>();

  final successCallback = (web.GeolocationPosition pos) {
    final coords = pos.coords;
    completer.complete(LocationResult(
      latitude:  coords.latitude,
      longitude: coords.longitude,
      isMock:    false,
      isSuccess: true,
    ));
  }.toJS;

  final errorCallback = (web.GeolocationPositionError err) {
    String reason;
    switch (err.code) {
      case 1:
        reason = 'Permission denied by browser. Click the lock icon in the address bar to allow location, then try again.';
        break;
      case 2:
        reason = 'Position unavailable (no GPS or network location).';
        break;
      case 3:
        reason = 'Geolocation timed out.';
        break;
      default:
        reason = 'Unknown geolocation error (code ${err.code}).';
    }
    completer.complete(LocationResult(
      latitude:     33.6428,
      longitude:    72.9730,
      address:      'H-13, Islamabad, Pakistan',
      area:         'H-13',
      city:         'Islamabad',
      country:      'Pakistan',
      isMock:       true,
      isSuccess:    true,
      errorMessage: reason,
    ));
  }.toJS;

  web.window.navigator.geolocation.getCurrentPosition(
    successCallback,
    errorCallback,
  );

  return completer.future.timeout(
    const Duration(milliseconds: 2000),
    onTimeout: () => const LocationResult(
      latitude:     33.6428,
      longitude:    72.9730,
      address:      'H-13, Islamabad, Pakistan',
      area:         'H-13',
      city:         'Islamabad',
      country:      'Pakistan',
      isMock:       true,
      isSuccess:    true,
      errorMessage: 'Location request timed out after 2.0s.',
    ),
  );
}
