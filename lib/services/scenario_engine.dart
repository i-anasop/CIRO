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
import '../models/signal.dart';
import '../models/weather_result.dart';
import '../models/route_result.dart';
import '../models/social_post_signal.dart';
import '../models/orchestration_models.dart';
import '../agents/agent_pipeline.dart';
import '../agents/ai_agent_pipeline.dart';
import '../services/groq_service.dart';
import '../services/real_signal_service.dart';
import '../services/notification_service.dart';
import '../services/location_service.dart';
import '../services/real_scenario_adapter.dart';
import '../services/app_config.dart';

class ScenarioEngine extends ChangeNotifier {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final ScenarioEngine instance = ScenarioEngine._();
  ScenarioEngine._();

  // ── State ─────────────────────────────────────────────────────────────────
  late PipelineResult _currentResult;
  String _activeScenarioId = 'SCN-001';
  bool _isRunning = false;
  bool _isAiActive = false;
  bool _isUsingFallback = false;
  final List<String> _internalDebugLogs = [];
  CrisisType? _injectedRealCrisisType;
  RealSignalBundle? _lastRealBundle;

  bool get isAiActive => _isAiActive;
  bool get isUsingFallback => _isUsingFallback;
  List<String> get internalDebugLogs => _internalDebugLogs;
  CrisisType? get injectedRealCrisisType => _injectedRealCrisisType;
  List<SocialPostSignal> get latestSocialPosts =>
      _lastRealBundle?.socialPosts ?? const [];

  void setInjectedRealCrisisType(CrisisType? type) {
    if (_injectedRealCrisisType == type) return;
    _injectedRealCrisisType = type;
    notifyListeners();
    // Re-run real signal analysis if in Real Mode (SCN-REAL)
    if (_activeScenarioId == 'SCN-REAL') {
      final loc = _currentResult.scenario.coordinates;
      double? lat;
      double? lng;
      try {
        final parts = loc.split(',');
        if (parts.length == 2) {
          lat = double.parse(parts[0].trim());
          lng = double.parse(parts[1].trim());
        }
      } catch (_) {}
      runRealSignalAnalysis(latitude: lat, longitude: lng);
    }
  }

  // ── Init ──────────────────────────────────────────────────────────────────
  void initialize() {
    _currentResult = _runPipeline(scenarioById('SCN-001'));
  }

  // ── Public getters ────────────────────────────────────────────────────────
  PipelineResult get currentResult => _currentResult;
  DemoScenario get activeScenario => _currentResult.scenario;
  Crisis get activeCrisis => _currentResult.crisis;
  String get activeScenarioId => _activeScenarioId;
  bool get isRunning => _isRunning;

  List<PlanAction> get responsePlan => _currentResult.responsePlan;
  SimulationResult get simulation => _currentResult.simulation;
  List<AgentLog> get agentLogs => _currentResult.agentLogs;
  ResourceAllocation get resources => _currentResult.resources;
  VerificationDecision get verification => _currentResult.verification;
  List<String> get fusionPoints => _currentResult.fusionPoints;
  List<StakeholderNotification> get stakeholderNotifications =>
      _currentResult.stakeholderNotifications;
  List<AntigravityTraceEvent> get antigravityTrace =>
      _currentResult.antigravityTrace;

  List<DemoScenario> get allScenarios => mockDemoScenarios;

  // ── Scenario selection ────────────────────────────────────────────────────
  Future<void> selectScenario(String id) async {
    if (_activeScenarioId == id && !_isRunning) return;
    _isRunning = true;
    notifyListeners();

    // Simulate brief pipeline execution delay for demo feel
    await Future.delayed(const Duration(milliseconds: 800));

    _activeScenarioId = id;
    _currentResult = _runPipeline(scenarioById(id));
    _isRunning = false;
    notifyListeners();
  }

  void reset() {
    selectScenario('SCN-001');
  }

