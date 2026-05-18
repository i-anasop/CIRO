// CIRO — Multi-Agent Pipeline
// Lightweight stateless agent functions per AGENTS.md §6.
// Each agent takes a DemoScenario and returns its typed output.
// Agents produce concise human-readable reasoning — no raw chain-of-thought.
//
// Pipeline flow:
//   Signal → Fusion → Detection → Severity → Resource
//   → ResponsePlanner → Simulation → Verification → Log

import '../models/demo_scenario.dart';
import '../models/crisis.dart';
import '../models/signal.dart';
import '../models/agent_log.dart';
import '../models/simulation_result.dart';
import '../models/pipeline_result.dart';

// ── 1. Signal Agent ───────────────────────────────────────────────────────
// Normalizes raw scenario signals into the standard schema.
List<String> runSignalAgent(DemoScenario s) {
  return s.activeSignals.map((sig) {
    final src = _sourceLabel(sig.source);
    final conf = (sig.confidence * 100).toInt();
    return '[$src] ${sig.content} (conf. $conf%)';
  }).toList();
}

// ── 2. Fusion Agent ───────────────────────────────────────────────────────
// Combines signals, removes noise, builds unified event picture.
List<String> runFusionAgent(DemoScenario s) {
  final count = s.activeSignals.length;
  final sources = s.activeSignals.map((e) => _sourceLabel(e.source)).join(', ');
  final avgConf = count == 0 ? 0
      : (s.activeSignals.map((e) => e.confidence).reduce((a, b) => a + b) /
              count *
              100)
          .toInt();

  return [
    '$count active signal source${count == 1 ? "" : "s"} collected: $sources.',
    'Average signal confidence: $avgConf%. '
        '${avgConf >= 80 ? "Threshold exceeded — proceeding to detection." : "Below threshold — flagging for verification."}',
    'Signals corroborate activity near ${s.location}. '
        '${count >= 2 ? "Cross-source agreement detected." : "Single source — low corroboration."}',
    if (s.verificationType == VerificationType.conflictingSignals)
      '⚡ Conflict detected: sources do not fully agree on crisis nature.',
    if (s.verificationType == VerificationType.needsVerification)
      '⚠️ Insufficient multi-source evidence — human review recommended.',
  ];
}

// ── 3. Detection Agent ────────────────────────────────────────────────────
// Classifies crisis type and extracts location.
Crisis runDetectionAgent(DemoScenario s) {
  return Crisis(
    id: 'CRS-${s.id}',
    type: s.crisisType,
    title: s.title,
    location: s.location,
    coordinates: s.coordinates,
    severity: s.severity,
    status: s.status,
    confidencePercent: s.confidence,
    affectedPeople: s.affectedPopulation,
    detectedAt: DateTime.now(),
    estimatedDuration: s.expectedDuration,
    signalSummaries: s.activeSignals.map((sig) => sig.content).toList(),
    detectionReasoning:
        'Detection Agent classified this event as ${_crisisLabel(s.crisisType)} '
        'based on ${s.activeSignals.length} corroborating signal source(s). '
        'Location extracted: ${s.location}. '
        '${_detectionNote(s)}',
    verificationState: s.verificationLabel,
  );
}

// ── 4. Severity Agent ─────────────────────────────────────────────────────
// Estimates severity, confidence, affected population, duration, evolution.
String runSeverityAgent(DemoScenario s) {
  return 'Severity classified as ${_severityLabel(s.severity)} '
      'with ${s.confidence.toInt()}% confidence. '
      'Estimated ${s.affectedPopulation.toStringAsFixed(0)} people affected. '
      'Expected duration: ${s.expectedDuration}. '
      'Evolution: ${s.likelyEvolution}';
}

// ── 5. Resource Agent ─────────────────────────────────────────────────────
// Evaluates available resources and prioritizes across active crises.
ResourceAllocation runResourceAgent(DemoScenario s) {
  return ResourceAllocation(
    units: s.resourceUnits,
    unitCount: s.resourceUnits.length,
    summary: s.resourceSummary,
  );
}

// ── 6. Response Planner Agent ─────────────────────────────────────────────
// Generates the coordinated, step-by-step action plan.
List<PlanAction> runResponsePlannerAgent(DemoScenario s) => s.responseActions;

