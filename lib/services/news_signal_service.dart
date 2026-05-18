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

    final keyword = _crisisKeywords.take(5).join(' OR ');
    final query   = Uri.encodeComponent('($keyword) "$location"');

    try {
      final uri = Uri.parse(
        '$_baseUrl?q=$query'
        '&language=en'
        '&sortBy=publishedAt'
        '&pageSize=10'
        '&apiKey=${AppConfig.instance.newsApiKey}',
      );
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return [];

      final data    = jsonDecode(resp.body) as Map<String, dynamic>;
      final articles = (data['articles'] as List<dynamic>?) ?? [];

      final signals = <NewsSignal>[];
      for (final article in articles) {
        final signal = _toSignal(article as Map<String, dynamic>);
        if (signal != null) signals.add(signal);
        if (signals.length >= 5) break;
      }
      return signals;
    } catch (_) {
      return [];
    }
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
}
