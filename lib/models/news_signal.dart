// CIRO — NewsSignal Model
// Typed result from NewsAPI via NewsSignalService.
// Each item represents one news article matched to a crisis keyword.

class NewsSignal {
  final String title;
  final String description;
  final String source;
  final String url;
  final DateTime? publishedAt;
  final String matchedKeyword;
  final double confidenceHint; // 0.0–1.0, estimated from keyword relevance

  const NewsSignal({
    required this.title,
    required this.description,
    required this.source,
    required this.url,
    this.publishedAt,
    required this.matchedKeyword,
    required this.confidenceHint,
  });

  /// Short summary for signal chip display.
  String get shortSummary =>
      description.isNotEmpty ? description : title;

  /// Age in human-readable form.
  String get ageLabel {
    if (publishedAt == null) return 'Unknown time';
    final diff = DateTime.now().difference(publishedAt!);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
