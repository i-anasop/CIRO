import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/news_signal.dart';
import '../models/social_post_signal.dart';
import 'app_config.dart';

class SocialSignalService {
  SocialSignalService._();
  static final SocialSignalService instance = SocialSignalService._();

  static const _officialHandles = <_OfficialHandle>[
    _OfficialHandle(
      author: 'NDMA Pakistan',
      handle: '@ndmapk',
      topics: ['flood', 'rain', 'heat', 'emergency', 'disaster', 'weather'],
    ),
    _OfficialHandle(
      author: 'Chief Commissioner Islamabad',
      handle: '@ccislamabad',
      topics: ['islamabad', 'emergency', 'public', 'administration'],
    ),
    _OfficialHandle(
      author: 'Islamabad Police',
      handle: '@ICT_Police',
      topics: ['accident', 'traffic', 'blocked', 'road', 'public'],
    ),
    _OfficialHandle(
      author: 'Islamabad Traffic Police',
      handle: '@ITP_Police',
      topics: ['traffic', 'congestion', 'route', 'road', 'accident'],
    ),
    _OfficialHandle(
      author: 'National Highways & Motorway Police',
      handle: '@NHMPofficial',
      topics: ['traffic', 'highway', 'accident', 'route', 'fog'],
    ),
  ];

  static const _keywords = [
    'flood',
    'flooding',
    'rain',
    'accident',
    'traffic',
    'blocked',
    'heatwave',
    'heat',
    'outage',
    'blackout',
    'fire',
    'emergency',
  ];

  Future<List<SocialPostSignal>> fetchRelevantPosts({
    required String city,
    required List<NewsSignal> fallbackNews,
  }) async {
    final livePosts = await _fetchFromX(city);
    if (livePosts.isNotEmpty) return livePosts;
    return _fallbackFromPublicSignals(city: city, newsSignals: fallbackNews);
  }

  Future<List<SocialPostSignal>> _fetchFromX(String city) async {
    if (!AppConfig.instance.hasXBearerToken) return const [];

    final fromQuery = _officialHandles
        .map((item) => 'from:${item.handle.substring(1)}')
        .join(' OR ');
    final keywordQuery = _keywords.map((kw) => '"$kw"').join(' OR ');
    final query = Uri.encodeComponent(
      '($fromQuery) ($keywordQuery) "$city" -is:retweet',
    );
    final uri = Uri.parse(
      'https://api.x.com/2/tweets/search/recent'
      '?query=$query'
      '&max_results=10'
      '&tweet.fields=created_at,author_id'
      '&expansions=author_id'
      '&user.fields=name,username',
    );

    try {
      final response = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer ${AppConfig.instance.xBearerToken}',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return const [];
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final users = <String, Map<String, dynamic>>{};
      for (final user in (data['includes']?['users'] as List<dynamic>?) ?? []) {
        final map = user as Map<String, dynamic>;
        users[map['id'] as String] = map;
      }

      final posts = <SocialPostSignal>[];
      for (final item in (data['data'] as List<dynamic>?) ?? []) {
        final tweet = item as Map<String, dynamic>;
        final text = tweet['text'] as String? ?? '';
        final user = users[tweet['author_id'] as String? ?? ''];
        final username = user?['username'] as String? ?? 'public_source';
        final author = user?['name'] as String? ?? username;
        final keyword = _matchedKeyword(text);
        posts.add(
          SocialPostSignal(
            id: tweet['id'] as String? ?? DateTime.now().toString(),
            author: author,
            handle: '@$username',
            text: text,
            location: city,
            url: 'https://x.com/$username/status/${tweet['id']}',
            publishedAt: DateTime.tryParse(
              tweet['created_at'] as String? ?? '',
            ),
            matchedKeyword: keyword,
            confidence: keyword == 'emergency' ? 0.78 : 0.88,
          ),
        );
      }
      return posts.take(5).toList();
    } catch (e) {
      debugPrint('[SocialSignalService] X fetch failed: $e');
      return const [];
    }
  }

  List<SocialPostSignal> _fallbackFromPublicSignals({
    required String city,
    required List<NewsSignal> newsSignals,
  }) {
    if (newsSignals.isEmpty) return const [];

    return newsSignals.take(5).map((signal) {
      final handle = _handleFor(signal.matchedKeyword);
      final text = signal.description.isNotEmpty
          ? signal.description
          : signal.title;
      return SocialPostSignal(
        id: 'public-${signal.url.hashCode.abs()}',
        author: handle.author,
        handle: handle.handle,
        text: text,
        location: city,
        url: signal.url,
        publishedAt: signal.publishedAt,
        matchedKeyword: signal.matchedKeyword,
        confidence: signal.confidenceHint,
      );
    }).toList();
  }

  _OfficialHandle _handleFor(String keyword) {
    final normalized = keyword.toLowerCase();
    for (final item in _officialHandles) {
      if (item.topics.any(normalized.contains)) return item;
    }
    return _officialHandles.first;
  }

  String _matchedKeyword(String text) {
    final lower = text.toLowerCase();
    return _keywords.firstWhere(lower.contains, orElse: () => 'emergency');
  }
}

class _OfficialHandle {
  final String author;
  final String handle;
  final List<String> topics;

  const _OfficialHandle({
    required this.author,
    required this.handle,
    required this.topics,
  });
}
