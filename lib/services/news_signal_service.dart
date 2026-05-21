// CIRO — News Signal Service
// Fetches crisis-relevant news using NewsAPI /everything endpoint.
// Searches for crisis keywords near the given location string.
// Returns max 5 NewsSignal items — never crashes on missing key.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_signal.dart';
import 'app_config.dart';

class NewsSignalService {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final NewsSignalService instance = NewsSignalService._();
  NewsSignalService._();

  static const _baseUrl = 'https://newsapi.org/v2/everything';

  /// Crisis keywords to search for.
  static const _crisisKeywords = [
    'flood', 'flooding', 'heavy rain',
    'accident', 'road blocked', 'traffic jam',
    'heatwave', 'heat wave',
    'power outage', 'blackout',
    'fire', 'emergency',
  ];

  /// Fetch news signals for a location string (city/area name).
  /// Returns empty list with no crash if key is missing.
  Future<List<NewsSignal>> fetchSignals(String location) async {
    if (!AppConfig.instance.hasNewsApiKey) {
      return [];
    }

    final signals = <NewsSignal>[];
    final seen = <String>{};
    for (final queryText in _queryVariants(location)) {
      final fetched = await _fetchQuery(queryText);
      for (final signal in fetched) {
        final key = _dedupeKey(signal);
        if (seen.add(key)) {
          signals.add(signal);
        }
        if (signals.length >= 12) return signals;
      }
    }
    return signals;
  }

  Future<List<NewsSignal>> _fetchQuery(String queryText) async {
    final query = Uri.encodeComponent(queryText);

    try {
      final uri = Uri.parse(
        '$_baseUrl?q=$query'
        '&language=en'
        '&sortBy=publishedAt'
        '&pageSize=12'
        '&apiKey=${AppConfig.instance.newsApiKey}',
      );
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return [];

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final articles = (data['articles'] as List<dynamic>?) ?? [];

      return articles
          .whereType<Map<String, dynamic>>()
          .map(_toSignal)
          .whereType<NewsSignal>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<String> _queryVariants(String location) {
    final compact = location.trim().replaceAll(RegExp(r'\s+'), ' ');
    final parts = compact
        .split(RegExp(r'[,،]|\s+'))
        .map((part) => part.trim())
        .where((part) => part.length > 2)
        .toList();
    final city = parts.isNotEmpty ? parts.last : compact;
    final area = parts.length > 1 ? parts.first : city;
    final crisis = _crisisKeywords.join(' OR ');

    return [
      '($crisis) AND "$compact"',
      '($crisis) AND "$city"',
      '($crisis) AND Pakistan',
      'emergency OR disaster OR flood OR accident OR heatwave OR outage Pakistan',
      '"$area" OR "$city" emergency',
    ].where((item) => item.trim().isNotEmpty).toList();
  }

  NewsSignal? _toSignal(Map<String, dynamic> a) {
    final title       = a['title']       as String? ?? '';
    final description = a['description'] as String? ?? '';
    final url         = a['url']         as String? ?? '';
    final publishedAt = a['publishedAt'] as String?;
    final sourceName  = (a['source'] as Map<String, dynamic>?)?['name']
        as String? ?? 'Unknown';

    if (title.isEmpty || title == '[Removed]') return null;

    // Determine matched keyword for confidence hint
    final combined = '${title.toLowerCase()} ${description.toLowerCase()}';
    String matched = 'emergency';
    double confidence = 0.5;
    for (final kw in _crisisKeywords) {
      if (combined.contains(kw)) {
        matched     = kw;
        confidence  = kw.contains('flood') || kw.contains('rain')
            ? 0.85 : 0.70;
        break;
      }
    }

    DateTime? published;
    if (publishedAt != null) {
      published = DateTime.tryParse(publishedAt);
    }

    return NewsSignal(
      title:           _truncate(title, 90),
      description:     _truncate(description, 140),
      source:          sourceName,
      url:             url,
      publishedAt:     published,
      matchedKeyword:  matched,
      confidenceHint:  confidence,
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
