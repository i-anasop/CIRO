// CIRO — Routes Service
// Calls Google Routes API to get traffic-aware travel duration.
// Computes congestion level from delay ratio.
// Uses a safe nearby reference point when no explicit destination is provided.
// Falls back gracefully on missing key or API error.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/route_result.dart';
import 'app_config.dart';

class RoutesService {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final RoutesService instance = RoutesService._();
  RoutesService._();

  static const _url =
      'https://routes.googleapis.com/directions/v2:computeRoutes';

  /// Get traffic-aware route from origin to a nearby point (2km offset).
  /// Nearest major point is derived by slightly offsetting the origin.
  Future<RouteResult> getTrafficConditions(
      double originLat, double originLon) async {
    if (!AppConfig.instance.hasGoogleMapsKey) {
      return RouteResult.failure('Google Maps key not configured');
    }

    // Destination: 2km north (rough offset for local traffic check)
    final destLat = originLat + 0.018;
    final destLon = originLon;

    final body = jsonEncode({
      'origin': {
        'location': {
          'latLng': {'latitude': originLat, 'longitude': originLon}
        }
      },
      'destination': {
        'location': {
          'latLng': {'latitude': destLat, 'longitude': destLon}
        }
      },
      'travelMode':              'DRIVE',
      'routingPreference':       'TRAFFIC_AWARE',
      'computeAlternativeRoutes': false,
      'routeModifiers': {'avoidTolls': false, 'avoidHighways': false},
    });

    try {
      final resp = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type':             'application/json',
          'X-Goog-Api-Key':           AppConfig.instance.googleMapsApiKey,
          'X-Goog-FieldMask':
              'routes.duration,routes.staticDuration,'
              'routes.distanceMeters,routes.description',
        },
        body: body,
      ).timeout(const Duration(seconds: 12));

      if (resp.statusCode != 200) {
        return RouteResult.failure('Routes API error ${resp.statusCode}');
      }

      final data   = jsonDecode(resp.body) as Map<String, dynamic>;
      final routes = (data['routes'] as List<dynamic>?);
      if (routes == null || routes.isEmpty) {
        return RouteResult.failure('No routes returned');
      }

      final route      = routes.first as Map<String, dynamic>;
      final distMeters = (route['distanceMeters'] as num?)?.toInt() ?? 0;
      final summary    = route['description'] as String? ?? 'Local route';

      // Parse durations — format "NNNs"
      final staticSec  = _parseSecs(route['staticDuration']  as String?);
      final trafficSec = _parseSecs(route['duration']        as String?);

      final normalMin  = (staticSec  / 60).round().clamp(1, 9999);
      final trafficMin = (trafficSec / 60).round().clamp(1, 9999);
      final ratio      = normalMin == 0 ? 1.0 : trafficMin / normalMin;

      CongestionLevel level;
      if (ratio < 1.2) {
        level = CongestionLevel.low;
      } else if (ratio < 1.6) {
        level = CongestionLevel.medium;
      } else {
        level = CongestionLevel.high;
      }

      return RouteResult(
        normalDurationMinutes:  normalMin,
        trafficDurationMinutes: trafficMin,
        distanceKm:             distMeters / 1000,
        congestionLevel:        level,
        routeSummary:           summary,
        isSuccess:              true,
      );
    } catch (e) {
      return RouteResult.failure('Routes request failed: ${e.runtimeType}');
    }
  }

  /// Parse Google's duration string "123s" → seconds integer.
  int _parseSecs(String? s) {
    if (s == null) return 0;
    final cleaned = s.replaceAll('s', '').trim();
    return int.tryParse(cleaned) ?? 0;
  }
}
