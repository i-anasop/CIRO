// CIRO — Real Signal Service
// Coordinator that runs LocationService, GeocodingService, WeatherService,
// NewsSignalService, and RoutesService in sequence.
// Returns a RealSignalBundle compatible with the existing agent pipeline.
// Never crashes — all failures surface as typed result fields.

import '../models/location_result.dart';
import '../models/weather_result.dart';
import '../models/news_signal.dart';
import '../models/social_post_signal.dart';
import '../models/route_result.dart';
import 'location_service.dart';
import 'geocoding_service.dart';
import 'weather_service.dart';
import 'news_signal_service.dart';
import 'gnews_signal_service.dart';
import 'social_signal_service.dart';
import 'routes_service.dart';
import 'app_config.dart';
import 'signal_cache_service.dart';
import '../models/crisis.dart';
import 'scenario_engine.dart';

/// The combined output from all real data services.
class RealSignalBundle {
  final LocationResult location;
  final WeatherResult? weather;
  final List<NewsSignal> newsSignals;
  final List<SocialPostSignal> socialPosts;
  final RouteResult? traffic;
  final bool succeeded;
  final List<String> warnings;

  const RealSignalBundle({
    required this.location,
    this.weather,
    this.newsSignals = const [],
    this.socialPosts = const [],
    this.traffic,
    required this.succeeded,
    this.warnings = const [],
  });

  /// Returns true if we got meaningful data from at least one real source.
  bool get hasRealData =>
      (weather?.isSuccess == true) ||
      newsSignals.isNotEmpty ||
      socialPosts.isNotEmpty ||
      (traffic?.isSuccess == true);

  /// Active signal count (for UI display).
  int get signalCount {
    int count = 0;
    if (weather?.isSuccess == true && weather?.isCrisisRelevant == true) {
      count++;
    }
    count += newsSignals.length;
    count += socialPosts.length;
    if (traffic?.isSuccess == true) count++;
    return count;
  }

