// CIRO — LocationResult Model
// Typed result returned by LocationService.
// isMock=true means no real GPS was used.

class LocationResult {
  final double? latitude;
  final double? longitude;
  final String address;
  final String area;
  final String city;
  final String country;
  final bool isMock;
  final bool isSuccess;
  final String? errorMessage;

  const LocationResult({
    this.latitude,
    this.longitude,
    this.address     = '',
    this.area        = '',
    this.city        = '',
    this.country     = '',
    this.isMock      = false,
    this.isSuccess   = true,
    this.errorMessage,
  });

  /// Convenience failure constructor.
  factory LocationResult.failure(String message) => LocationResult(
        isSuccess:    false,
        isMock:       false,
        errorMessage: message,
      );

  /// Mock location for Islamabad G-10 (primary demo zone).
  factory LocationResult.mockIslamabad() => const LocationResult(
        latitude:  33.6946,
        longitude: 73.0179,
        address:   'G-10 Markaz, Islamabad, Pakistan',
        area:      'G-10',
        city:      'Islamabad',
        country:   'Pakistan',
        isMock:    true,
        isSuccess: true,
      );

  String get displayLabel =>
      area.isNotEmpty ? '$area, $city' : city.isNotEmpty ? city : 'Unknown';
}