  // ── Pipeline orchestration ────────────────────────────────────────────────
  PipelineResult _runPipeline(DemoScenario scenario) {
    // Run all 9 agents in sequence
    final crisis = runDetectionAgent(scenario);
    final fusionPts = runFusionAgent(scenario);
    final resources = runResourceAgent(scenario);
    final plan = runResponsePlannerAgent(scenario);
    final simulation = runSimulationAgent(scenario);
    final verification = runVerificationAgent(scenario);
    final logs = runLogAgent(scenario, crisis);
    final signalAssessments = runSignalAssessmentAgent(scenario);
    final evolution = runEvolutionAgent(scenario);
    final resourceDecisions = runResourceDecisionAgent(scenario);
    final notifications = runStakeholderAgent(scenario);
    final coordination = runCoordinationAgent(scenario);
    final antigravityTrace = runAntigravityTraceAgent(
      scenario,
      crisis,
      resources,
      verification,
    );

    return PipelineResult(
      scenario: scenario,
      crisis: crisis,
      fusionPoints: fusionPts,
      resources: resources,
      responsePlan: plan,
      simulation: simulation,
      verification: verification,
      agentLogs: logs,
      signalAssessments: signalAssessments,
      evolution: evolution,
      resourceDecisions: resourceDecisions,
      stakeholderNotifications: notifications,
      coordination: coordination,
      antigravityTrace: antigravityTrace,
      generatedAt: DateTime.now(),
    );
  }

  void overrideLocation(String newLocation, {double? lat, double? lng}) {
    final oldScenario = _currentResult.scenario;
    final updatedScenario = DemoScenario(
      id: oldScenario.id,
      title: oldScenario.title,
      crisisType: oldScenario.crisisType,
      location: newLocation,
      coordinates: lat != null && lng != null
          ? '$lat,$lng'
          : oldScenario.coordinates,
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
      responseActions: oldScenario.responseActions
          .map(
            (action) => PlanAction(
              step: action.step,
              title: action.title.replaceAll('G-10', newLocation),
              description: action.description.replaceAll('G-10', newLocation),
              department: action.department,
              priority: action.priority,
              eta: action.eta,
              status: action.status,
              resultSummary: action.resultSummary,
            ),
          )
          .toList(),
      simulationMetrics: oldScenario.simulationMetrics,
      possibleSideEffects: oldScenario.possibleSideEffects,
      verificationType: oldScenario.verificationType,
      verificationNote: oldScenario.verificationNote,
      mapZoneLabel: newLocation,
      resourceSummary: oldScenario.resourceSummary,
      resourceUnits: oldScenario.resourceUnits,
      orchestration: oldScenario.orchestration,
    );

    _currentResult = _runPipeline(updatedScenario);
    notifyListeners();
  }

  // ── Real Mode state management ─────────────────────────────────────────────

  /// Resets the engine state to a pristine signal monitoring baseline.
  void resetRealAnalysis() {
    _isAiActive = false;
    _isUsingFallback = false;
    _internalDebugLogs.clear();
    final pristineScenario = DemoScenario(
      id: 'SCN-REAL',
      title: 'Active Signal Monitoring',
      crisisType: CrisisType.roadBlockage,
      location: 'Detecting Location...',
      coordinates: '33.6946°N, 73.0179°E',
      severity: SeverityLevel.low,
      confidence: 100,
      status: CrisisStatus.monitoring,
      affectedPopulation: 0,
      expectedDuration: '-',
      likelyEvolution:
          'Continuous scan active. Awaiting location detection to fetch local signals.',
      socialSignal: const SignalInput(
        source: SignalSource.socialPost,
        content: 'Signal feed: Monitoring',
        confidence: 1.0,
      ),
      weatherSignal: const SignalInput(
        source: SignalSource.weatherAlert,
        content: 'Weather feed: Monitoring',
        confidence: 1.0,
      ),
      trafficSignal: const SignalInput(
        source: SignalSource.trafficData,
        content: 'Traffic feed: Monitoring',
        confidence: 1.0,
      ),
      extraSignals: const [],
      responseActions: const [],
      simulationMetrics: const [],
      possibleSideEffects: const [],
      verificationType: VerificationType.needsVerification,
      verificationNote: 'System initialized. Awaiting real signal integration.',
      mapZoneLabel: 'Monitoring Sector',
      resourceSummary: 'All units standby',
      resourceUnits: const [],
      orchestration: const ScenarioOrchestrationHints(
        affectedRadius: '0 km',
        peakImpactTime: 'None',
        spreadRisk: 'No spread risk while monitoring',
        uncertaintyRange: '+/- 5%',
        fallbackMode:
            'Degraded monitoring baseline. Missing APIs do not block demo mode.',
      ),
    );
    _activeScenarioId = 'SCN-REAL';
    _currentResult = _runPipeline(pristineScenario);
    notifyListeners();
  }

