// CIRO - Real Scenario Adapter
// Converts a live RealSignalBundle into a complete pipeline-ready scenario.
// Live sources are used where available; derived sensor/call/field signals are
// explicitly marked as CIRO-derived because public access to those feeds varies.

import '../models/crisis.dart';
import '../models/demo_scenario.dart';
import '../models/orchestration_models.dart';
import '../models/route_result.dart';
import '../models/signal.dart';
import '../models/weather_result.dart';
import 'real_signal_service.dart';

class RealScenarioAdapter {
  const RealScenarioAdapter._();

  static DemoScenario fromBundle(RealSignalBundle bundle) {
    final location = bundle.location.displayLabel;
    final weather = bundle.weather;
    final traffic = bundle.traffic;

    final classification = _classify(bundle);
    final type = classification.type;
    final severity = classification.severity;
    final confidence = classification.confidence;
    final active = severity != SeverityLevel.low;
    final affected = _affectedPopulation(type, severity, traffic);
    final duration = _duration(type, severity);
    final evolution = _evolution(type, severity, location);
    final title = active ? '${_typeLabel(type)} - $location' : 'No Active Crisis Detected - $location';

    final socialSignal = SignalInput(
      source: SignalSource.socialPost,
      content: bundle.newsSignals.isNotEmpty
          ? 'Live news/public feed: ${bundle.newsSignals.length} relevant article(s). Latest: "${bundle.newsSignals.first.title}" (${bundle.newsSignals.first.source}).'
          : 'Live public/news feed: no crisis keywords found near $location.',
      confidence: bundle.newsSignals.isNotEmpty ? 0.78 : 0.55,
      isActive: bundle.newsSignals.isNotEmpty || active,
    );

    final weatherSignal = SignalInput(
      source: SignalSource.weatherAlert,
      content: weather?.isSuccess == true
          ? 'Live OpenWeather: ${weather!.condition} (${weather.description}), temp ${weather.temperatureLabel}, feels ${weather.feelsLikeLabel}, rain ${weather.rainfallLabel}, alert ${weather.alertLabel}.'
          : 'Live weather unavailable; no official weather signal fused.',
      confidence: weather?.isSuccess == true ? 0.92 : 0.30,
      isActive: weather?.isSuccess == true,
    );

    final trafficSignal = SignalInput(
      source: SignalSource.trafficData,
      content: traffic?.isSuccess == true
          ? 'Live Google Routes: ${traffic!.congestionLabel} congestion, ${traffic.normalDurationMinutes}m normal vs ${traffic.trafficDurationMinutes}m with traffic, delay ${traffic.delayMinutes}m.'
          : 'Live traffic unavailable; route anomaly not confirmed.',
      confidence: traffic?.isSuccess == true ? 0.88 : 0.30,
      isActive: traffic?.isSuccess == true,
    );

    final extraSignals = _derivedSignals(bundle, type, severity, active);
    final responseActions = active
        ? _actions(type, location, affected)
        : _monitoringActions(location);
    final metrics = active
        ? _metrics(type, severity, affected, traffic)
        : const [
            MetricPair(label: 'Risk Index', before: '5%', after: '5%', delta: '0%', isImprovement: false),
            MetricPair(label: 'Active Live Alerts', before: '0', after: '0', delta: '0', isImprovement: false),
          ];

    final warnings = [
      if (bundle.location.isMock) 'GPS fallback location used',
      ...bundle.warnings,
      if (bundle.newsSignals.isEmpty) 'News/public feed returned no relevant local crisis articles',
    ];

    return DemoScenario(
      id: 'SCN-REAL',
      title: title,
      crisisType: type,
      location: location,
      coordinates: '${bundle.location.latitude ?? 0},${bundle.location.longitude ?? 0}',
      severity: severity,
      confidence: confidence,
      status: active ? CrisisStatus.active : CrisisStatus.monitoring,
      affectedPopulation: affected,
      expectedDuration: duration,
      likelyEvolution: evolution,
      socialSignal: socialSignal,
      weatherSignal: weatherSignal,
      trafficSignal: trafficSignal,
      extraSignals: extraSignals,
      responseActions: responseActions,
      simulationMetrics: metrics,
      possibleSideEffects: _sideEffects(type, active),
      verificationType: _verification(bundle, active, confidence),
      verificationNote: _verificationNote(bundle, active, confidence),
      mapZoneLabel: location,
      resourceSummary: active ? _resourceSummary(type) : 'All units standby; live monitoring active',
      resourceUnits: active ? _resources(type) : const ['CIRO Live Monitor'],
      orchestration: ScenarioOrchestrationHints(
        resourceConstraint: active
            ? 'Live location response pool assigned from city emergency baseline; private inventories unavailable.'
            : 'No dispatch needed; live sources remain under monitoring thresholds.',
        affectedRadius: active ? _radius(type, severity) : '0.5 km monitoring radius',
        peakImpactTime: active ? _peak(type) : 'None',
        spreadRisk: active ? _spreadRisk(type) : 'Low',
        uncertaintyRange: warnings.isEmpty ? '+/- 15%' : '+/- 25%',
        resourceTradeOffs: active
            ? _tradeOffs(type, warnings)
            : ['No emergency resources consumed while live signals remain below threshold.'],
        stakeholderMessages: _stakeholders(type, location, active, warnings),
        fallbackMode: warnings.isEmpty
            ? 'Real Mode: live GPS/geocode/weather/news/routes fused successfully.'
            : 'Real Mode degraded sources: ${warnings.join("; ")}.',
      ),
    );
  }