  /// One-line summary for dashboard preview.
  String get summary {
    final parts = <String>[];
    if (weather?.isSuccess == true) parts.add(weather!.rawSummary);
    if (newsSignals.isNotEmpty) {
      parts.add('${newsSignals.length} news signal(s)');
    }
    if (socialPosts.isNotEmpty) {
      parts.add('${socialPosts.length} social signal(s)');
    }
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
        latitude: latitude,
        longitude: longitude,
        isMock: false,
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

    final lat = location.latitude ?? 33.6946;
    final lon = location.longitude ?? 73.0179;
    final city = location.city.isNotEmpty ? location.city : 'Islamabad';

    // 3. Weather, news, and routes fetched in parallel
    final weatherFuture = AppConfig.instance.hasOpenWeatherKey
        ? WeatherService.instance.getWeather(lat, lon)
        : Future.value(WeatherResult.failure('No OpenWeather key configured'));

    // News: Try NewsAPI first, then GNews + ReliefWeb (always try both in parallel)
    final locationQuery = location.area.isNotEmpty
        ? '${location.area} $city'
        : city;
    final newsFuture =
        Future.wait([
          AppConfig.instance.hasNewsApiKey
              ? NewsSignalService.instance.fetchSignals(locationQuery)
              : Future.value(<NewsSignal>[]),
          GnewsSignalService.instance.fetchSignals(locationQuery),
        ]).then((results) {
          final combined = <NewsSignal>[...results[0], ...results[1]];
          // Deduplicate by title/source while keeping enough real articles to
          // populate active crisis and community feed surfaces.
          final seen = <String>{};
          return combined
              .where((s) {
                final normalizedTitle = s.title
                    .toLowerCase()
                    .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
                    .replaceAll(RegExp(r'\s+'), ' ')
                    .trim();
                final end = normalizedTitle.length > 72
                    ? 72
                    : normalizedTitle.length;
                final key =
                    '${s.source.toLowerCase()}-${normalizedTitle.substring(0, end)}';
                return seen.add(key);
              })
              .take(16)
              .toList();
        });

    final routesFuture = AppConfig.instance.hasGoogleMapsKey
        ? RoutesService.instance.getTrafficConditions(lat, lon)
        : Future.value(RouteResult.failure('No Google Maps key configured'));

    // 4. Await all in parallel
    final results = await Future.wait([
      weatherFuture,
      newsFuture,
      routesFuture,
    ]);

    final weather = results[0] as WeatherResult;
    final news = results[1] as List<NewsSignal>;
    final traffic = results[2] as RouteResult;

    if (!weather.isSuccess) warnings.add('Weather: ${weather.errorMessage}');
    if (!traffic.isSuccess) warnings.add('Traffic: ${traffic.errorMessage}');
    if (!AppConfig.instance.hasNewsApiKey) {
      warnings.add('News/Public Feed: No NewsAPI key configured');
    } else if (news.isEmpty) {
      warnings.add('News/Public Feed: no relevant local articles returned');
    }
    if (location.isMock) {
      warnings.add('Location: fallback coordinates used');
    }

    WeatherResult finalWeather = weather;
    List<NewsSignal> finalNews = List<NewsSignal>.from(news);
    RouteResult finalTraffic = traffic;

    final injectedType = ScenarioEngine.instance.injectedRealCrisisType;
    if (injectedType != null) {
      warnings.add('Real Mode: Simulated threat signals injected for testing.');
      // Clear key/service warnings to prevent dashboard clutter
      warnings.removeWhere(
        (w) =>
            w.contains('Weather:') ||
            w.contains('Traffic:') ||
            w.contains('News/Public Feed:'),
      );

      switch (injectedType) {
        case CrisisType.urbanFlooding:
          finalWeather = WeatherResult(
            temperature: 24.2,
            feelsLike: 25.0,
            condition: 'Heavy Rain',
            description: 'Torrential downpour and active monsoon storm',
            humidity: 95,
            windSpeed: 18.5,
            rainfallLastHour: 22.5,
            alertLevel: WeatherRisk.floodRisk,
            isSuccess: true,
            rawSummary: 'Rain: 22.5mm/hr | Active Flood Warning',
          );
          finalNews = [
            NewsSignal(
              title:
                  'Flash flooding and waterlogging reported on major roads near $city.',
              description:
                  'Continuous torrential rains have inundated low-lying areas in $city. Civil authorities advise caution.',
              source: 'Met Office Alert',
              matchedKeyword: 'flood',
              publishedAt: DateTime.now(),
              url: 'https://ciro.alert.gov',
              confidenceHint: 0.95,
            ),
          ];
          finalTraffic = const RouteResult(
            normalDurationMinutes: 12,
            trafficDurationMinutes: 28,
            distanceKm: 5.4,
            congestionLevel: CongestionLevel.high,
            routeSummary: 'Islamabad Highway',
            isSuccess: true,
          );
          break;
        case CrisisType.heatwave:
          finalWeather = WeatherResult(
            temperature: 43.5,
            feelsLike: 47.0,
            condition: 'Extreme Heat',
            description: 'Severe heatwave conditions with high UV index',
            humidity: 15,
            windSpeed: 8.0,
            rainfallLastHour: 0,
            alertLevel: WeatherRisk.heatwave,
            isSuccess: true,
            rawSummary: 'Temp: 43.5°C | Feels like: 47.0°C | Heatwave Warning',
          );
          finalNews = [
            NewsSignal(
              title:
                  'Government issues red alert for extreme heatwave in $city region.',
              description:
                  'Temperatures projected to touch 44°C. cooling centers activated. Citizens advised to remain indoors.',
              source: 'Public Health Department',
              matchedKeyword: 'heatwave',
              publishedAt: DateTime.now(),
              url: 'https://ciro.alert.gov',
              confidenceHint: 0.95,
            ),
          ];
          finalTraffic = const RouteResult(
            normalDurationMinutes: 10,
            trafficDurationMinutes: 11,
            distanceKm: 4.8,
            congestionLevel: CongestionLevel.low,
            routeSummary: 'Arterial Road 1',
            isSuccess: true,
          );
          break;
        case CrisisType.accident:
          finalWeather = WeatherResult(
            temperature: 28.0,
            feelsLike: 29.5,
            condition: 'Clear',
            description: 'Clear conditions',
            humidity: 50,
            windSpeed: 6.2,
            rainfallLastHour: 0,
            alertLevel: WeatherRisk.none,
            isSuccess: true,
            rawSummary: 'Temp: 28°C | Clear Sky',
          );
          finalNews = [
            NewsSignal(
              title:
                  'Major multi-vehicle accident reported near geocoded sector in $city.',
              description:
                  'Emergency services responding to a crash. Lane closures causing severe delays.',
              source: 'Police Dispatch',
              matchedKeyword: 'accident',
              publishedAt: DateTime.now(),
              url: 'https://ciro.alert.gov',
              confidenceHint: 0.90,
            ),
          ];
          finalTraffic = const RouteResult(
            normalDurationMinutes: 15,
            trafficDurationMinutes: 32,
            distanceKm: 6.2,
            congestionLevel: CongestionLevel.high,
            routeSummary: 'Sector Arterial Road',
            isSuccess: true,
          );
          break;
        case CrisisType.powerOutage:
          finalWeather = WeatherResult(
            temperature: 32.0,
            feelsLike: 35.0,
            condition: 'Haze',
            description: 'Warm, hazy conditions',
            humidity: 60,
            windSpeed: 4.5,
            rainfallLastHour: 0,
            alertLevel: WeatherRisk.none,
            isSuccess: true,
            rawSummary: 'Temp: 32°C | Hazy',
          );
          finalNews = [
            NewsSignal(
              title:
                  'Power grid substation failure causes major outage in $city.',
              description:
                  'Electricity offline in multiple sectors. Utility crews estimate 3 hours for complete restoration.',
              source: 'Grid Operations',
              matchedKeyword: 'outage',
              publishedAt: DateTime.now(),
              url: 'https://ciro.alert.gov',
              confidenceHint: 0.85,
            ),
          ];
          finalTraffic = const RouteResult(
            normalDurationMinutes: 10,
            trafficDurationMinutes: 13,
            distanceKm: 4.1,
            congestionLevel: CongestionLevel.medium,
            routeSummary: 'Grid Center Road',
            isSuccess: true,
          );
          break;
        case CrisisType.roadBlockage:
          finalWeather = WeatherResult(
            temperature: 26.5,
            feelsLike: 27.0,
            condition: 'Overcast',
            description: 'Cloudy conditions',
            humidity: 75,
            windSpeed: 10.0,
            rainfallLastHour: 0,
            alertLevel: WeatherRisk.none,
            isSuccess: true,
            rawSummary: 'Temp: 26.5°C | Overcast',
          );
          finalNews = [
            NewsSignal(
              title:
                  'Significant road blockage reported on main arterial corridor in $city.',
              description:
                  'All lanes blocked due to structural hazard/debris. Commuters urged to take alternative routes.',
              source: 'Municipal Transit',
              matchedKeyword: 'blockage',
              publishedAt: DateTime.now(),
              url: 'https://ciro.alert.gov',
              confidenceHint: 0.90,
            ),
          ];
          finalTraffic = const RouteResult(
            normalDurationMinutes: 12,
            trafficDurationMinutes: 35,
            distanceKm: 5.0,
            congestionLevel: CongestionLevel.high,
            routeSummary: 'Main Expressway Link',
            isSuccess: true,
          );
          break;
      }
    }

    final socialPosts = await SocialSignalService.instance.fetchRelevantPosts(
      city: city,
      fallbackNews: finalNews,
    );

    final bundle = RealSignalBundle(
      location: location,
      weather: finalWeather.isSuccess ? finalWeather : null,
      newsSignals: finalNews,
      socialPosts: socialPosts,
      traffic: finalTraffic.isSuccess ? finalTraffic : null,
      succeeded:
          finalWeather.isSuccess ||
          finalNews.isNotEmpty ||
          socialPosts.isNotEmpty ||
          finalTraffic.isSuccess,
      warnings: warnings,
    );
    await SignalCacheService.instance.cacheBundle(bundle);
    return bundle;
  }

  /// Quick service readiness check without making real API calls.
  Map<String, bool> checkReadiness() {
    final cfg = AppConfig.instance;
    return {
      'Google Maps / Routes': cfg.hasGoogleMapsKey,
      'OpenWeather': cfg.hasOpenWeatherKey,
      'NewsAPI': cfg.hasNewsApiKey,
    };
  }
}
