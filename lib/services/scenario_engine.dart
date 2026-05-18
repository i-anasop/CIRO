// CIRO — Scenario Engine Service
// Central state manager for the active demo scenario.
// Uses ChangeNotifier for reactive UI updates (no external packages needed).
//
// Usage:
//   ScenarioEngine.instance.selectScenario('SCN-001');
//   ListenableBuilder(listenable: ScenarioEngine.instance, builder: ...)

import 'package:flutter/foundation.dart';
import '../data/mock_scenarios.dart';
import '../models/demo_scenario.dart';
import '../models/pipeline_result.dart';
import '../models/crisis.dart';
import '../models/agent_log.dart';
import '../models/simulation_result.dart';
import '../agents/agent_pipeline.dart';

class ScenarioEngine extends ChangeNotifier {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final ScenarioEngine instance = ScenarioEngine._();
  ScenarioEngine._();

  // ── State ─────────────────────────────────────────────────────────────────
  late PipelineResult _currentResult;
  String _activeScenarioId = 'SCN-001';
  bool _isRunning = false;

  // ── Init ──────────────────────────────────────────────────────────────────
  void initialize() {
    _currentResult = _runPipeline(scenarioById('SCN-001'));
  }

  // ── Public getters ────────────────────────────────────────────────────────
  PipelineResult get currentResult => _currentResult;
  DemoScenario   get activeScenario => _currentResult.scenario;
  Crisis         get activeCrisis   => _currentResult.crisis;
  String         get activeScenarioId => _activeScenarioId;
  bool           get isRunning      => _isRunning;

  List<PlanAction>      get responsePlan => _currentResult.responsePlan;
  SimulationResult      get simulation   => _currentResult.simulation;
  List<AgentLog>        get agentLogs    => _currentResult.agentLogs;
  ResourceAllocation    get resources    => _currentResult.resources;
  VerificationDecision  get verification => _currentResult.verification;
  List<String>          get fusionPoints => _currentResult.fusionPoints;

  List<DemoScenario> get allScenarios => mockDemoScenarios;

  // ── Scenario selection ────────────────────────────────────────────────────
  Future<void> selectScenario(String id) async {
    if (_activeScenarioId == id && !_isRunning) return;
    _isRunning = true;
    notifyListeners();

    // Simulate brief pipeline execution delay for demo feel
    await Future.delayed(const Duration(milliseconds: 800));

    _activeScenarioId = id;
    _currentResult    = _runPipeline(scenarioById(id));
    _isRunning        = false;
    notifyListeners();
  }

  void reset() {
    selectScenario('SCN-001');
  }

  // ── Pipeline orchestration ────────────────────────────────────────────────
  PipelineResult _runPipeline(DemoScenario scenario) {
    // Run all 9 agents in sequence
    final crisis       = runDetectionAgent(scenario);
    final fusionPts    = runFusionAgent(scenario);
    final resources    = runResourceAgent(scenario);
    final plan         = runResponsePlannerAgent(scenario);
    final simulation   = runSimulationAgent(scenario);
    final verification = runVerificationAgent(scenario);
    final logs         = runLogAgent(scenario, crisis);

    return PipelineResult(
      scenario:     scenario,
      crisis:       crisis,
      fusionPoints: fusionPts,
      resources:    resources,
      responsePlan: plan,
      simulation:   simulation,
      verification: verification,
      agentLogs:    logs,
      generatedAt:  DateTime.now(),
    );
  }

  void overrideLocation(String newLocation, {double? lat, double? lng}) {
    final oldCrisis = _currentResult.crisis;
    final updatedCrisis = Crisis(
      id: oldCrisis.id,
      type: oldCrisis.type,
      title: oldCrisis.title,
      location: newLocation,
      coordinates: lat != null && lng != null ? '$lat,$lng' : oldCrisis.coordinates,
      severity: oldCrisis.severity,
      status: oldCrisis.status,
      confidencePercent: oldCrisis.confidencePercent,
      affectedPeople: oldCrisis.affectedPeople,
      detectedAt: oldCrisis.detectedAt,
      estimatedDuration: oldCrisis.estimatedDuration,
      signalSummaries: oldCrisis.signalSummaries,
      detectionReasoning: oldCrisis.detectionReasoning.replaceAll('G-10 Markaz', newLocation).replaceAll('G-10', newLocation),
      verificationState: oldCrisis.verificationState,
    );

    final oldScenario = _currentResult.scenario;
    final updatedScenario = DemoScenario(
      id: oldScenario.id,
      title: oldScenario.title,
      crisisType: oldScenario.crisisType,
      location: newLocation,
      coordinates: lat != null && lng != null ? '$lat,$lng' : oldScenario.coordinates,
      severity: oldScenario.severity,
      confidence: oldScenario.confidence,
      status: oldScenario.status,
      affectedPopulation: oldScenario.affectedPopulation,
      expectedDuration: oldScenario.expectedDuration,
      likelyEvolution: oldScenario.likelyEvolution,
      socialSignal: oldScenario.socialSignal,
      weatherSignal: oldScenario.weatherSignal,
      trafficSignal: oldScenario.trafficSignal,
      extraSignals: oldScenario.extraSignals,
      responseActions: oldScenario.responseActions.map((action) => PlanAction(
        step: action.step,
        title: action.title.replaceAll('G-10', newLocation),
        description: action.description.replaceAll('G-10', newLocation),
        department: action.department,
        priority: action.priority,
        eta: action.eta,
        status: action.status,
        resultSummary: action.resultSummary,
      )).toList(),
      simulationMetrics: oldScenario.simulationMetrics,
      possibleSideEffects: oldScenario.possibleSideEffects,
      verificationType: oldScenario.verificationType,
      verificationNote: oldScenario.verificationNote,
      mapZoneLabel: newLocation,
      resourceSummary: oldScenario.resourceSummary,
      resourceUnits: oldScenario.resourceUnits,
    );

    _currentResult = PipelineResult(
      scenario:     updatedScenario,
      crisis:       updatedCrisis,
      fusionPoints: _currentResult.fusionPoints,
      resources:    _currentResult.resources,
      responsePlan: updatedScenario.responseActions,
      simulation:   _currentResult.simulation,
      verification: _currentResult.verification,
      agentLogs:    _currentResult.agentLogs.map((log) => AgentLog(
        id: log.id,
        agent: log.agent,
        summary: log.summary.replaceAll('G-10 Markaz', newLocation).replaceAll('G-10', newLocation),
        detail: log.detail.replaceAll('G-10 Markaz', newLocation).replaceAll('G-10', newLocation),
        level: log.level,
        timestamp: log.timestamp,
        output: log.output,
      )).toList(),
      generatedAt:  _currentResult.generatedAt,
    );
    notifyListeners();
  }
}