  static _Classification _classify(RealSignalBundle bundle) {
    final weather = bundle.weather;
    final traffic = bundle.traffic;
    final text = bundle.newsSignals
        .map((n) => '${n.title} ${n.description} ${n.matchedKeyword}')
        .join(' ')
        .toLowerCase();

    final rainfall = weather?.rainfallLastHour ?? 0;
    final temp = weather?.temperature ?? 0;
    final feels = weather?.feelsLike ?? temp;
    final delay = traffic?.delayRatio ?? 1.0;
    final congestion = traffic?.congestionLevel ?? CongestionLevel.unknown;

    final userArea = bundle.location.area.toLowerCase();
    final isInjected = bundle.warnings.any((w) => w.contains('Simulated threat'));

    // Helper to check if a news article specifically names the user's immediate area
    bool isLocallySpecific(String newsText) {
      if (isInjected) return true;
      if (userArea.isEmpty) return false;
      final normalizedArea = userArea.replaceAll('-', '').trim();
      final normalizedNews = newsText.replaceAll('-', '').toLowerCase();
      return normalizedNews.contains(normalizedArea);
    }

    // 1. FLOOD: Trigger only if heavy rainfall measured, active flood alert, or a local news report confirms it in the exact area
    final hasActiveFloodWeather = weather?.alertLevel == WeatherRisk.floodRisk ||
        rainfall > 12.0;
    final hasLocalFloodNews = (text.contains('flood') || text.contains('waterlog')) && isLocallySpecific(text);
    final flood = hasActiveFloodWeather || hasLocalFloodNews;

    // 2. HEATWAVE: Trigger only if temp is extreme or local heat news specifically targets their area
    final hasActiveHeatWeather = weather?.alertLevel == WeatherRisk.heatwave || temp >= 39.0 || feels >= 42.0;
    final hasLocalHeatNews = text.contains('heatwave') && isLocallySpecific(text);
    final heat = hasActiveHeatWeather || hasLocalHeatNews;

    // 3. ACCIDENT: Trigger only if a news report confirms a collision in their exact area
    final accident = (text.contains('accident') || text.contains('collision') || text.contains('crash')) && isLocallySpecific(text);

    // 4. POWER OUTAGE: Trigger only if outage news specifically names their area
    final outage = (text.contains('power outage') || text.contains('blackout') || text.contains('load shedding')) && isLocallySpecific(text);

    // 5. ROAD BLOCKAGE: Trigger only if Google Routes shows severe congestion OR local blockage news names their area
    final hasSevereTraffic = congestion == CongestionLevel.high && delay >= 1.5;
    final hasLocalBlockNews = text.contains('road blocked') && isLocallySpecific(text);
    final blocked = hasSevereTraffic || hasLocalBlockNews;

    if (flood) {
      return _Classification(
        CrisisType.urbanFlooding,
        rainfall > 20 || weather?.alertLevel == WeatherRisk.floodRisk ? SeverityLevel.critical : SeverityLevel.high,
        _confidence(bundle, base: 72, weatherBoost: 12, trafficBoost: blocked ? 8 : 0),
      );
    }
    if (heat) {
      return _Classification(
        CrisisType.heatwave,
        temp >= 43 || feels >= 46 ? SeverityLevel.critical : SeverityLevel.high,
        _confidence(bundle, base: 74, weatherBoost: 14),
      );
    }
    if (accident) {
      return _Classification(
        CrisisType.accident,
        SeverityLevel.high,
        _confidence(bundle, base: 68, trafficBoost: blocked ? 12 : 4),
      );
    }
    if (outage) {
      return _Classification(
        CrisisType.powerOutage,
        SeverityLevel.moderate,
        _confidence(bundle, base: 63, newsBoost: 14),
      );
    }
    if (blocked) {
      return _Classification(
        CrisisType.roadBlockage,
        congestion == CongestionLevel.high ? SeverityLevel.high : SeverityLevel.moderate,
        _confidence(bundle, base: 66, trafficBoost: 16),
      );
    }

    return _Classification(CrisisType.roadBlockage, SeverityLevel.low, bundle.hasRealData ? 90.0 : 95.0);
  }

