// CIRO — Real Signal Service
// Coordinator that runs LocationService, GeocodingService, WeatherService,
// NewsSignalService, and RoutesService in sequence.
// Returns a RealSignalBundle compatible with the existing agent pipeline.
// Never crashes — all failures surface as typed result fields.

import '../models/location_result.dart';
import '../models/weather_result.dart';
import '../models/news_signal.dart';
import '../models/route_result.dart';
import 'location_service.dart';
import 'geocoding_service.dart';
import 'weather_service.dart';
import 'news_signal_service.dart';
import 'routes_service.dart';
import 'app_config.dart';

/// The combined output from all real data services.
class RealSignalBundle {
  final LocationResult location;
  final WeatherResult? weather;
  final List<NewsSignal> newsSignals;
  final RouteResult? traffic;
  final bool succeeded;
  final List<String> warnings;

  const RealSignalBundle({
    required this.location,
    this.weather,
    this.newsSignals = const [],
    this.traffic,
    required this.succeeded,
    this.warnings    = const [],
  });

  /// Returns true if we got meaningful data from at least one real source.
  bool get hasRealData =>
      (weather?.isSuccess == true) ||
      newsSignals.isNotEmpty ||
      (traffic?.isSuccess == true);

  /// Active signal count (for UI display).
  int get signalCount {
    int count = 0;
    if (weather?.isSuccess == true && weather?.isCrisisRelevant == true) count++;
    count += newsSignals.length;
    if (traffic?.isSuccess == true) count++;
    return count;
  }

  /// One-line summary for dashboard preview.
  String get summary {
    final parts = <String>[];
    if (weather?.isSuccess == true) parts.add(weather!.rawSummary);
    if (newsSignals.isNotEmpty)     parts.add('${newsSignals.length} news signal(s)');
    if (traffic?.isSuccess == true) {
      parts.add('Traffic: ${traffic!.congestionLabel}');
    }
    return parts.isNotEmpty ? parts.join(' | ') : 'No real signals available';
  }
}

class RealSignalService {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final RealSignalService instance = RealSignalService._();
  RealSignalService._();

  /// Run the full real-data pipeline from GPS → geocode → weather → news → routes.
  /// Pass [useMockLocation: true] to skip GPS and use G-10 mock coords.
  Future<RealSignalBundle> fetchAll({
    bool useMockLocation = false,
    double? latitude,
    double? longitude,
  }) async {
    final warnings = <String>[];

    // 1. Location
    LocationResult location;
    if (latitude != null && longitude != null) {
      location = LocationResult(
        latitude:  latitude,
        longitude: longitude,
        isMock:    false,
        isSuccess: true,
      );
    } else if (useMockLocation) {
      location = LocationService.instance.getMockLocation();
    } else {
      location = await LocationService.instance.getCurrentLocation();
      if (!location.isSuccess) {
        warnings.add('GPS: ${location.errorMessage}');
        // Fall back to mock coordinates so downstream services still work
        location = LocationService.instance.getMockLocation();
      }
    }

    // 2. Geocode (always reverse geocode, falls back to OSM Nominatim if Google Key is missing)
    if (location.area.isEmpty) {
      location = await GeocodingService.instance.reverseGeocode(location);
    }

    final lat  = location.latitude  ?? 33.6946;
    final lon  = location.longitude ?? 73.0179;
    final city = location.city.isNotEmpty ? location.city : 'Islamabad';

    // 3. Weather (parallel with news + routes)
    final weatherFuture = AppConfig.instance.hasOpenWeatherKey
        ? WeatherService.instance.getWeather(lat, lon)
        : Future.value(WeatherResult.failure('No OpenWeather key configured'));

    final newsFuture = AppConfig.instance.hasNewsApiKey
        ? NewsSignalService.instance.fetchSignals(
            location.area.isNotEmpty ? '${location.area} $city' : city)
        : Future.value(<NewsSignal>[]);

    final routesFuture = AppConfig.instance.hasGoogleMapsKey
        ? RoutesService.instance.getTrafficConditions(lat, lon)
        : Future.value(RouteResult.failure('No Google Maps key configured'));

    // 4. Await all in parallel
    final results = await Future.wait([
      weatherFuture,
      newsFuture,
      routesFuture,
    ]);

    final weather    = results[0] as WeatherResult;
    final news       = results[1] as List<NewsSignal>;
    final traffic    = results[2] as RouteResult;

    if (!weather.isSuccess)  warnings.add('Weather: ${weather.errorMessage}');
    if (!traffic.isSuccess)  warnings.add('Traffic: ${traffic.errorMessage}');
    if (!AppConfig.instance.hasNewsApiKey) {
      warnings.add('News/Public Feed: No NewsAPI key configured');
    } else if (news.isEmpty) {
      warnings.add('News/Public Feed: no relevant local articles returned');
    }
    if (location.isMock) {
      warnings.add('Location: fallback coordinates used');
    }

    return RealSignalBundle(
      location:    location,
      weather:     weather.isSuccess  ? weather  : null,
      newsSignals: news,
      traffic:     traffic.isSuccess  ? traffic  : null,
      succeeded:   weather.isSuccess || news.isNotEmpty || traffic.isSuccess,
      warnings:    warnings,
    );
  }

  /// Quick service readiness check without making real API calls.
  Map<String, bool> checkReadiness() {
    final cfg = AppConfig.instance;
    return {
      'Google Maps / Routes':  cfg.hasGoogleMapsKey,
      'OpenWeather':           cfg.hasOpenWeatherKey,
      'NewsAPI':               cfg.hasNewsApiKey,
    };
  }
}
