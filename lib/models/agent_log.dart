// CIRO — AgentLog Data Model
// Represents a single timestamped entry in the agent decision audit trail.
// All agent log entries must be routed through the Log Agent.

/// Which agent produced this log entry.
enum AgentType {
  signalAgent,
  fusionAgent,
  detectionAgent,
  severityAgent,
  resourceAgent,
  responsePlannerAgent,
  simulationAgent,
  verificationAgent,
  logAgent,
}

/// Log level / significance of the entry.
enum LogLevel { info, warning, error, success }

class AgentLog {
  final String id;
  final AgentType agent;
  final String summary;      // One-line human-readable summary
  final String detail;       // Longer explanation of the reasoning
  final LogLevel level;
  final DateTime timestamp;
  final Map<String, dynamic> output; // Structured output snapshot

  const AgentLog({
    required this.id,
    required this.agent,
    required this.summary,
    required this.detail,
    required this.level,
    required this.timestamp,
    this.output = const {},
  });

  /// Human-readable label for the agent type.
  String get agentLabel {
    switch (agent) {
      case AgentType.signalAgent:          return 'Signal Agent';
      case AgentType.fusionAgent:          return 'Fusion Agent';
      case AgentType.detectionAgent:       return 'Detection Agent';
      case AgentType.severityAgent:        return 'Severity Agent';
      case AgentType.resourceAgent:        return 'Resource Agent';
      case AgentType.responsePlannerAgent: return 'Response Planner Agent';
      case AgentType.simulationAgent:      return 'Simulation Agent';
      case AgentType.verificationAgent:    return 'Verification Agent';
      case AgentType.logAgent:             return 'Log Agent';
    }
  }
}