  static double _confidence(
    RealSignalBundle bundle, {
    required int base,
    int weatherBoost = 0,
    int trafficBoost = 0,
    int newsBoost = 0,
  }) {
    var score = base;
    if (bundle.weather?.isSuccess == true) score += weatherBoost == 0 ? 6 : weatherBoost;
    if (bundle.traffic?.isSuccess == true) score += trafficBoost == 0 ? 5 : trafficBoost;
    if (bundle.newsSignals.isNotEmpty) score += newsBoost == 0 ? 8 : newsBoost;
    score -= bundle.warnings.length * 4;
    return score.clamp(35, 94).toDouble();
  }

  static List<SignalInput> _derivedSignals(
    RealSignalBundle bundle,
    CrisisType type,
    SeverityLevel severity,
    bool active,
  ) {
    final area = bundle.location.displayLabel;
    final signals = <SignalInput>[];
    if (!active) {
      signals.add(SignalInput(
        source: SignalSource.mockSensor,
        content: 'CIRO-derived local sensor baseline for $area: weather and route readings are inside normal limits.',
        confidence: 0.70,
        isActive: true,
      ));
      return signals;
    }

    switch (type) {
      case CrisisType.urbanFlooding:
        signals.add(SignalInput(
          source: SignalSource.mockSensor,
          content: 'CIRO-derived flood sensor estimate for $area: rainfall/runoff risk elevated from live weather and route delay.',
          confidence: 0.82,
        ));
        signals.add(SignalInput(
          source: SignalSource.emergencyCall,
          content: 'CIRO-derived call-frequency estimate: flood/stranding call volume expected above baseline in $area.',
          confidence: 0.74,
        ));
        break;
      case CrisisType.heatwave:
        signals.add(SignalInput(
          source: SignalSource.mockSensor,
          content: 'CIRO-derived heat sensor estimate for $area: live temperature/feels-like crosses health-risk threshold.',
          confidence: 0.86,
        ));
        signals.add(SignalInput(
          source: SignalSource.fieldReport,
          content: 'CIRO-derived field advisory: hydration/cooling outreach recommended near dense outdoor activity zones.',
          confidence: 0.72,
        ));
        break;
      case CrisisType.accident:
        signals.add(SignalInput(
          source: SignalSource.emergencyCall,
          content: 'CIRO-derived emergency-call proxy: accident keywords plus route delay suggest dispatch verification.',
          confidence: 0.75,
        ));
        break;
      case CrisisType.powerOutage:
        signals.add(SignalInput(
          source: SignalSource.mockSensor,
          content: 'CIRO-derived infrastructure sensor proxy: outage keywords require utility confirmation for $area.',
          confidence: 0.70,
        ));
        break;
      case CrisisType.roadBlockage:
        signals.add(SignalInput(
          source: SignalSource.fieldReport,
          content: 'CIRO-derived field task: verify blockage cause and confirm whether towing or traffic control is needed.',
          confidence: 0.73,
        ));
        break;
    }

    if (severity == SeverityLevel.critical) {
      signals.add(SignalInput(
        source: SignalSource.fieldReport,
        content: 'CIRO-derived critical escalation: field commander review required within 10 minutes.',
        confidence: 0.78,
      ));
    }
    return signals;
  }

