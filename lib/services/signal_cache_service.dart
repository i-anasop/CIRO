import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cached_signal.dart';
import '../models/crisis.dart';
import '../models/news_signal.dart';
import '../models/route_result.dart';
import '../models/signal.dart';
import '../models/social_post_signal.dart';
import '../models/weather_result.dart';

class SignalCacheService extends ChangeNotifier {
  SignalCacheService._();
  static final SignalCacheService instance = SignalCacheService._();

  static const _cacheKey = 'ciro.signal_cache.v2.real_only';
  static const _maxSignals = 80;
  final List<CachedSignal> _signals = [];
  bool _loaded = false;

  List<CachedSignal> get rankedSignals {
    final now = DateTime.now();
    final fresh = _signals.where((signal) => signal.expiresAt.isAfter(now)).toList();
    fresh.sort((a, b) => b.rankScore.compareTo(a.rankScore));
    return fresh;
  }

  CachedSignal? get topSignal {
    final ranked = rankedSignals;
    return ranked.isEmpty ? null : ranked.first;
  }

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_cacheKey) ?? const [];
    _signals
      ..clear()
      ..addAll(raw.map((item) {
        try {
          return CachedSignal.fromJson(jsonDecode(item) as Map<String, dynamic>);
        } catch (_) {
          return null;
        }
      }).whereType<CachedSignal>());
    _loaded = true;
    await _persistPruned();
  }

  Future<void> cacheBundle(dynamic bundle) async {
    await ensureLoaded();
    if (bundle.warnings.any(
      (warning) => warning.toString().contains('Simulated threat'),
    )) {
      return;
    }
    final now = DateTime.now();
    final city = bundle.location.city.isNotEmpty ? bundle.location.city : 'Islamabad';
    final area = bundle.location.area;
    final lat = bundle.location.latitude;
    final lng = bundle.location.longitude;
    final signals = <CachedSignal>[];

    final weather = bundle.weather;
    if (weather?.isSuccess == true) {
      signals.add(_fromWeather(weather!, city, area, lat, lng, now));
    }

    for (final item in bundle.newsSignals) {
      signals.add(_fromNews(item, city, area, lat, lng, now));
    }

    for (final item in bundle.socialPosts) {
      signals.add(_fromSocial(item, city, area, lat, lng, now));
    }

    final traffic = bundle.traffic;
    if (traffic?.isSuccess == true) {
      signals.add(_fromTraffic(traffic!, city, area, lat, lng, now));
    }

    if (signals.isNotEmpty) {
      await upsertAll(signals);
    }
  }

  Future<void> cacheUserReport({
    required String title,
    required String body,
    required String location,
    required String tag,
    double? latitude,
    double? longitude,
  }) async {
    await ensureLoaded();
    final now = DateTime.now();
    final type = _typeFromText('$title $body $tag');
    await upsertAll([
      CachedSignal(
        id: 'user-${now.microsecondsSinceEpoch}',
        source: SignalSource.citizenReport,
        sourceName: 'Citizen report',
        city: _cityFromLocation(location),
        area: location,
        title: title.isEmpty ? 'Citizen crisis report' : title,
        content: body,
        crisisTypeHint: type ?? CrisisType.roadBlockage,
        severityHint: SeverityLevel.moderate,
        confidence: 0.72,
        timestamp: now,
        expiresAt: now.add(const Duration(hours: 6)),
        latitude: latitude,
        longitude: longitude,
        freshness: SignalFreshness.live,
        contributesToActiveCrisis: true,
      ),
    ]);
  }

  Future<void> upsertAll(List<CachedSignal> incoming) async {
    await ensureLoaded();
    final byId = {for (final signal in _signals) signal.id: signal};
    for (final signal in incoming) {
      byId[signal.id] = signal;
    }
    _signals
      ..clear()
      ..addAll(byId.values);
    await _persistPruned();
    notifyListeners();
  }

  Future<void> _persistPruned() async {
    final now = DateTime.now();
    _signals.removeWhere((signal) => signal.expiresAt.isBefore(now));
    _signals.sort((a, b) => b.rankScore.compareTo(a.rankScore));
    if (_signals.length > _maxSignals) {
      _signals.removeRange(_maxSignals, _signals.length);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _cacheKey,
      _signals.map((signal) => jsonEncode(signal.toJson())).toList(),
    );
  }

  CachedSignal _fromWeather(
    WeatherResult weather,
    String city,
    String area,
    double? lat,
    double? lng,
    DateTime now,
  ) {
    final type = switch (weather.alertLevel) {
      WeatherRisk.floodRisk || WeatherRisk.heavyRain || WeatherRisk.storm =>
        CrisisType.urbanFlooding,
      WeatherRisk.heatwave => CrisisType.heatwave,
      WeatherRisk.none || WeatherRisk.unknown => null,
    };
    final severity = switch (weather.alertLevel) {
      WeatherRisk.floodRisk => SeverityLevel.critical,
      WeatherRisk.heatwave || WeatherRisk.heavyRain || WeatherRisk.storm =>
        SeverityLevel.high,
      WeatherRisk.none || WeatherRisk.unknown => SeverityLevel.low,
    };
    return CachedSignal(
      id: 'weather-$city-${now.millisecondsSinceEpoch ~/ 60000}',
      source: SignalSource.weatherAlert,
      sourceName: 'OpenWeather',
      city: city,
      area: area,
      title: weather.alertLabel,
      content: weather.rawSummary,
      crisisTypeHint: type ?? CrisisType.roadBlockage,
      severityHint: severity,
      confidence: weather.isCrisisRelevant ? 0.92 : 0.62,
      timestamp: now,
      expiresAt: now.add(const Duration(hours: 2)),
      latitude: lat,
      longitude: lng,
      contributesToActiveCrisis: weather.isCrisisRelevant,
    );
  }

  CachedSignal _fromNews(
    NewsSignal news,
    String city,
    String area,
    double? lat,
    double? lng,
    DateTime now,
  ) {
    final published = news.publishedAt;
    final timestamp = published == null || now.difference(published).inDays > 7
        ? now
        : published;
    final type = _typeFromText(
      '${news.title} ${news.description} ${news.matchedKeyword}',
    );
    return CachedSignal(
      id: 'news-${news.url.hashCode.abs()}',
      source: SignalSource.socialPost,
      sourceName: news.source,
      city: city,
      area: area,
      title: news.title,
      content: news.shortSummary,
      crisisTypeHint: type ?? CrisisType.roadBlockage,
      severityHint: _severityFromType(type, news.confidenceHint, fromNews: true),
      confidence: news.confidenceHint,
      timestamp: timestamp,
      expiresAt: now.add(const Duration(hours: 24)),
      latitude: lat,
      longitude: lng,
      freshness: now.difference(timestamp).inMinutes > 15
          ? SignalFreshness.cached
          : SignalFreshness.live,
      contributesToActiveCrisis: news.confidenceHint >= 0.70,
    );
  }

  CachedSignal _fromSocial(
    SocialPostSignal post,
    String city,
    String area,
    double? lat,
    double? lng,
    DateTime now,
  ) {
    final published = post.publishedAt;
    final timestamp = published == null || now.difference(published).inDays > 7
        ? now
        : published;
    final type = _typeFromText('${post.text} ${post.matchedKeyword}');
    return CachedSignal(
      id: 'social-${post.id}',
      source: SignalSource.socialPost,
      sourceName: post.handle,
      city: city,
      area: post.location.isNotEmpty ? post.location : area,
      title: post.verifiedSource ? 'Official public signal' : 'Public signal',
      content: post.text,
      crisisTypeHint: type ?? CrisisType.roadBlockage,
      severityHint: _severityFromType(type, post.confidence, fromNews: true),
      confidence: post.confidence,
      timestamp: timestamp,
      expiresAt: now.add(const Duration(hours: 12)),
      latitude: lat,
      longitude: lng,
      freshness: post.verifiedSource ? SignalFreshness.live : SignalFreshness.cached,
      contributesToActiveCrisis: post.confidence >= 0.70,
    );
  }

  CachedSignal _fromTraffic(
    RouteResult traffic,
    String city,
    String area,
    double? lat,
    double? lng,
    DateTime now,
  ) {
    final severe = traffic.congestionLevel == CongestionLevel.high;
    return CachedSignal(
      id: 'traffic-$city-${now.millisecondsSinceEpoch ~/ 60000}',
      source: SignalSource.trafficData,
      sourceName: 'Google Routes',
      city: city,
      area: area,
      title: '${traffic.congestionLabel} traffic congestion',
      content:
          '${traffic.routeSummary}: ${traffic.normalDurationMinutes}m normal, ${traffic.trafficDurationMinutes}m with traffic, ${traffic.delayMinutes}m delay.',
      crisisTypeHint: severe ? CrisisType.roadBlockage : null,
      severityHint: severe
          ? SeverityLevel.high
          : traffic.congestionLevel == CongestionLevel.medium
              ? SeverityLevel.moderate
              : SeverityLevel.low,
      confidence: severe ? 0.88 : 0.64,
      timestamp: now,
      expiresAt: now.add(const Duration(hours: 1)),
      latitude: lat,
      longitude: lng,
      contributesToActiveCrisis: severe,
    );
  }

  static CrisisType? _typeFromText(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('flood') ||
        lower.contains('rain') ||
        lower.contains('waterlog')) {
      return CrisisType.urbanFlooding;
    }
    if (lower.contains('heat')) return CrisisType.heatwave;
    if (lower.contains('accident') ||
        lower.contains('collision') ||
        lower.contains('crash')) {
      return CrisisType.accident;
    }
    if (lower.contains('outage') ||
        lower.contains('blackout') ||
        lower.contains('power')) {
      return CrisisType.powerOutage;
    }
    if (lower.contains('traffic') ||
        lower.contains('blocked') ||
        lower.contains('blockage')) {
      return CrisisType.roadBlockage;
    }
    return null;
  }

  static SeverityLevel _severityFromType(
    CrisisType? type,
    double confidence, {
    bool fromNews = false,
  }) {
    if (type == null) return fromNews ? SeverityLevel.moderate : SeverityLevel.low;
    if (confidence >= 0.88) return SeverityLevel.high;
    if (confidence >= 0.70) return SeverityLevel.moderate;
    return SeverityLevel.low;
  }

  static String _cityFromLocation(String location) {
    final parts = location.split(',');
    if (parts.length > 1) return parts.last.trim();
    return location.trim();
  }
}
