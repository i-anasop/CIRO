// CIRO — Crisis Data Model
// Defines the typed Crisis entity. All crisis data across the app must conform
// to this schema. Mock and future real-API data must both produce this shape.

/// Severity levels as defined in AGENTS.md §8.
enum SeverityLevel { critical, high, moderate, low, unknown }

/// Active state of a crisis in the system.
enum CrisisStatus { active, monitoring, resolved, needsVerification }

/// Supported crisis types per AGENTS.md §4.
enum CrisisType { urbanFlooding, roadBlockage, accident, heatwave, powerOutage }

class Crisis {
  final String id;
  final CrisisType type;
  final String title;
  final String location;
  final String coordinates; // "lat,lng" string for map display
  final SeverityLevel severity;
  final CrisisStatus status;
  final double confidencePercent; // 0–100
  final int affectedPeople;
  final DateTime detectedAt;
  final String? estimatedDuration; // e.g. "4–6 hours"
  final List<String> signalSummaries; // short descriptions of input signals
  final String detectionReasoning;   // narrative from Detection Agent
  final String verificationState;    // from Verification Agent

  const Crisis({
    required this.id,
    required this.type,
    required this.title,
    required this.location,
    required this.coordinates,
    required this.severity,
    required this.status,
    required this.confidencePercent,
    required this.affectedPeople,
    required this.detectedAt,
    this.estimatedDuration,
    required this.signalSummaries,
    required this.detectionReasoning,
    required this.verificationState,
  });

  /// Human-readable label for the crisis type.
  String get typeLabel {
    switch (type) {
      case CrisisType.urbanFlooding: return 'Urban Flooding';
      case CrisisType.roadBlockage:  return 'Road Blockage';
      case CrisisType.accident:      return 'Accident';
      case CrisisType.heatwave:      return 'Heatwave';
      case CrisisType.powerOutage:   return 'Power Outage';
    }
  }

  /// Human-readable label for the severity level.
  String get severityLabel {
    switch (severity) {
      case SeverityLevel.critical: return 'Critical';
      case SeverityLevel.high:     return 'High';
      case SeverityLevel.moderate: return 'Moderate';
      case SeverityLevel.low:      return 'Low';
      case SeverityLevel.unknown:  return 'Unknown';
    }
  }

  /// Human-readable label for the crisis status.
  String get statusLabel {
    switch (status) {
      case CrisisStatus.active:             return 'Active';
      case CrisisStatus.monitoring:         return 'Monitoring';
      case CrisisStatus.resolved:           return 'Resolved';
      case CrisisStatus.needsVerification:  return 'Needs Verification';
    }
  }

  /// Icon identifier string for the crisis type (Material icon name equivalent).
  String get typeIcon {
    switch (type) {
      case CrisisType.urbanFlooding: return 'water';
      case CrisisType.roadBlockage:  return 'traffic';
      case CrisisType.accident:      return 'car_crash';
      case CrisisType.heatwave:      return 'thermostat';
      case CrisisType.powerOutage:   return 'power_off';
    }
  }

  /// Integer confidence shortcut (rounds confidencePercent).
  int get confidence => confidencePercent.round();

  /// Human-readable time string from detectedAt DateTime.
  String get detectedAtLabel {
    final h = detectedAt.hour.toString().padLeft(2, '0');
    final m = detectedAt.minute.toString().padLeft(2, '0');
    return '$h:$m PKT';
  }
}
