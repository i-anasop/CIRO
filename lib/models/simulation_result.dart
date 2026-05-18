// CIRO — SimulationResult Data Model
// Captures the before/after metric comparison produced by the Simulation Agent.

class MetricSnapshot {
  final String label;
  final String before;
  final String after;
  final String delta;        // e.g. "▼ 36%" or "▲ 6 units"
  final bool isImprovement;  // True if the change is positive for the crisis

  const MetricSnapshot({
    required this.label,
    required this.before,
    required this.after,
    required this.delta,
    required this.isImprovement,
  });
}

class SimulatedAction {
  final String id;
  final String title;
  final String description;
  final String status;  // e.g. "Completed", "In Progress", "Scheduled"
  final String? resultSummary;

  const SimulatedAction({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.resultSummary,
  });
}

class SimulationResult {
  final String crisisId;
  final List<SimulatedAction> actions;
  final List<MetricSnapshot> metrics;
  final DateTime simulatedAt;

  const SimulationResult({
    required this.crisisId,
    required this.actions,
    required this.metrics,
    required this.simulatedAt,
  });
}
