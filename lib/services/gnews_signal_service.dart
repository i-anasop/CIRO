// CIRO — GNews Signal Service
// Fetches crisis-relevant news using GNews API (completely free, 100 calls/day).
// Also includes RSS fallback from ReliefWeb (UN disaster feed, unlimited & free).
// Returns max 5 NewsSignal items — never crashes on missing key.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/news_signal.dart';
import 'app_config.dart';

class GnewsSignalService {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final GnewsSignalService instance = GnewsSignalService._();
  GnewsSignalService._();

  static const _gnewsBase = 'https://gnews.io/api/v4/search';
  static const _reliefWebBase = 'https://api.reliefweb.int/v1/reports';

  static const _crisisKeywords = [
    'flood', 'heavy rain', 'accident', 'heatwave',
    'power outage', 'road blocked', 'emergency', 'disaster',
  ];

  // ── GNews (Free, 100 req/day, no paid plan needed) ───────────────────────

  /// Fetch news using GNews API. Falls back to ReliefWeb if GNews key missing.
  Future<List<NewsSignal>> fetchSignals(String location) async {
    final results = <NewsSignal>[];
    final seen = <String>{};

    if (AppConfig.instance.hasGnewsKey) {
      for (final signal in await _fetchFromGnews(location)) {
        if (seen.add(_dedupeKey(signal))) results.add(signal);
      }
    }

    // Also pull from ReliefWeb RSS (always free, UN source — great for hackathon)
    if (!kIsWeb) {
      for (final signal in await _fetchFromReliefWeb(location)) {
        if (seen.add(_dedupeKey(signal))) results.add(signal);
        if (results.length >= 12) break;
      }
    }

    return results;
  }

  Future<List<NewsSignal>> _fetchFromGnews(String location) async {
    final queries = _queryVariants(location);
    final signals = <NewsSignal>[];
    final seen = <String>{};

    for (final q in queries) {
      final fetched = await _fetchGnewsQuery(q);
      for (final signal in fetched) {
        final key = signal.title.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
        if (seen.add(key)) signals.add(signal);
        if (signals.length >= 8) return signals;
      }
    }

    return signals;
  }

  Future<List<NewsSignal>> _fetchGnewsQuery(String queryText) async {
    final query = Uri.encodeComponent(queryText);
    try {
      final uri = Uri.parse(
        '$_gnewsBase?q=$query'
        '&lang=en'
        '&max=6'
        '&sortby=publishedAt'
        '&apikey=${AppConfig.instance.gnewsApiKey}',
      );
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return [];

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final articles = (data['articles'] as List<dynamic>?) ?? [];

      final signals = <NewsSignal>[];
      for (final a in articles) {
        final sig = _gnewsToSignal(a as Map<String, dynamic>);
        if (sig != null) signals.add(sig);
        if (signals.length >= 5) break;
      }
      return signals;
    } catch (e) {
      debugPrint('[GnewsSignalService] GNews error: $e');
      return [];
    }
  }

  List<String> _queryVariants(String location) {
    final compact = location.trim().replaceAll(RegExp(r'\s+'), ' ');
    String? city;
    final parts = compact
        .split(RegExp(r'[,،]|\s+'))
        .where((part) => part.trim().length > 2)
        .toList();
    if (parts.isNotEmpty) city = parts.last;
    final cityQuery = city == null ? compact : city;

    return [
      '$compact flood OR rain OR accident OR traffic OR heatwave OR outage',
      '$cityQuery emergency OR disaster OR traffic OR accident',
      'Pakistan flood OR rain OR accident OR heatwave OR power outage',
      'Pakistan emergency disaster traffic',
    ].where((item) => item.trim().isNotEmpty).toList();
  }

  Future<List<NewsSignal>> _fetchFromReliefWeb(String location) async {
    // ReliefWeb — UN OCHA public API, completely free and unlimited
    try {
      final city = location.split(',').first.trim();
      final body = jsonEncode({
        'query': {
          'value': city,
          'fields': ['title', 'body'],
          'operator': 'AND',
        },
        'sort': ['date.created:desc'],
        'limit': 5,
        'fields': {
          'include': ['title', 'date.created', 'url', 'source.name', 'body-html'],
        },
      });

      final resp = await http
          .post(
            Uri.parse(_reliefWebBase),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode != 200) return [];

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final items = (data['data'] as List<dynamic>?) ?? [];

      final signals = <NewsSignal>[];
      for (final item in items) {
        final f = item['fields'] as Map<String, dynamic>? ?? {};
        final title = f['title'] as String? ?? '';
        final url = (f['url'] as String?) ?? '';
        final source = (f['source'] as List?)?.firstOrNull?['name'] as String? ?? 'ReliefWeb/UN';
        final dateStr = (f['date'] as Map?)?['created'] as String?;
        final DateTime? published = dateStr != null ? DateTime.tryParse(dateStr) : null;

        if (title.isEmpty) continue;

        String matched = 'emergency';
        double conf = 0.65;
        final lower = title.toLowerCase();
        for (final kw in _crisisKeywords) {
          if (lower.contains(kw)) {
            matched = kw;
            conf = 0.78;
            break;
          }
        }

        signals.add(NewsSignal(
          title: _truncate(title, 90),
          description: 'Source: ReliefWeb (UN OCHA) — $city region crisis report.',
          source: source,
          url: url,
          publishedAt: published,
          matchedKeyword: matched,
          confidenceHint: conf,
        ));
        if (signals.length >= 5) break;
      }
      return signals;
    } catch (e) {
      if (!kIsWeb) {
        debugPrint('[GnewsSignalService] ReliefWeb error: $e');
      }
      return [];
    }
  }

  NewsSignal? _gnewsToSignal(Map<String, dynamic> a) {
    final title = a['title'] as String? ?? '';
    final description = a['description'] as String? ?? '';
    final url = a['url'] as String? ?? '';
    final publishedAt = a['publishedAt'] as String?;
    final sourceName = (a['source'] as Map<String, dynamic>?)?['name'] as String? ?? 'GNews';

    if (title.isEmpty || title == '[Removed]') return null;

    final combined = '${title.toLowerCase()} ${description.toLowerCase()}';
    String matched = 'emergency';
    double confidence = 0.55;
    for (final kw in _crisisKeywords) {
      if (combined.contains(kw)) {
        matched = kw;
        confidence = kw.contains('flood') || kw.contains('rain') ? 0.88 : 0.72;
        break;
      }
    }

    return NewsSignal(
      title: _truncate(title, 90),
      description: _truncate(description, 140),
      source: sourceName,
      url: url,
      publishedAt: publishedAt != null ? DateTime.tryParse(publishedAt) : null,
      matchedKeyword: matched,
      confidenceHint: confidence,
    );
  }

  String _truncate(String s, int max) =>
      s.length > max ? '${s.substring(0, max)}…' : s;

  String _dedupeKey(NewsSignal signal) {
    final source = signal.source.toLowerCase().trim();
    final normalizedTitle = signal.title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final end = normalizedTitle.length > 72 ? 72 : normalizedTitle.length;
    return '$source-${normalizedTitle.substring(0, end)}';
  }
}