  /// Triggers a live signal analysis by fetching GPS, reverse geocoding, querying APIs,
  /// and running the Groq AI agent pipeline (or deterministic fallback).
  Future<void> runRealSignalAnalysis({
    double? latitude,
    double? longitude,
    String? area,
  }) async {
    _isRunning = true;
    notifyListeners();

    try {
      _internalDebugLogs.clear();
      GroqService.instance.resetLastCallStatus();

      // Check key configuration — Groq
      final hasGroq = AppConfig.instance.hasGroqKey;
      _internalDebugLogs.add('Groq key: ${hasGroq ? "yes" : "no"}');

      double? lat = latitude;
      double? lng = longitude;
      if (lat == null || lng == null) {
        final loc = await LocationService.instance.getCurrentLocation();
        lat = loc.latitude;
        lng = loc.longitude;
      }

      // 1. Fetch all real signals (weather, news, traffic in parallel)
      final bundle = await RealSignalService.instance.fetchAll(
        useMockLocation: lat == null || lng == null,
        latitude: lat,
        longitude: lng,
      );
      _lastRealBundle = bundle;

      _activeScenarioId = 'SCN-REAL';

      // 2. Health-check: Groq, then local fallback
      bool aiWorks = false;

      if (hasGroq) {
        _internalDebugLogs.add('Testing Groq connection...');
        final testResult = await GroqService.instance.generateText('Ping');
        if (testResult != null && GroqService.instance.lastCallSucceeded) {
          aiWorks = true;
          _isAiActive = true; // reusing flag — means "AI is active"
          _isUsingFallback = false;
          _internalDebugLogs.add(
            'Groq test passed ✓ — Llama 3.3 pipeline active',
          );
        } else {
          _internalDebugLogs.add('Groq test failed - local fallback activated');
        }
      }

      if (!aiWorks) {
        _isAiActive = false;
        _isUsingFallback = true;
        if (!hasGroq) {
          _internalDebugLogs.add(
            'No Groq key configured - local fallback activated',
          );
        }
      }

      // 3. Route to AI pipeline if working, else Local Agentic Fallback
      if (aiWorks) {
        debugPrint('[ScenarioEngine] Running Groq AI pipeline...');
        _currentResult = await AiAgentPipeline.run(bundle);
        debugPrint('[ScenarioEngine] Groq AI pipeline complete.');

        // Double-check in case any sub-agent failed during run
        final stillWorking = GroqService.instance.lastCallSucceeded;
        if (!stillWorking) {
          _isAiActive = false;
          _isUsingFallback = true;
          _internalDebugLogs.add(
            'AI sub-agent failed during run — fallback active next cycle',
          );
        }
      } else {
        debugPrint(
          '[ScenarioEngine] AI unavailable — using Local Agentic Fallback Mode.',
        );
        final scenario = _toDemoScenario(bundle);
        _currentResult = _runPipeline(scenario);
      }

      _isRunning = false;
      notifyListeners();

      // 4. Trigger notifications based on crisis severity and conditions
      _triggerNotificationsForRealMode(bundle);
    } catch (e) {
      debugPrint('[ScenarioEngine] Real analysis error: $e');
      _isRunning = false;
      notifyListeners();
    }
  }

