// CIRO — PipelineResult Model
// The combined typed output of all 9 agents after processing a DemoScenario.

import 'demo_scenario.dart';
import 'crisis.dart';
import 'agent_log.dart';
import 'simulation_result.dart';

/// Resource allocation summary from the Resource Agent.
class ResourceAllocation {
  final List<String> units;
  final int unitCount;
  final String summary;

  const ResourceAllocation({
    required this.units,
    required this.unitCount,
    required this.summary,
  });
}

/// Verification decision from the Verification Agent.
class VerificationDecision {
  final VerificationType type;
  final String label;
  final String note;

  const VerificationDecision({
    required this.type,
    required this.label,
    required this.note,
  });
}

/// Full output of the multi-agent pipeline for one scenario.
class PipelineResult {
  final DemoScenario scenario;
  final Crisis crisis;
  final List<String> fusionPoints;        // Fusion Agent narrative bullets
  final ResourceAllocation resources;
  final List<PlanAction> responsePlan;
  final SimulationResult simulation;
  final VerificationDecision verification;
  final List<AgentLog> agentLogs;
  final DateTime generatedAt;

  const PipelineResult({
    required this.scenario,
    required this.crisis,
    required this.fusionPoints,
    required this.resources,
    required this.responsePlan,
    required this.simulation,
    required this.verification,
    required this.agentLogs,
    required this.generatedAt,
  });
}
