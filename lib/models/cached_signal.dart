import 'crisis.dart';
import 'signal.dart';

enum SignalFreshness { live, cached, derived, fallback }

class CachedSignal {
  final String id;
  final SignalSource source;
  final String sourceName;
  final String city;
  final String area;
  final String title;
  final String content;
  final CrisisType? crisisTypeHint;
  final SeverityLevel severityHint;
  final double confidence;
  final DateTime timestamp;
  final DateTime expiresAt;
  final double? latitude;
  final double? longitude;
  final SignalFreshness freshness;
  final bool contributesToActiveCrisis;

  const CachedSignal({
    required this.id,
    required this.source,
    required this.sourceName,
    required this.city,
    required this.area,
    required this.title,
    required this.content,
    required this.crisisTypeHint,
    required this.severityHint,
    required this.confidence,
    required this.timestamp,
    required this.expiresAt,
    this.latitude,
    this.longitude,
    this.freshness = SignalFreshness.live,
    this.contributesToActiveCrisis = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  String get locationLabel {
    if (area.isNotEmpty && city.isNotEmpty) return '$area, $city';
    if (area.isNotEmpty) return area;
    return city;
  }

  String get ageLabel {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String get freshnessLabel {
    if (freshness == SignalFreshness.derived) return 'Derived';
    if (freshness == SignalFreshness.fallback) return 'Fallback';
    if (DateTime.now().difference(timestamp).inMinutes <= 2) return 'Live';
    return 'Cached ${ageLabel.replaceAll(' ago', '')}';
  }

  double get rankScore {
    final severityScore = switch (severityHint) {
      SeverityLevel.critical => 100.0,
      SeverityLevel.high => 78.0,
      SeverityLevel.moderate => 54.0,
      SeverityLevel.low => 24.0,
      SeverityLevel.unknown => 12.0,
    };
    final sourceScore = switch (source) {
      SignalSource.weatherAlert => 88.0,
      SignalSource.trafficData => 82.0,
      SignalSource.socialPost => 70.0,
      SignalSource.citizenReport => 66.0,
      SignalSource.emergencyCall => 86.0,
      SignalSource.mockSensor => 74.0,
      SignalSource.fieldReport => 78.0,
    };
    final minutes = DateTime.now().difference(timestamp).inMinutes;
    final recencyScore = (100 - minutes).clamp(0, 100).toDouble();
    final activeBoost = contributesToActiveCrisis ? 12.0 : 0.0;
    return (severityScore * 0.35) +
        ((confidence * 100) * 0.25) +
        (sourceScore * 0.20) +
        (recencyScore * 0.15) +
        activeBoost;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source.name,
        'sourceName': sourceName,
        'city': city,
        'area': area,
        'title': title,
        'content': content,
        'crisisTypeHint': crisisTypeHint?.name,
        'severityHint': severityHint.name,
        'confidence': confidence,
        'timestamp': timestamp.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'freshness': freshness.name,
        'contributesToActiveCrisis': contributesToActiveCrisis,
      };

  factory CachedSignal.fromJson(Map<String, dynamic> json) {
    return CachedSignal(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      source: _parseSource(json['source'] as String?),
      sourceName: json['sourceName'] as String? ?? 'Unknown source',
      city: json['city'] as String? ?? '',
      area: json['area'] as String? ?? '',
      title: json['title'] as String? ?? 'Signal',
      content: json['content'] as String? ?? '',
      crisisTypeHint: _parseCrisisType(json['crisisTypeHint'] as String?),
      severityHint: _parseSeverity(json['severityHint'] as String?),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
          DateTime.now().add(const Duration(hours: 2)),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      freshness: _parseFreshness(json['freshness'] as String?),
      contributesToActiveCrisis: json['contributesToActiveCrisis'] as bool? ?? false,
    );
  }

  static SignalSource _parseSource(String? value) {
    return SignalSource.values.firstWhere(
      (item) => item.name == value,
      orElse: () => SignalSource.socialPost,
    );
  }

  static CrisisType? _parseCrisisType(String? value) {
    if (value == null) return null;
    for (final item in CrisisType.values) {
      if (item.name == value) return item;
    }
    return null;
  }

  static SeverityLevel _parseSeverity(String? value) {
    return SeverityLevel.values.firstWhere(
      (item) => item.name == value,
      orElse: () => SeverityLevel.low,
    );
  }

  static SignalFreshness _parseFreshness(String? value) {
    return SignalFreshness.values.firstWhere(
      (item) => item.name == value,
      orElse: () => SignalFreshness.live,
    );
  }
}