  static List<PlanAction> _actions(CrisisType type, String location, int affected) {
    switch (type) {
      case CrisisType.urbanFlooding:
        return [
          PlanAction(step: 1, title: 'Reroute Traffic Around $location', description: 'Use live route delays to divert vehicles away from low-lying corridors.', department: 'Traffic Authority', priority: 'P1', eta: '3 min', status: 'In Progress', resultSummary: 'Traffic diversion plan generated from live route signal.'),
          PlanAction(step: 2, title: 'Dispatch Drainage and Rescue Units', description: 'Send pump/rescue crew to highest-risk catchment near the user location.', department: 'Rescue / Municipal Drainage', priority: 'P1', eta: '10 min', status: 'Pending'),
          PlanAction(step: 3, title: 'Send Localized Flood Alert', description: 'Warn approximately $affected nearby residents and commuters.', department: 'Emergency Broadcast', priority: 'P2', eta: '5 min', status: 'Completed'),
        ];
      case CrisisType.heatwave:
        return [
          PlanAction(step: 1, title: 'Open Cooling and Hydration Points', description: 'Deploy water/cooling support around dense public zones near $location.', department: 'Health / Municipal Services', priority: 'P1', eta: '15 min', status: 'In Progress'),
          PlanAction(step: 2, title: 'Notify Nearby Hospitals', description: 'Prepare heatstroke triage for at-risk population estimate of $affected.', department: 'Hospital Coordination', priority: 'P1', eta: '5 min', status: 'Completed'),
          PlanAction(step: 3, title: 'Broadcast Heat Advisory', description: 'Send public health guidance based on live temperature thresholds.', department: 'Emergency Broadcast', priority: 'P2', eta: '3 min', status: 'Completed'),
        ];
      case CrisisType.accident:
        return [
          PlanAction(step: 1, title: 'Dispatch Ambulance and Traffic Police', description: 'Use live congestion and accident keywords to verify and secure scene near $location.', department: 'Rescue / Traffic Police', priority: 'P1', eta: '6 min', status: 'In Progress'),
          PlanAction(step: 2, title: 'Activate Alternate Route', description: 'Reduce secondary collision risk by diverting approach traffic.', department: 'Traffic Authority', priority: 'P1', eta: '4 min', status: 'Completed'),
        ];
      case CrisisType.powerOutage:
        return [
          PlanAction(step: 1, title: 'Escalate Utility Ticket', description: 'Send outage evidence and location to the utility response desk.', department: 'Utility Provider', priority: 'P1', eta: '8 min', status: 'In Progress'),
          PlanAction(step: 2, title: 'Check Critical Backup Power', description: 'Prioritize clinics, signals, and vulnerable facilities near $location.', department: 'Emergency Utilities', priority: 'P2', eta: '15 min', status: 'Pending'),
        ];
      case CrisisType.roadBlockage:
        return [
          PlanAction(step: 1, title: 'Deploy Traffic Control to $location', description: 'Confirm blockage and open a managed lane if possible.', department: 'Traffic Police', priority: 'P1', eta: '5 min', status: 'In Progress'),
          PlanAction(step: 2, title: 'Publish Alternate Route Advisory', description: 'Use live route delay to redirect nearby commuters.', department: 'Transport Authority', priority: 'P2', eta: '3 min', status: 'Completed'),
        ];
    }
  }

  static List<PlanAction> _monitoringActions(String location) => [
        PlanAction(step: 1, title: 'Continue Live Monitoring at $location', description: 'Poll location, weather, public/news, and route signals for threshold changes.', department: 'CIRO Live Monitor', priority: 'P3', eta: 'Ongoing', status: 'Completed'),
        const PlanAction(step: 2, title: 'Keep Fallback Demo Pipeline Ready', description: 'Use mock-first scenario if APIs become unavailable during judging.', department: 'CIRO Runtime', priority: 'P3', eta: 'Ongoing', status: 'Completed'),
      ];

