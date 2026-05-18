import 'package:flutter_test/flutter_test.dart';
import 'package:ciro/services/scenario_engine.dart';
import 'package:ciro/models/crisis.dart';

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
  });
}
