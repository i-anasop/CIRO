// CIRO — DemoScenario Model
// The structured input for the scenario engine. Each scenario pre-defines
// all signal inputs and expected pipeline outcomes for demo reproducibility.

import 'crisis.dart';
import 'signal.dart';

/// Verification states per AGENTS.md §11.
enum VerificationType {
  confirmed,          // ✅ High-confidence multi-source agreement
  needsVerification,  // ⚠️ Low-confidence or single-source
  conflictingSignals, // ⚡ Sources disagree
  falsePositiveRisk,  // 🔴 Likely false alarm
  escalationRequired, // 🔼 Under-rated crisis
}

/// A single raw signal input for a scenario.
class SignalInput {
  final SignalSource source;
  final String content;
  final double confidence; // 0.0–1.0
  final bool isActive;     // false = source is clear/normal for this scenario

  const SignalInput({
    required this.source,
    required this.content,
    required this.confidence,
    this.isActive = true,
  });
}

/// A single ordered response action (used in Response Plan screen).
class PlanAction {
  final int step;
  final String title;
  final String description;
  final String department;
  final String priority; // P1, P2, P3
  final String eta;
  final String status;   // Completed | In Progress | Pending
  final String? resultSummary;

  const PlanAction({
    required this.step,
    required this.title,
    required this.description,
    required this.department,
    required this.priority,
    required this.eta,
    required this.status,
    this.resultSummary,
  });
}

/// Before/after metric pair for Simulation screen.
class MetricPair {
  final String label;
  final String before;
  final String after;
  final String delta;
  final bool isImprovement;

  const MetricPair({
    required this.label,
    required this.before,
    required this.after,
    required this.delta,
    required this.isImprovement,
  });
}

/// Full pre-defined demo scenario.
class DemoScenario {
  final String id;
  final String title;
  final CrisisType crisisType;
  final String location;
  final String coordinates;
  final SeverityLevel severity;
  final double confidence;       // 0–100
  final CrisisStatus status;
  final int affectedPopulation;
  final String expectedDuration;
  final String likelyEvolution;
  final SignalInput socialSignal;
  final SignalInput weatherSignal;
  final SignalInput trafficSignal;
  final List<SignalInput> extraSignals;
  final List<PlanAction> responseActions;
  final List<MetricPair> simulationMetrics;
  final List<String> possibleSideEffects;
  final VerificationType verificationType;
  final String verificationNote;
  final String mapZoneLabel;
  final String resourceSummary;
  final List<String> resourceUnits;

  const DemoScenario({
    required this.id,
    required this.title,
    required this.crisisType,
    required this.location,
    required this.coordinates,
    required this.severity,
    required this.confidence,
    required this.status,
    required this.affectedPopulation,
    required this.expectedDuration,
    required this.likelyEvolution,
    required this.socialSignal,
    required this.weatherSignal,
    required this.trafficSignal,
    this.extraSignals = const [],
    required this.responseActions,
    required this.simulationMetrics,
    this.possibleSideEffects = const [],
    required this.verificationType,
    required this.verificationNote,
    required this.mapZoneLabel,
    required this.resourceSummary,
    this.resourceUnits = const [],
  });

  /// Returns only active signal inputs.
  List<SignalInput> get activeSignals => [
    if (socialSignal.isActive) socialSignal,
    if (weatherSignal.isActive) weatherSignal,
    if (trafficSignal.isActive) trafficSignal,
    ...extraSignals.where((s) => s.isActive),
  ];

  /// Human-readable verification label.
  String get verificationLabel {
    switch (verificationType) {
      case VerificationType.confirmed:          return '✅ Confirmed Crisis';
      case VerificationType.needsVerification:  return '⚠️ Needs Verification';
      case VerificationType.conflictingSignals: return '⚡ Conflicting Signals';
      case VerificationType.falsePositiveRisk:  return '🔴 False Positive Risk';
      case VerificationType.escalationRequired: return '🔼 Escalation Required';
    }
  }
}