  static List<MetricPair> _metrics(CrisisType type, SeverityLevel severity, int affected, RouteResult? traffic) {
    final congestionBefore = traffic?.congestionPercent ?? (type == CrisisType.roadBlockage ? 75 : 45);
    final congestionAfter = (congestionBefore * 0.62).round();
    final responseBefore = severity == SeverityLevel.critical ? 22 : 16;
    final responseAfter = severity == SeverityLevel.critical ? 8 : 7;
    return [
      MetricPair(label: 'Congestion %', before: '$congestionBefore%', after: '$congestionAfter%', delta: 'down ${congestionBefore - congestionAfter}%', isImprovement: true),
      MetricPair(label: 'Response Time', before: '$responseBefore min', after: '$responseAfter min', delta: 'down ${responseBefore - responseAfter} min', isImprovement: true),
      MetricPair(label: 'Risk Level', before: _severityLabel(severity), after: severity == SeverityLevel.critical ? 'High' : 'Moderate', delta: 'down', isImprovement: true),
      MetricPair(label: 'Affected People', before: '$affected', after: '${(affected * 0.34).round()}', delta: 'down ${(affected * 0.66).round()}', isImprovement: true),
    ];
  }

  static int _affectedPopulation(CrisisType type, SeverityLevel severity, RouteResult? traffic) {
    final base = switch (type) {
      CrisisType.urbanFlooding => 2600,
      CrisisType.heatwave => 4200,
      CrisisType.accident => 900,
      CrisisType.powerOutage => 1800,
      CrisisType.roadBlockage => 1400,
    };
    final sev = severity == SeverityLevel.critical ? 1.45 : severity == SeverityLevel.high ? 1.15 : 0.70;
    final trafficBoost = (traffic?.congestionLevel == CongestionLevel.high) ? 1.25 : 1.0;
    return (base * sev * trafficBoost).round();
  }

  static VerificationType _verification(RealSignalBundle bundle, bool active, double confidence) {
    if (!active) return VerificationType.needsVerification;
    if (confidence >= 78 && bundle.signalCount >= 2) return VerificationType.confirmed;
    if (bundle.warnings.isNotEmpty) return VerificationType.needsVerification;
    return VerificationType.conflictingSignals;
  }

  static String _verificationNote(RealSignalBundle bundle, bool active, double confidence) {
    if (!active) {
      return 'Live sources for ${bundle.location.displayLabel} remain below emergency thresholds. CIRO continues monitoring and keeps fallback mode ready.';
    }
    final warnings = bundle.warnings.isEmpty ? 'No service warnings.' : 'Service warnings: ${bundle.warnings.join("; ")}.';
    return 'Real Mode fused live location, weather, public/news, and route signals with ${confidence.toInt()}% confidence. $warnings Derived sensor/call signals are labeled and used only to complete operational simulation.';
  }

  static List<String> _resources(CrisisType type) => switch (type) {
        CrisisType.urbanFlooding => ['Drainage Pump DP-REAL', 'Rescue Unit RU-REAL', 'Traffic Unit TU-REAL'],
        CrisisType.heatwave => ['Medical Team MT-REAL', 'Water Tanker WT-REAL', 'Hospital Desk HD-REAL'],
        CrisisType.accident => ['Ambulance AMB-REAL', 'Traffic Patrol TP-REAL', 'Tow Truck TT-REAL'],
        CrisisType.powerOutage => ['Utility Crew UC-REAL', 'Generator GEN-REAL', 'Field Team FT-REAL'],
        CrisisType.roadBlockage => ['Traffic Patrol TP-REAL', 'Tow Truck TT-REAL'],
      };

  static String _resourceSummary(CrisisType type) => switch (type) {
        CrisisType.urbanFlooding => 'Drainage pump, rescue unit, and traffic diversion team',
        CrisisType.heatwave => 'Medical outreach team, water support, and hospital preparedness',
        CrisisType.accident => 'Ambulance, traffic patrol, and towing support',
        CrisisType.powerOutage => 'Utility repair crew, generator support, and field verification',
        CrisisType.roadBlockage => 'Traffic patrol and towing support',
      };

  static Map<String, String> _stakeholders(CrisisType type, String location, bool active, List<String> warnings) {
    if (!active) {
      return {
        'Public': 'No active crisis confirmed near $location. Continue normal movement and monitor CIRO updates.',
        'Command Center': 'Real Mode monitoring active. ${warnings.isEmpty ? "All available sources normal." : warnings.join("; ")}',
      };
    }
    return {
      'Public': '${_typeLabel(type)} risk near $location. Follow localized instructions and avoid affected corridors.',
      'Emergency Services': 'Dispatch and verify ${_typeLabel(type)} response near $location using live location evidence.',
      'Hospitals': 'Prepare capacity proportional to CIRO affected-population estimate near $location.',
      'Utilities': 'Review supporting infrastructure risks for ${_typeLabel(type)} near $location.',
      'Transport Authority': 'Use live route impact to stage rerouting and prevent congestion spillover.',
      'Command Center': 'Real Mode trace available. ${warnings.isEmpty ? "No degraded sources." : warnings.join("; ")}',
    };
  }

