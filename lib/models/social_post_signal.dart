class SocialPostSignal {
  final String id;
  final String author;
  final String handle;
  final String text;
  final String location;
  final String url;
  final DateTime? publishedAt;
  final String matchedKeyword;
  final double confidence;
  final bool verifiedSource;

  const SocialPostSignal({
    required this.id,
    required this.author,
    required this.handle,
    required this.text,
    required this.location,
    required this.url,
    this.publishedAt,
    required this.matchedKeyword,
    required this.confidence,
    this.verifiedSource = true,
  });

  String get ageLabel {
    if (publishedAt == null) return 'Live';
    final diff = DateTime.now().difference(publishedAt!);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