// ── 7. Simulation Agent ───────────────────────────────────────────────────
// Simulates action execution and produces before/after metrics.
SimulationResult runSimulationAgent(DemoScenario s) {
  final actions = s.responseActions.map((a) => SimulatedAction(
        id: 'SIM-${a.step}',
        title: a.title,
        description: a.description,
        status: a.status,
        resultSummary: a.resultSummary,
      )).toList();

  final metrics = s.simulationMetrics.map((m) => MetricSnapshot(
        label:         m.label,
        before:        m.before,
        after:         m.after,
        delta:         m.delta,
        isImprovement: m.isImprovement,
      )).toList();

  return SimulationResult(
    crisisId:    'CRS-${s.id}',
    actions:     actions,
    metrics:     metrics,
    simulatedAt: DateTime.now(),
  );
}

// ── 8. Verification Agent ─────────────────────────────────────────────────
// Determines signal validity and flags false positives / conflicts.
VerificationDecision runVerificationAgent(DemoScenario s) {
  return VerificationDecision(
    type:  s.verificationType,
    label: s.verificationLabel,
    note:  s.verificationNote,
  );
}

// ── 9. Log Agent ──────────────────────────────────────────────────────────
// Records every agent decision in a timestamped audit trail.
List<AgentLog> runLogAgent(DemoScenario s, Crisis crisis) {
  final base = DateTime.now();
  return [
    AgentLog(
      id: 'LOG-01',
      agent: AgentType.signalAgent,
      summary: '${s.activeSignals.length} signals collected and normalized',
      detail: 'Signal Agent collected ${s.activeSignals.length} active signal(s) '
          'from: ${s.activeSignals.map((e) => _sourceLabel(e.source)).join(", ")}. '
          'All signals normalized to standard schema.',
      level: LogLevel.success,
      timestamp: base.subtract(const Duration(seconds: 100)),
      output: {'signal_count': s.activeSignals.length},
    ),
    AgentLog(
      id: 'LOG-02',
      agent: AgentType.fusionAgent,
      summary: 'Signals fused — ${s.activeSignals.length >= 2 ? "corroboration detected" : "single source flagged"}',
      detail: 'Fusion Agent combined all signals. '
          '${s.activeSignals.length >= 2 ? "Cross-source overlap confirms activity near ${s.location}. Noise filtered." : "Single source detected. Corroboration insufficient. Flagged for verification."}',
      level: s.activeSignals.length >= 2 ? LogLevel.success : LogLevel.warning,
      timestamp: base.subtract(const Duration(seconds: 88)),
      output: {'sources_fused': s.activeSignals.length},
    ),
    AgentLog(
      id: 'LOG-03',
      agent: AgentType.detectionAgent,
      summary: '${_crisisLabel(s.crisisType)} detected at ${s.location}',
      detail: 'Detection Agent classified crisis type as ${_crisisLabel(s.crisisType)}. '
          'Location confirmed: ${s.location}. '
          'Coordinates: ${s.coordinates}.',
      level: LogLevel.success,
      timestamp: base.subtract(const Duration(seconds: 75)),
      output: {'type': _crisisLabel(s.crisisType), 'location': s.location},
    ),
    AgentLog(
      id: 'LOG-04',
      agent: AgentType.severityAgent,
      summary: '${_severityLabel(s.severity)} severity · ${s.confidence.toInt()}% confidence',
      detail: 'Severity Agent computed: ${_severityLabel(s.severity)} severity '
          'with ${s.confidence.toInt()}% confidence. '
          'Est. affected: ${s.affectedPopulation} people. '
          'Duration: ${s.expectedDuration}.',
      level: s.severity == SeverityLevel.critical ? LogLevel.error
          : s.severity == SeverityLevel.high ? LogLevel.warning
          : LogLevel.info,
      timestamp: base.subtract(const Duration(seconds: 62)),
      output: {
        'severity': _severityLabel(s.severity),
        'confidence': '${s.confidence.toInt()}%',
        'affected': s.affectedPopulation,
      },
    ),
    AgentLog(
      id: 'LOG-05',
      agent: AgentType.resourceAgent,
      summary: '${s.resourceUnits.length} units prioritized',
      detail: 'Resource Agent evaluated available inventory and prioritized: '
          '${s.resourceSummary}.',
      level: LogLevel.info,
      timestamp: base.subtract(const Duration(seconds: 50)),
      output: {'unit_count': s.resourceUnits.length},
    ),
    AgentLog(
      id: 'LOG-06',
      agent: AgentType.responsePlannerAgent,
      summary: '${s.responseActions.length}-step response plan generated',
      detail: 'Response Planner Agent created ${s.responseActions.length} coordinated '
          'actions with assigned departments and ETAs. '
          'Priority P1 actions: ${s.responseActions.where((a) => a.priority == "P1").length}.',
      level: LogLevel.success,
      timestamp: base.subtract(const Duration(seconds: 38)),
      output: {'action_count': s.responseActions.length},
    ),
    AgentLog(
      id: 'LOG-07',
      agent: AgentType.simulationAgent,
      summary: 'Simulation complete — outcomes projected',
      detail: 'Simulation Agent executed ${s.responseActions.length} actions. '
          '${s.simulationMetrics.length} before/after metrics computed. '
          'Primary improvement: ${s.simulationMetrics.isNotEmpty ? "${s.simulationMetrics.first.label}: ${s.simulationMetrics.first.before} → ${s.simulationMetrics.first.after}" : "N/A"}.',
      level: LogLevel.success,
      timestamp: base.subtract(const Duration(seconds: 25)),
      output: {'metric_count': s.simulationMetrics.length},
    ),
    AgentLog(
      id: 'LOG-08',
      agent: AgentType.verificationAgent,
      summary: s.verificationLabel,
      detail: s.verificationNote,
      level: s.verificationType == VerificationType.confirmed ? LogLevel.success
          : s.verificationType == VerificationType.needsVerification ? LogLevel.warning
          : s.verificationType == VerificationType.conflictingSignals ? LogLevel.warning
          : LogLevel.info,
      timestamp: base.subtract(const Duration(seconds: 12)),
      output: {'verification': s.verificationType.name},
    ),
    AgentLog(
      id: 'LOG-09',
      agent: AgentType.logAgent,
      summary: 'Full pipeline complete — audit trail recorded',
      detail: 'Log Agent compiled 9-step decision trace for crisis CRS-${s.id}. '
          'Pipeline duration: ~100 seconds. '
          'All decisions recorded and ready for human review.',
      level: LogLevel.success,
      timestamp: base,
      output: {'log_count': 9, 'crisis_id': 'CRS-${s.id}'},
    ),
  ];
}