  /// Maps a live RealSignalBundle into a DemoScenario for agent consumption.
  DemoScenario _toDemoScenario(RealSignalBundle bundle) {
    return RealScenarioAdapter.fromBundle(bundle);
  }

  /*
    final weatherAlert = bundle.weather?.alertLevel ?? WeatherRisk.none;
    final rainfall = bundle.weather?.rainfallLastHour ?? 0.0;
    final temp = bundle.weather?.temperature ?? 0.0;
    final trafficLevel = bundle.traffic?.congestionLevel ?? CongestionLevel.unknown;
    final delayRatio = bundle.traffic?.delayRatio ?? 1.0;

    CrisisType detectedType = CrisisType.roadBlockage;
    double confidence = 50.0;
    SeverityLevel severity = SeverityLevel.low;
    String likelyEvolution = 'Normal operations. No active crisis detected.';
    String title = 'No Active Crisis Detected near you';
    String locationStr = bundle.location.displayLabel;
    String coordinatesStr = '${bundle.location.latitude ?? 33.6946}°N, ${bundle.location.longitude ?? 73.0179}°E';
    
    // Core keyword matches in news signals
    bool hasFloodNews = false;
    bool hasAccidentNews = false;
    bool hasTrafficNews = false;
    bool hasHeatwaveNews = false;
    bool hasPowerNews = false;

    for (final article in bundle.newsSignals) {
      final text = '${article.title} ${article.description}'.toLowerCase();
      if (text.contains('flood') || text.contains('rain') || text.contains('waterlog')) {
        hasFloodNews = true;
      }
      if (text.contains('accident') || text.contains('collision') || text.contains('crash')) {
        hasAccidentNews = true;
      }
      if (text.contains('traffic') || text.contains('congestion') || text.contains('block')) {
        hasTrafficNews = true;
      }
      if (text.contains('heat') || text.contains('temperature') || text.contains('warm')) {
        hasHeatwaveNews = true;
      }
      if (text.contains('power') || text.contains('electricity') || text.contains('outage') || text.contains('load shedding')) {
        hasPowerNews = true;
      }
    }

    // Agent decision rules matching real-world criteria
    if (weatherAlert == WeatherRisk.heavyRain || weatherAlert == WeatherRisk.floodRisk || rainfall > 15.0 || hasFloodNews) {
      detectedType = CrisisType.urbanFlooding;
      title = 'Urban Flooding';
      severity = (rainfall > 30.0 || weatherAlert == WeatherRisk.floodRisk) ? SeverityLevel.critical : SeverityLevel.high;
      confidence = 75.0 + (bundle.newsSignals.isNotEmpty ? 15.0 : 5.0);
      likelyEvolution = 'Low-lying areas and underpasses may flood rapidly. High chance of traffic gridlock.';
    } else if (temp > 38.0 || weatherAlert == WeatherRisk.heatwave || hasHeatwaveNews) {
      detectedType = CrisisType.heatwave;
      title = 'Extreme Heatwave';
      severity = temp > 43.0 ? SeverityLevel.critical : SeverityLevel.high;
      confidence = 80.0 + (hasHeatwaveNews ? 10.0 : 0.0);
      likelyEvolution = 'High risk of dehydration and heat stroke for outdoor workers. Power grid surge expected.';
    } else if (hasAccidentNews) {
      detectedType = CrisisType.accident;
      title = 'Vehicle Accident';
      severity = SeverityLevel.high;
      confidence = 85.0;
      likelyEvolution = 'Traffic congestion at the intersection will intensify. Emergency dispatch required.';
    } else if (hasPowerNews) {
      detectedType = CrisisType.powerOutage;
      title = 'Power Outage';
      severity = SeverityLevel.moderate;
      confidence = 75.0;
      likelyEvolution = 'Blackout in local residential sectors, affecting water supplies and public services.';
    } else if (trafficLevel == CongestionLevel.high || delayRatio > 1.4 || hasTrafficNews) {
      detectedType = CrisisType.roadBlockage;
      title = 'Road Blockage';
      severity = trafficLevel == CongestionLevel.high ? SeverityLevel.high : SeverityLevel.moderate;
      confidence = 80.0;
      likelyEvolution = 'High congestion will persist unless traffic is diverted. Standard commute delays.';
    }

    // Build the inputs
    final weatherContent = bundle.weather?.isSuccess == true 
        ? 'Weather: ${bundle.weather!.condition} (${bundle.weather!.description}), ${bundle.weather!.temperatureLabel}, rain: ${bundle.weather!.rainfallLabel}'
        : 'Weather: No critical signals';
    
    final trafficContent = bundle.traffic?.isSuccess == true
        ? 'Traffic: ${bundle.traffic!.congestionLabel} congestion (${bundle.traffic!.normalDurationMinutes}m normal, ${bundle.traffic!.trafficDurationMinutes}m traffic)'
        : 'Traffic: No traffic anomalies';

    final socialContent = bundle.newsSignals.isNotEmpty
        ? 'News signals: ${bundle.newsSignals.length} relevant articles found. Latest: "${bundle.newsSignals.first.title}"'
        : 'Citizen feed: No active crisis reports or abnormal keywords detected.';

    // Generate responsive actions and simulation metrics based on detected crisis type
    final responseActions = <PlanAction>[];
    final simulationMetrics = <MetricPair>[];
    final resourceUnits = <String>[];
    String resourceSummary = 'All units standby';

    if (severity != SeverityLevel.low) {
      resourceSummary = 'Emergency response teams mobilized';
      if (detectedType == CrisisType.urbanFlooding) {
        resourceUnits.addAll(['Rescue Boat RB-10', 'Pumping Unit PU-05', 'Ambulance AMB-08']);
        responseActions.addAll([
          const PlanAction(
            step: 1,
            title: 'Reroute Traffic via Nearest Alternate',
            description: 'Activate diversion signs at main avenues and deploy traffic wardens to clear underpasses.',
            department: 'CDA Traffic Management',
            priority: 'P1',
            eta: '3 min',
            status: 'In Progress',
            resultSummary: 'Wardens en route. Diversion signboards updated.',
          ),
          const PlanAction(
            step: 2,
            title: 'Dispatch High-Capacity Water Pumps',
            description: 'Mobilize 1122 dewatering pumps to low-lying drainage choke points.',
            department: 'Rescue 1122 & CDA Drainage',
            priority: 'P1',
            eta: '10 min',
            status: 'Pending',
          ),
          const PlanAction(
            step: 3,
            title: 'Broadcast Public Safety SMS Alert',
            description: 'Send localized emergency SMS broadcast warning citizens to avoid underpasses and secure basements.',
            department: 'PSCA Emergency Broadcast',
            priority: 'P2',
            eta: '5 min',
            status: 'Completed',
            resultSummary: 'SMS broadcast sent to 2,500 local residents.',
          ),
          const PlanAction(
            step: 4,
            title: 'Create Emergency Incident Ticket #CR-REAL-01',
            description: 'Log verified urban flood incident in Federal Emergency Operations Center database.',
            department: 'NDMA Control Room',
            priority: 'P3',
            eta: '2 min',
            status: 'Completed',
            resultSummary: 'Incident Ticket #CR-REAL-01 created and escalated.',
          ),
        ]);
        simulationMetrics.addAll([
          const MetricPair(label: 'Congestion %', before: '82%', after: '45%', delta: '▼ 37%', isImprovement: true),
          const MetricPair(label: 'Response Time', before: '20 min', after: '8 min', delta: '▼ 12 min', isImprovement: true),
          const MetricPair(label: 'Pumping Level', before: '0 L/m', after: '4,500 L/m', delta: '▲ 4.5k', isImprovement: true),
          const MetricPair(label: 'Risk Index', before: 'Critical', after: 'Moderate', delta: '▼ -2', isImprovement: true),
        ]);
      } else if (detectedType == CrisisType.heatwave) {
        resourceUnits.addAll(['Medical Team MT-05', 'Water Truck WT-02']);
        responseActions.addAll([
          const PlanAction(
            step: 1,
            title: 'Establish Mobile Hydration Points',
            description: 'Deploy WASA water distribution trucks to commercial sectors.',
            department: 'WASA Operations',
            priority: 'P1',
            eta: '15 min',
            status: 'In Progress',
          ),
          const PlanAction(
            step: 2,
            title: 'Alert Hospital Trauma Wings',
            description: 'Notify closest government clinics to allocate dedicated heatstroke emergency beds.',
            department: 'Health Ministry & Local Clinics',
            priority: 'P1',
            status: 'Completed',
            eta: '5 min',
            resultSummary: '15 beds cleared. Ambulance pathways notified.',
          ),
          const PlanAction(
            step: 3,
            title: 'Broadcast Extreme Heat Advisory SMS',
            description: 'Send public safety health warnings with hydration guidelines.',
            department: 'PSCA Broadcast Services',
            priority: 'P2',
            eta: '3 min',
            status: 'Completed',
            resultSummary: 'Hydration advisory broadcast on local FM radio and SMS.',
          ),
        ]);
        simulationMetrics.addAll([
          const MetricPair(label: 'At-Risk Population', before: '4,500', after: '800', delta: '▼ 3,700', isImprovement: true),
          const MetricPair(label: 'Hospital Capacity', before: '0 beds', after: '15 beds', delta: '▲ +15', isImprovement: true),
          const MetricPair(label: 'Risk Level', before: 'High', after: 'Moderate', delta: '▼ -1', isImprovement: true),
        ]);
      } else if (detectedType == CrisisType.accident) {
        resourceUnits.addAll(['Ambulance AMB-09', 'Towing Unit TW-03']);
        responseActions.addAll([
          const PlanAction(
            step: 1,
            title: 'Dispatch Emergency Ambulance',
            description: 'Deploy Rescue 1122 ambulance unit to stabilize and triage victims.',
            department: 'Rescue 1122 Command',
            priority: 'P1',
            eta: '6 min',
            status: 'In Progress',
          ),
          const PlanAction(
            step: 2,
            title: 'Clear Traffic Lanes',
            description: 'Deploy traffic police wardens to redirect flow and secure accident zone.',
            department: 'Traffic Wardens Division',
            priority: 'P1',
            eta: '4 min',
            status: 'Completed',
            resultSummary: 'Wardens arrived. Single lane opened for light vehicles.',
          ),
        ]);
        simulationMetrics.addAll([
          const MetricPair(label: 'Congestion %', before: '75%', after: '30%', delta: '▼ 45%', isImprovement: true),
          const MetricPair(label: 'Triage Time', before: '15 min', after: '6 min', delta: '▼ 9 min', isImprovement: true),
        ]);
      } else if (detectedType == CrisisType.powerOutage) {
        resourceUnits.addAll(['IESCO Utility Team UT-04', 'Generator Unit GEN-03']);
        responseActions.addAll([
          const PlanAction(
            step: 1,
            title: 'Dispatch IESCO Substation Repair Crew',
            description: 'Deploy utility technicians to diagnose feeder fault and restore transformer baseline.',
            department: 'IESCO Grid Support',
            priority: 'P1',
            eta: '12 min',
            status: 'In Progress',
          ),
          const PlanAction(
            step: 2,
            title: 'Deploy Emergency Backup Generator',
            description: 'Supply NDMA mobile generator units to local critical care health centers.',
            department: 'NDMA Utility Equipment',
            priority: 'P1',
            eta: '20 min',
            status: 'Pending',
          ),
        ]);
        simulationMetrics.addAll([
          const MetricPair(label: 'Power Restored', before: '0%', after: '70%', delta: '▲ +70%', isImprovement: true),
          const MetricPair(label: 'Risk Level', before: 'Moderate', after: 'Low', delta: '▼ -1', isImprovement: true),
        ]);
      } else {
        resourceUnits.addAll(['Traffic Patrol TP-02', 'Towing Truck TW-04']);
        responseActions.addAll([
          const PlanAction(
            step: 1,
            title: 'Deploy Traffic wardens to Jinnah Avenue',
            description: 'Manually manage and disperse commercial congestion blockages.',
            department: 'Traffic Wardens',
            priority: 'P1',
            eta: '5 min',
            status: 'Completed',
            resultSummary: 'Warden arrived. Confirmed overturned vehicle is primary cause.',
          ),
          const PlanAction(
            step: 2,
            title: 'Mobilize Towing Unit',
            description: 'Clear vehicle wreckage from highway lanes.',
            department: 'CDA Heavy Road Operations',
            priority: 'P1',
            eta: '15 min',
            status: 'In Progress',
          ),
        ]);
        simulationMetrics.addAll([
          const MetricPair(label: 'Congestion %', before: '88%', after: '34%', delta: '▼ 54%', isImprovement: true),
          const MetricPair(label: 'Response Time', before: '25 min', after: '5 min', delta: '▼ 20 min', isImprovement: true),
        ]);
      }
    } else {
      // Normal monitoring actions
      responseActions.addAll([
        const PlanAction(
          step: 1,
          title: 'Continuous Background Signal Polling',
          description: 'Regularly query weather, traffic, and citizen reports across safety baselines.',
          department: 'CIRO Automated Monitor',
          priority: 'P3',
          eta: 'Ongoing',
          status: 'Completed',
          resultSummary: 'All channels reporting safe operating limits.',
        ),
        const PlanAction(
          step: 2,
          title: 'Verify Baseline Sensor Values',
          description: 'Confirm local temperature, moisture, and road flow sensors match PMD benchmarks.',
          department: 'IoT Analytics Engine',
          priority: 'P3',
          eta: '5 min',
          status: 'Completed',
          resultSummary: 'Baseline metrics verified.',
        ),
      ]);
      simulationMetrics.addAll([
        const MetricPair(label: 'Risk Index', before: '5%', after: '5%', delta: '0%', isImprovement: false),
        const MetricPair(label: 'Active Signals', before: '0', after: '0', delta: '0', isImprovement: false),
      ]);
    }

    return DemoScenario(
      id: 'SCN-REAL',
      title: title,
      crisisType: detectedType,
      location: locationStr,
      coordinates: coordinatesStr,
      severity: severity,
      confidence: confidence,
      status: severity == SeverityLevel.low ? CrisisStatus.monitoring : CrisisStatus.active,
      affectedPopulation: severity == SeverityLevel.low ? 0 : 800,
      expectedDuration: severity == SeverityLevel.low ? '-' : '2–4 hours',
      likelyEvolution: likelyEvolution,
      socialSignal: SignalInput(source: SignalSource.socialPost, content: socialContent, confidence: 0.8),
      weatherSignal: SignalInput(source: SignalSource.weatherAlert, content: weatherContent, confidence: 0.9),
      trafficSignal: SignalInput(source: SignalSource.trafficData, content: trafficContent, confidence: 0.9),
      extraSignals: const [],
      responseActions: responseActions,
      simulationMetrics: simulationMetrics,
      possibleSideEffects: const [],
      verificationType: severity == SeverityLevel.low ? VerificationType.needsVerification : VerificationType.confirmed,
      verificationNote: severity == SeverityLevel.low 
          ? 'Continuous background scanning is operational. Signals remain inside safety thresholds.'
          : 'Live API correlation confirms crisis patterns matching keywords and thresholds.',
      mapZoneLabel: locationStr,
      resourceSummary: resourceSummary,
      resourceUnits: resourceUnits,
      orchestration: ScenarioOrchestrationHints(
        resourceConstraint: bundle.succeeded
            ? 'Real API bundle available with ${bundle.signalCount} active signal(s).'
            : 'API data unavailable; CIRO remains in mock-first fallback mode.',
        affectedRadius: severity == SeverityLevel.low ? '0.5 km monitoring radius' : '1.5 km live radius',
        peakImpactTime: severity == SeverityLevel.low ? 'None' : '30-90 min',
        spreadRisk: severity == SeverityLevel.low ? 'Low' : likelyEvolution,
        uncertaintyRange: bundle.warnings.isEmpty ? '+/- 15%' : '+/- 25% due to partial API data',
        resourceTradeOffs: bundle.warnings.isEmpty
            ? const ['Live source confidence is sufficient for standard dispatch.']
            : bundle.warnings.map((w) => 'Fallback note: $w').toList(),
        fallbackMode: bundle.warnings.isEmpty
            ? 'All configured real services responded.'
            : 'Partial real mode: ${bundle.warnings.join("; ")}',
      ),
    );
  }
  */

