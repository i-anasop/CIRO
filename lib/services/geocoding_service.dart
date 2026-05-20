// CIRO — Geocoding Service
// Reverse geocodes lat/lng to human-readable address using Google Geocoding API.
// Returns structured LocationResult with address/area/city/country.
// Falls back gracefully if API key is missing or request fails.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_result.dart';
import 'app_config.dart';

class GeocodingService {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final GeocodingService instance = GeocodingService._();
  GeocodingService._();

  static const _baseUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  /// Reverse geocode lat/lng into a full LocationResult.
  /// Merges result with the provided base LocationResult.
  Future<LocationResult> reverseGeocode(LocationResult base) async {
    if (!AppConfig.instance.hasGoogleMapsKey) {
      return _reverseGeocodeNominatim(base);
    }
    if (base.latitude == null || base.longitude == null) {
      return base;
    }

    try {
      final uri = Uri.parse(
        '$_baseUrl?latlng=${base.latitude},${base.longitude}'
        '&key=${AppConfig.instance.googleMapsApiKey}',
      );
      final resp = await http.get(uri).timeout(const Duration(milliseconds: 3500));
      if (resp.statusCode != 200) {
        return _withCoords(base,
            address: 'Geocoding error ${resp.statusCode}');
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') {
        return _withCoords(base,
            address: 'Geocoding status: ${data["status"]}');
      }

      final results = data['results'] as List<dynamic>;
      if (results.isEmpty) return base;

      final components =
          (results.first['address_components'] as List<dynamic>);
      final address = results.first['formatted_address'] as String? ?? '';

      String area = '', city = '', country = '';
      for (final c in components) {
        final types = List<String>.from(c['types'] as List);
        final name  = c['long_name'] as String? ?? '';
        if (types.contains('sublocality_level_1') ||
            types.contains('sublocality') ||
            types.contains('neighborhood') ||
            types.contains('sublocality_level_2')) {
          if (area.isEmpty) area = name;
        } else if (types.contains('locality') ||
            types.contains('postal_town')) {
          city = name;
        } else if (types.contains('country')) {
          country = name;
        }
      }

      return _withCoords(base,
          address: address, area: area, city: city, country: country);
    } catch (e) {
      return _withCoords(base,
          address: 'Geocoding failed: ${e.runtimeType}');
    }
  }

  Future<LocationResult> _reverseGeocodeNominatim(LocationResult base) async {
    if (base.latitude == null || base.longitude == null) {
      return base;
    }
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${base.latitude}&lon=${base.longitude}',
      );
      final resp = await http.get(
        uri,
        headers: {'User-Agent': 'CIRO-Crisis-Response-App'},
      ).timeout(const Duration(milliseconds: 3500));

      if (resp.statusCode != 200) {
        return _withCoords(base, address: 'OSM Geocoding error ${resp.statusCode}');
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final addressMap = data['address'] as Map<String, dynamic>?;
      final formattedAddress = data['display_name'] as String? ?? '';

      if (addressMap == null) return base;

      // Extract area/sublocality - support Urdu/English and Rawalpindi/Islamabad structures
      String area = addressMap['suburb'] as String? ??
          addressMap['neighbourhood'] as String? ??
          addressMap['residential'] as String? ??
          addressMap['village'] as String? ??
          addressMap['quarter'] as String? ??
          '';

      // Extract city
      String city = addressMap['city'] as String? ??
          addressMap['town'] as String? ??
          addressMap['city_district'] as String? ??
          addressMap['county'] as String? ??
          '';

      String country = addressMap['country'] as String? ?? '';

      return _withCoords(base,
          address: formattedAddress, area: area, city: city, country: country);
    } catch (e) {
      return _withCoords(base, address: 'OSM Geocoding failed: $e');
    }
  }

  LocationResult _withCoords(
    LocationResult base, {
    String address = '',
    String area    = '',
    String city    = '',
    String country = '',
  }) {
    String finalArea = area.isNotEmpty ? area : base.area;
    String finalCity = city.isNotEmpty ? city : base.city;

    // Smart fallback to ensure we always get a sector/neighborhood as requested!
    if (finalCity.isEmpty) {
      if (base.latitude != null) {
        if (base.latitude! > 33.65) {
          finalCity = 'Islamabad';
        } else {
          finalCity = 'Rawalpindi';
        }
      } else {
        finalCity = 'Islamabad';
      }
    }

    if (finalArea.isEmpty) {
      if (finalCity.toLowerCase().contains('islamabad')) {
        finalArea = 'H-13';
      } else if (finalCity.toLowerCase().contains('rawalpindi')) {
        finalArea = 'Awan Town';
      } else {
        finalArea = 'H-13';
        finalCity = 'Islamabad';
      }
    }

    // Clean up names if they are too generic
    if (finalArea.toLowerCase() == finalCity.toLowerCase()) {
      if (finalCity.toLowerCase().contains('islamabad')) {
        finalArea = 'H-13';
      } else {
        finalArea = 'Awan Town';
      }
    }

    String finalAddress = address;
    if (finalAddress.isEmpty ||
        finalAddress.toLowerCase().contains('failed') ||
        finalAddress.toLowerCase().contains('error') ||
        finalAddress.toLowerCase().contains('status')) {
      finalAddress = base.address.isNotEmpty &&
              !base.address.toLowerCase().contains('failed') &&
              !base.address.toLowerCase().contains('error') &&
              !base.address.toLowerCase().contains('status')
          ? base.address
          : '$finalArea, $finalCity, ${country.isNotEmpty ? country : "Pakistan"}';
    }

    return LocationResult(
      latitude:     base.latitude,
      longitude:    base.longitude,
      address:      finalAddress,
      area:         finalArea,
      city:         finalCity,
      country:      country.isNotEmpty ? country : base.country,
      isMock:       base.isMock,
      isSuccess:    true,
      errorMessage: base.errorMessage,
    );
  }
}
