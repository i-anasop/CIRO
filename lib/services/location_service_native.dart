// CIRO — Native Location Platform Stub
// On native (Android/iOS), the main LocationService._getNativeLocation() handles GPS.
// This file just satisfies the conditional import requirement.

import '../models/location_result.dart';

Future<LocationResult> getCurrentLocationPlatform() async {
  // Should never be called on native — LocationService routes to _getNativeLocation() directly.
  return const LocationResult(
    latitude:     33.6428,
    longitude:    72.9730,
    address:      'H-13, Islamabad, Pakistan',
    area:         'H-13',
    city:         'Islamabad',
    country:      'Pakistan',
    isMock:       true,
    isSuccess:    true,
    errorMessage: 'Native stub called unexpectedly',
  );
}