// ── Helpers ───────────────────────────────────────────────────────────────
String _sourceLabel(SignalSource src) {
  switch (src) {
    case SignalSource.socialPost:    return 'Social Post';
    case SignalSource.weatherAlert:  return 'Weather Alert';
    case SignalSource.trafficData:   return 'Traffic Data';
    case SignalSource.mockSensor:    return 'IoT Sensor';
    case SignalSource.citizenReport: return 'Citizen Report';
    case SignalSource.fieldReport:   return 'Field Report';
    case SignalSource.emergencyCall: return 'Emergency Call';
  }
}

String _crisisLabel(CrisisType t) {
  switch (t) {
    case CrisisType.urbanFlooding: return 'Urban Flooding';
    case CrisisType.roadBlockage:  return 'Road Blockage';
    case CrisisType.accident:      return 'Accident';
    case CrisisType.heatwave:      return 'Heatwave';
    case CrisisType.powerOutage:   return 'Power Outage';
  }
}

String _severityLabel(SeverityLevel sl) {
  switch (sl) {
    case SeverityLevel.critical: return 'Critical';
    case SeverityLevel.high:     return 'High';
    case SeverityLevel.moderate: return 'Moderate';
    case SeverityLevel.low:      return 'Low';
    case SeverityLevel.unknown:  return 'Unknown';
  }
}

String _detectionNote(DemoScenario s) {
  switch (s.crisisType) {
    case CrisisType.urbanFlooding:
      return 'Flooding pattern identified from concurrent rainfall alert and traffic anomaly.';
    case CrisisType.accident:
      return 'Sudden congestion spike without weather cause — accident pattern confirmed.';
    case CrisisType.heatwave:
      return 'Extreme temperature sensor data and health-related social signals matched.';
    case CrisisType.powerOutage:
      return 'Zero-voltage sensor reading with social outage reports — infrastructure failure confirmed.';
    case CrisisType.roadBlockage:
      return 'High congestion without weather or accident signal — blockage pattern confirmed.';
  }
}
