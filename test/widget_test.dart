import 'package:flutter_test/flutter_test.dart';
import 'package:ciro/services/scenario_engine.dart';
import 'package:ciro/services/real_scenario_adapter.dart';
import 'package:ciro/services/real_signal_service.dart';
import 'package:ciro/models/crisis.dart';
import 'package:ciro/models/demo_scenario.dart';
import 'package:ciro/models/location_result.dart';
import 'package:ciro/models/news_signal.dart';
import 'package:ciro/models/route_result.dart';
import 'package:ciro/models/weather_result.dart';

void main() {
  group('CIRO Core Pipeline and State Tests', () {
    test('ScenarioEngine initial state and default flooding scenario test', () {
      final engine = ScenarioEngine.instance;
      engine.initialize();

      expect(engine.activeScenarioId, 'SCN-001');
      expect(engine.activeScenario.title, contains('Flooding'));
      expect(engine.activeCrisis.type, CrisisType.urbanFlooding);
      expect(engine.agentLogs.isNotEmpty, true);
    });

    test('ScenarioEngine selectScenario SCN-002 accident scenario test', () async {
      final engine = ScenarioEngine.instance;
      engine.initialize();

      await engine.selectScenario('SCN-002');
      expect(engine.activeScenarioId, 'SCN-002');
      expect(engine.activeCrisis.type, CrisisType.accident);
    });

    test('all five verification states are demonstrable', () async {
      final engine = ScenarioEngine.instance;
      engine.initialize();

      final states = engine.allScenarios.map((s) => s.verificationType).toSet();
      expect(states.contains(VerificationType.confirmed), true);
      expect(states.contains(VerificationType.needsVerification), true);
      expect(states.contains(VerificationType.conflictingSignals), true);
      expect(states.contains(VerificationType.falsePositiveRisk), true);
      expect(states.contains(VerificationType.escalationRequired), true);
    });

    test('multi-crisis scenario produces coordination and resource trade-offs', () async {
      final engine = ScenarioEngine.instance;
      engine.initialize();

      await engine.selectScenario('SCN-006');
      expect(engine.currentResult.coordination.isActive, true);
      expect(engine.currentResult.coordination.relatedIncidents.length, 1);
      expect(engine.currentResult.resourceDecisions.isNotEmpty, true);
      expect(engine.currentResult.coordination.tradeOffs.isNotEmpty, true);
    });

    test('Antigravity trace export is generated for active scenario', () async {
      final engine = ScenarioEngine.instance;
      engine.initialize();

      await engine.selectScenario('SCN-008');
      expect(engine.antigravityTrace.length, greaterThanOrEqualTo(6));
      expect(engine.currentResult.antigravityTraceExport, contains('Verification Agent'));
      expect(engine.currentResult.antigravityTraceExport, contains('False Positive'));
    });

    test('degraded monitoring baseline preserves fallback mode', () {
      final engine = ScenarioEngine.instance;
      engine.initialize();

      engine.resetRealAnalysis();
      expect(engine.activeScenarioId, 'SCN-REAL');
      expect(engine.currentResult.evolution.spreadRisk, contains('No spread'));
      expect(engine.currentResult.antigravityTraceExport, contains('fallback'));
    });

    test('real adapter converts live-like local bundle into full crisis scenario', () {
      final scenario = RealScenarioAdapter.fromBundle(
        RealSignalBundle(
          location: const LocationResult(
            latitude: 33.6844,
            longitude: 73.0479,
            area: 'F-8',
            city: 'Islamabad',
            country: 'Pakistan',
          ),
          weather: const WeatherResult(
            temperature: 28,
            feelsLike: 30,
            humidity: 78,
            condition: 'Rain',
            description: 'heavy intensity rain',
            rainfallLastHour: 18,
            alertLevel: WeatherRisk.floodRisk,
            rawSummary: 'Heavy rain',
          ),
          traffic: const RouteResult(
            normalDurationMinutes: 10,
            trafficDurationMinutes: 21,
            distanceKm: 3.2,
            congestionLevel: CongestionLevel.high,
            routeSummary: 'Local route',
          ),
          newsSignals: [
            NewsSignal(
              title: 'Flooding reported near F-8 underpass',
              description: 'Heavy rain is causing waterlogging and traffic delays.',
              source: 'Local Desk',
              url: 'https://example.com',
              matchedKeyword: 'flood',
              confidenceHint: 0.86,
            ),
          ],
          succeeded: true,
        ),
      );

      expect(scenario.id, 'SCN-REAL');
      expect(scenario.location, 'F-8, Islamabad');
      expect(scenario.crisisType, CrisisType.urbanFlooding);
      expect(scenario.activeSignals.length, greaterThanOrEqualTo(4));
      expect(scenario.responseActions.isNotEmpty, true);
      expect(scenario.orchestration.fallbackMode, contains('Real Mode'));
    });
  });
}
