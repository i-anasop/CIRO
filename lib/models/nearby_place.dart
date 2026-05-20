// CIRO — Nearby Place Model
// Represents a real nearby facility from Google Places API.
// Used for shelters, hospitals, police stations, fire stations, pharmacies.

class NearbyPlace {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final NearbyPlaceType type;
  final double? rating;
  final bool? isOpen;
  final String? phoneNumber;

  const NearbyPlace({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.type,
    this.rating,
    this.isOpen,
    this.phoneNumber,
  });

  /// Human-readable type label.
  String get typeLabel => switch (type) {
    NearbyPlaceType.hospital => 'Hospital',
    NearbyPlaceType.policeStation => 'Police Station',
    NearbyPlaceType.fireStation => 'Fire Station',
    NearbyPlaceType.pharmacy => 'Pharmacy',
    NearbyPlaceType.shelter => 'Shelter / Community Center',
  };

  /// Icon name for UI display.
  String get iconName => switch (type) {
    NearbyPlaceType.hospital => 'local_hospital',
    NearbyPlaceType.policeStation => 'local_police',
    NearbyPlaceType.fireStation => 'fire_truck',
    NearbyPlaceType.pharmacy => 'local_pharmacy',
    NearbyPlaceType.shelter => 'night_shelter',
  };

  /// Distance label (e.g. "1.2 km" or "800 m").
  String get distanceLabel {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  /// Open/Closed label.
  String get statusLabel {
    if (isOpen == null) return 'Unknown';
    return isOpen! ? 'Open' : 'Closed';
  }
}

enum NearbyPlaceType {
  hospital,
  policeStation,
  fireStation,
  pharmacy,
  shelter,
}
