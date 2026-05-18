// CIRO — Mock Agent Logs
// Timestamped decision audit trail from all agents for the primary demo scenario.
// These entries map to the G-10 flooding scenario (CRS-2024-001).

import '../models/agent_log.dart';

final List<AgentLog> mockAgentLogs = [
  AgentLog(
    id: 'LOG-001',
    agent: AgentType.signalAgent,
    summary: '3 signals collected and normalized',
    detail:
        'Collected signals from 3 active sources: '
        '1 social post (Urdu language), 1 weather alert from PMD, '
        '1 traffic congestion report from CDA Traffic Management System. '
        'All signals normalized to standard Signal schema. '
        'Language detection applied — Urdu post transliterated for downstream processing.',
    level: LogLevel.success,
    timestamp: DateTime(2024, 6, 15, 14, 22, 10),
    output: {'signalCount': 3, 'sources': ['social', 'weather', 'traffic']},
  ),

  AgentLog(
    id: 'LOG-002',
    agent: AgentType.fusionAgent,
    summary: 'High-overlap event cluster detected in G-10',
    detail:
        'Signals fused using geo-temporal clustering. '
        'All three signals point to the same 0.8km² area in G-10 Markaz. '
        'Temporal offset: 7 minutes between earliest and latest signal. '
        'Conflict resolution: no conflicting signals detected. '
        'Noise filter applied — no low-confidence noise signals removed.',
    level: LogLevel.success,
    timestamp: DateTime(2024, 6, 15, 14, 22, 18),
    output: {'clusterConfidence': 0.89, 'signalOverlap': 'G-10 Markaz'},
  ),

  AgentLog(
    id: 'LOG-003',
    agent: AgentType.detectionAgent,
    summary: 'Crisis classified: Urban Flooding — G-10, Islamabad',
    detail:
        'Crisis type classification: Urban Flooding (confidence 91%). '
        'Location extracted: G-10 Markaz, Islamabad (33.6844°N, 73.0479°E). '
        'Estimated onset time: ~14:15 PKT based on earliest signal timestamp. '
        'Affected area radius: ~0.8 km from G-10 Markaz intersection. '
        'Key indicators: standing water keywords (Urdu: "pani bhar gaya"), '
        'stranded vehicles, red-category rainfall, severe congestion spike.',
    level: LogLevel.success,
    timestamp: DateTime(2024, 6, 15, 14, 22, 31),
    output: {
      'crisisType': 'Urban Flooding',
      'location': 'G-10, Islamabad',
      'confidence': 0.91,
    },
  ),

  AgentLog(
    id: 'LOG-004',
    agent: AgentType.severityAgent,
    summary: 'Severity: CRITICAL — 3,200+ people estimated affected',
    detail:
        'Severity scoring model applied. '
        'Factors: population density in G-10 (high residential), '
        'rainfall category (red — >75mm expected in 3 hours), '
        'road submersion confirmed, drainage failure likely. '
        'Estimated affected population: 3,200 (residents + commuters). '
        'Estimated duration: 4–6 hours without intervention. '
        'Likely escalation: risk of secondary accidents and health impact if unaddressed.',
    level: LogLevel.warning,
    timestamp: DateTime(2024, 6, 15, 14, 22, 44),
    output: {
      'severity': 'Critical',
      'affectedPeople': 3200,
      'durationEstimate': '4–6 hours',
    },
  ),

  AgentLog(
    id: 'LOG-005',
    agent: AgentType.resourceAgent,
    summary: '6 resources prioritized — 2 boats, 1 pump, 3 vehicles',
    detail:
        'Resource inventory checked. Active crises: 4. '
        'Resources available: 3 rescue boats (2 allocated), '
        '2 pumping units (1 allocated), 5 emergency vehicles (3 allocated). '
        'Priority logic: G-10 flooding assigned Critical priority — '
        'highest resource allocation tier. '
        'Remaining resources distributed across other active crises.',
    level: LogLevel.success,
    timestamp: DateTime(2024, 6, 15, 14, 22, 59),
    output: {
      'resourcesAllocated': 6,
      'breakdown': {'boats': 2, 'pumps': 1, 'vehicles': 3},
    },
  ),

  AgentLog(
    id: 'LOG-006',
    agent: AgentType.responsePlannerAgent,
    summary: '5-action response plan generated',
    detail:
        'Coordinated response plan generated with 5 sequenced actions. '
        'Action 1: Immediate traffic rerouting via I-8 alternate route. '
        'Action 2: Dispatch rescue team (ETA 8 minutes). '
        'Action 3: Broadcast public alert to 4,800 registered residents. '
        'Action 4: Create emergency ticket CR-2024-0847 for NDMA + CDA Drainage. '
        'Action 5: Notify ICITDMA — escalation to disaster management authority. '
        'Timeline: all actions to be initiated within 10 minutes of plan generation.',
    level: LogLevel.success,
    timestamp: DateTime(2024, 6, 15, 14, 23, 15),
    output: {'actionCount': 5, 'estimatedExecutionTime': '10 minutes'},
  ),

  AgentLog(
    id: 'LOG-007',
    agent: AgentType.simulationAgent,
    summary: 'All 5 actions simulated — congestion reduced by 36%',
    detail:
        'Simulation completed for all 5 response actions. '
        'Traffic model: rerouting reduced G-10 congestion from 88% to 52%. '
        'Rescue dispatch: ETA modeled at 8 minutes with current traffic conditions. '
        'Alert broadcast: 4,800 residents notified via PSCA emergency channel. '
        'Ticket created: CR-2024-0847 logged in NDMA portal. '
        'Escalation: ICITDMA notified by automated system message. '
        'Projected risk level after intervention: Critical → Moderate.',
    level: LogLevel.success,
    timestamp: DateTime(2024, 6, 15, 14, 23, 38),
    output: {
      'congestionBefore': '88%',
      'congestionAfter': '52%',
      'alertsSent': 4800,
    },
  ),

  AgentLog(
    id: 'LOG-008',
    agent: AgentType.verificationAgent,
    summary: '✅ Confirmed Crisis — no conflicting signals',
    detail:
        'All three signals are internally consistent in time, location, and type. '
        'No false positive indicators detected. '
        'Social language analysis confirms genuine distress report. '
        'Traffic data independently corroborates flooding. '
        'Verification state: Confirmed. No human escalation required at this stage. '
        'System continues to monitor for escalating or de-escalating signals.',
    level: LogLevel.success,
    timestamp: DateTime(2024, 6, 15, 14, 23, 50),
    output: {'verificationState': 'Confirmed', 'humanEscalationRequired': false},
  ),

  AgentLog(
    id: 'LOG-009',
    agent: AgentType.logAgent,
    summary: 'Full decision trace recorded — 9 entries',
    detail:
        'Agent pipeline execution complete. '
        'All 8 agent decisions captured and stored in audit trail. '
        'Crisis ID: CRS-2024-001. Pipeline duration: 100 seconds. '
        'System status: Response plan active, simulation complete, '
        'verification confirmed. Awaiting field team status update.',
    level: LogLevel.info,
    timestamp: DateTime(2024, 6, 15, 14, 24, 00),
    output: {'logEntries': 9, 'crisisId': 'CRS-2024-001'},
  ),
];