  static List<String> _tradeOffs(CrisisType type, List<String> warnings) => [
        'Resources are assigned from generic city baseline because private agency inventory is unavailable.',
        if (warnings.isNotEmpty) 'Confidence widened because ${warnings.length} live source warning(s) occurred.',
        if (type == CrisisType.urbanFlooding || type == CrisisType.roadBlockage)
          'Traffic relief is balanced against emergency access corridor protection.',
      ];

  static List<String> _sideEffects(CrisisType type, bool active) {
    if (!active) return const [];
    return switch (type) {
      CrisisType.urbanFlooding => ['Alternate routes may see temporary congestion increases.'],
      CrisisType.heatwave => ['Clinic surge prep may reduce non-urgent outpatient capacity.'],
      CrisisType.accident => ['Rerouting may slow adjacent arterial roads.'],
      CrisisType.powerOutage => ['Generator prioritization may leave lower-risk sites waiting.'],
      CrisisType.roadBlockage => ['Manual traffic control may delay public transport schedules.'],
    };
  }

  static String _typeLabel(CrisisType type) => switch (type) {
        CrisisType.urbanFlooding => 'Urban Flooding',
        CrisisType.roadBlockage => 'Road Blockage',
        CrisisType.accident => 'Accident',
        CrisisType.heatwave => 'Heatwave',
        CrisisType.powerOutage => 'Power Outage',
      };

  static String _severityLabel(SeverityLevel severity) => switch (severity) {
        SeverityLevel.critical => 'Critical',
        SeverityLevel.high => 'High',
        SeverityLevel.moderate => 'Moderate',
        SeverityLevel.low => 'Low',
        SeverityLevel.unknown => 'Unknown',
      };

  static String _duration(CrisisType type, SeverityLevel severity) {
    if (severity == SeverityLevel.low) return 'Monitoring';
    return switch (type) {
      CrisisType.urbanFlooding => '2-6 hours',
      CrisisType.heatwave => '1-3 days',
      CrisisType.accident => '30-90 min',
      CrisisType.powerOutage => '2-5 hours',
      CrisisType.roadBlockage => '45-120 min',
    };
  }

  static String _radius(CrisisType type, SeverityLevel severity) {
    final critical = severity == SeverityLevel.critical;
    return switch (type) {
      CrisisType.urbanFlooding => critical ? '2.5 km drainage basin' : '1.5 km local basin',
      CrisisType.heatwave => critical ? '5 km heat exposure zone' : '3 km heat exposure zone',
      CrisisType.accident => '1 km traffic impact zone',
      CrisisType.powerOutage => '2 km utility impact zone',
      CrisisType.roadBlockage => '1.8 km route impact zone',
    };
  }

  static String _peak(CrisisType type) => switch (type) {
        CrisisType.urbanFlooding => '30-90 min',
        CrisisType.heatwave => '12:00-16:00 local',
        CrisisType.accident => '15-30 min',
        CrisisType.powerOutage => '60-120 min',
        CrisisType.roadBlockage => '20-45 min',
      };

  static String _spreadRisk(CrisisType type) => switch (type) {
        CrisisType.urbanFlooding => 'High if rainfall continues or drains are blocked.',
        CrisisType.heatwave => 'High for outdoor workers, elderly people, and dense neighborhoods.',
        CrisisType.accident => 'Moderate secondary collision and congestion risk.',
        CrisisType.powerOutage => 'Moderate risk to clinics, signals, water pumps, and security.',
        CrisisType.roadBlockage => 'Moderate-to-high congestion spillover risk.',
      };

  static String _evolution(CrisisType type, SeverityLevel severity, String location) {
    if (severity == SeverityLevel.low) {
      return 'Live sources around $location remain normal. CIRO will escalate only if thresholds change.';
    }
    return '${_typeLabel(type)} near $location may peak within ${_peak(type)}. ${_spreadRisk(type)}';
  }
}

class _Classification {
  final CrisisType type;
  final SeverityLevel severity;
  final double confidence;

  const _Classification(this.type, this.severity, this.confidence);
}