  /// Triggers local notifications to alert users to real-time events.
  void _triggerNotificationsForRealMode(RealSignalBundle bundle) {
    // 1. Analysis complete notification
    NotificationService.instance.addNotification(
      title: 'CIRO Analysis Complete',
      details:
          'Signal integration completed for ${bundle.location.displayLabel}. Fused ${bundle.signalCount} active signals from Weather, Routes, and News APIs.',
    );

    // 2. High severity weather alert (rain/flood)
    final weather = bundle.weather;
    if (weather != null && weather.isSuccess) {
      if (weather.alertLevel == WeatherRisk.heavyRain ||
          weather.alertLevel == WeatherRisk.floodRisk ||
          weather.rainfallLastHour > 15.0) {
        NotificationService.instance.addNotification(
          title: 'Critical Rainfall Warning',
          details:
              'OpenWeather reports ${weather.rainfallLabel} in ${bundle.location.city}. CIRO is watching for urban flooding and drainage overload.',
          showSystem: true,
        );
      }
      // 2b. Heatwave alert
      if (weather.alertLevel == WeatherRisk.heatwave ||
          weather.temperature >= 42) {
        NotificationService.instance.addNotification(
          title: 'Critical Heatwave Alert',
          details:
              'Temperature is ${weather.temperatureLabel}, feels like ${weather.feelsLikeLabel}. Stay hydrated and avoid direct outdoor exposure.',
          showSystem: true,
        );
      }
    }

    // 3. Severe traffic blockage alert
    final traffic = bundle.traffic;
    if (traffic != null && traffic.isSuccess) {
      if (traffic.congestionLevel == CongestionLevel.high ||
          traffic.delayRatio > 1.4) {
        NotificationService.instance.addNotification(
          title: 'High Traffic Blockage',
          details:
              'Google Routes reports heavy slowdowns near ${bundle.location.area}. Alternate routing is recommended.',
          showSystem: true,
        );
      }
    }

    // 4. High/Critical severity crisis detected
    if (_currentResult.crisis.severity == SeverityLevel.high ||
        _currentResult.crisis.severity == SeverityLevel.critical) {
      NotificationService.instance.addNotification(
        title: 'Verified Incident: ${_currentResult.crisis.title}',
        details:
            'CIRO confirms an active ${_classificationLabel(_currentResult.crisis.type)} crisis at ${_currentResult.crisis.location}. Response guidance is ready.',
        showSystem: true,
      );
    }

    // 5. Confirmed verification status
    if (_currentResult.verification.type == VerificationType.confirmed) {
      NotificationService.instance.addNotificationWithId(
        id: 'VERIFIED-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Crisis Confirmed by Verification',
        details:
            '${_currentResult.verification.label}: ${_currentResult.verification.note}',
      );
    }
  }

  String _classificationLabel(CrisisType t) {
    switch (t) {
      case CrisisType.urbanFlooding:
        return 'Urban Flooding';
      case CrisisType.roadBlockage:
        return 'Road Blockage';
      case CrisisType.accident:
        return 'Accident';
      case CrisisType.heatwave:
        return 'Heatwave';
      case CrisisType.powerOutage:
        return 'Power Outage';
    }
  }
}
