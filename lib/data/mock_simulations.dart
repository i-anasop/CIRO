// CIRO — Mock Simulation Results
// Before/after metrics for the primary demo scenario (CRS-2024-001: G-10 Flooding).
// Conforms to SimulationResult model in lib/models/simulation_result.dart.

import '../models/simulation_result.dart';

final Map<String, SimulationResult> mockSimulations = {
  'CRS-2024-001': SimulationResult(
    crisisId: 'CRS-2024-001',
    simulatedAt: DateTime(2024, 6, 15, 14, 23, 38),
    actions: [
      const SimulatedAction(
        id: 'ACT-001',
        title: 'Traffic Rerouting',
        description: 'Reroute G-10 Markaz traffic via I-8 alternate route. '
            'Dynamic signage activated at 3 key junctions.',
        status: 'Completed',
        resultSummary: 'Congestion reduced from 88% to 52%. '
            'Alternate route now handling 3,200 vehicles/hour.',
      ),
      const SimulatedAction(
        id: 'ACT-002',
        title: 'Rescue Team Dispatch',
        description: 'Deploy 2 rescue boats + 4 personnel from Rescue 1122 '
            'G-10 depot. ETA: 8 minutes.',
        status: 'In Progress',
        resultSummary: 'Team en route. Boats deployed from depot. '
            'Estimated on-scene arrival: 14:31 PKT.',
      ),
      const SimulatedAction(
        id: 'ACT-003',
        title: 'Public Alert Broadcast',
        description: 'Emergency alert sent to 4,800 registered G-10 residents '
            'via PSCA SMS and app notification.',
        status: 'Completed',
        resultSummary: '4,800 alerts delivered. Message: '
            '"FLOOD WARNING: Avoid G-10 Markaz. Use alternate routes. '
            'Do not drive through waterlogged roads."',
      ),
      const SimulatedAction(
        id: 'ACT-004',
        title: 'Emergency Ticket Created',
        description: 'Ticket CR-2024-0847 raised in NDMA portal. '
            'CDA Drainage department notified.',
        status: 'Completed',
        resultSummary: 'Ticket #CR-2024-0847 created. '
            'NDMA and CDA Drainage notified. '
            'Response team assignment: pending.',
      ),
      const SimulatedAction(
        id: 'ACT-005',
        title: 'ICITDMA Escalation',
        description: 'Islamabad Capital Territory Disaster Management Authority '
            'notified via automated system message.',
        status: 'Completed',
        resultSummary: 'ICITDMA duty officer notified at 14:23 PKT. '
            'Awaiting authority acknowledgment.',
      ),
    ],
    metrics: [
      const MetricSnapshot(
        label: 'Congestion %',
        before: '88%',
        after: '52%',
        delta: '▼ 36%',
        isImprovement: true,
      ),
      const MetricSnapshot(
        label: 'Response Time',
        before: '18 min',
        after: '7 min',
        delta: '▼ 11 min',
        isImprovement: true,
      ),
      const MetricSnapshot(
        label: 'Risk Level',
        before: 'Critical',
        after: 'Moderate',
        delta: '▼ Improving',
        isImprovement: true,
      ),
      const MetricSnapshot(
        label: 'Affected People',
        before: '3,200',
        after: '850',
        delta: '▼ 2,350',
        isImprovement: true,
      ),
      const MetricSnapshot(
        label: 'Resources Deployed',
        before: '0 units',
        after: '6 units',
        delta: '▲ 6',
        isImprovement: true,
      ),
      const MetricSnapshot(
        label: 'Alerts Sent',
        before: '0',
        after: '4,800',
        delta: '▲ 4,800',
        isImprovement: true,
      ),
    ],
  ),
};
