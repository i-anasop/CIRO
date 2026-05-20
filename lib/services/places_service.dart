// CIRO — Places Service
// Uses Google Places API (New) — Nearby Search to find real facilities.
// Searches for hospitals, police, fire stations, pharmacies, shelters.
// Falls back gracefully on missing key or API error.

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/nearby_place.dart';
import 'app_config.dart';

class PlacesService {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final PlacesService instance = PlacesService._();
  PlacesService._();

  // Cache to avoid repeated API calls for the same location
  final Map<String, List<NearbyPlace>> _cache = {};

  static const _url =
      'https://places.googleapis.com/v1/places:searchNearby';

  /// Fetch all nearby emergency-relevant places for a location.
  /// Returns cached results if available for same lat/lng rounded to 3 decimals.
  Future<List<NearbyPlace>> fetchNearbyPlaces(double lat, double lng) async {
    final cacheKey = '${lat.toStringAsFixed(3)},${lng.toStringAsFixed(3)}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    if (!AppConfig.instance.hasGoogleMapsKey) {
      debugPrint('[PlacesService] Google Maps key not configured');
      return [];
    }

    final results = <NearbyPlace>[];

    // Fetch each type in parallel
    final futures = <Future<List<NearbyPlace>>>[];
    futures.add(_searchType(lat, lng, ['hospital'], NearbyPlaceType.hospital));
    futures.add(_searchType(lat, lng, ['police'], NearbyPlaceType.policeStation));
    futures.add(_searchType(lat, lng, ['fire_station'], NearbyPlaceType.fireStation));
    futures.add(_searchType(lat, lng, ['pharmacy'], NearbyPlaceType.pharmacy));
    futures.add(_searchType(lat, lng, ['community_center', 'mosque', 'church'], NearbyPlaceType.shelter));

    final allResults = await Future.wait(futures);
    for (final list in allResults) {
      results.addAll(list);
    }

    // Sort by distance
    results.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    _cache[cacheKey] = results;
    return results;
  }

  /// Fetch a specific type of nearby places.
  Future<List<NearbyPlace>> fetchByType(
    double lat, double lng, NearbyPlaceType type,
  ) async {
    final all = await fetchNearbyPlaces(lat, lng);
    return all.where((p) => p.type == type).toList();
  }

  /// Clear the cache (e.g. when location changes).
  void clearCache() => _cache.clear();

  // ── Internal API call ─────────────────────────────────────────────────────

  Future<List<NearbyPlace>> _searchType(
    double lat, double lng,
    List<String> includedTypes,
    NearbyPlaceType placeType,
  ) async {
    try {
      final body = jsonEncode({
        'includedTypes': includedTypes,
        'maxResultCount': 5,
        'locationRestriction': {
          'circle': {
            'center': {'latitude': lat, 'longitude': lng},
            'radius': 5000.0, // 5km radius
          },
        },
      });

      final resp = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': AppConfig.instance.googleMapsApiKey,
          'X-Goog-FieldMask': 'places.displayName,places.formattedAddress,'
              'places.location,places.rating,'
              'places.currentOpeningHours,places.nationalPhoneNumber',
        },
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (resp.statusCode != 200) {
        debugPrint('[PlacesService] API error ${resp.statusCode}: ${resp.body}');
        return [];
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final places = (data['places'] as List<dynamic>?) ?? [];

      return places.map((p) {
        final place = p as Map<String, dynamic>;
        final loc = place['location'] as Map<String, dynamic>? ?? {};
        final pLat = (loc['latitude'] as num?)?.toDouble() ?? lat;
        final pLng = (loc['longitude'] as num?)?.toDouble() ?? lng;
        final displayName = place['displayName'] as Map<String, dynamic>? ?? {};

        return NearbyPlace(
          name: displayName['text'] as String? ?? 'Unknown',
          address: place['formattedAddress'] as String? ?? '',
          latitude: pLat,
          longitude: pLng,
          distanceKm: _haversine(lat, lng, pLat, pLng),
          type: placeType,
          rating: (place['rating'] as num?)?.toDouble(),
          isOpen: (place['currentOpeningHours']
              as Map<String, dynamic>?)?['openNow'] as bool?,
          phoneNumber: place['nationalPhoneNumber'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('[PlacesService] Error fetching $placeType: $e');
      return [];
    }
  }

  /// Haversine distance formula (km).
  double _haversine(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0; // Earth radius in km
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * pi / 180;
}
