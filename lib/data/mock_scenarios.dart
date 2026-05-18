// CIRO — Mock Demo Scenarios
// All 5 pre-built demo scenarios per AGENTS.md §14.
// Each scenario fully defines signals, response plan, and simulation metrics.
// Agent pipeline reads these and generates reasoning narratives from them.

import '../models/demo_scenario.dart';
import '../models/crisis.dart';
import '../models/signal.dart';

final List<DemoScenario> mockDemoScenarios = [

  // ── Scenario 1: Urban Flooding G-10 (PRIMARY DEMO) ─────────────────────
  const DemoScenario(
    id: 'SCN-001',
    title: 'Urban Flooding — G-10, Islamabad',
    crisisType: CrisisType.urbanFlooding,
    location: 'G-10, Islamabad',
    coordinates: '33.6946°N, 73.0179°E',
    severity: SeverityLevel.critical,
    confidence: 91,
    status: CrisisStatus.active,
    affectedPopulation: 3200,
    expectedDuration: '4–6 hours',
    likelyEvolution:
        'Without intervention: secondary accidents, residential flooding, '
        'and public health risks expected within 2 hours. '
        'Drainage failure will worsen if rainfall continues.',
    mapZoneLabel: 'G-10 — Islamabad',
    resourceSummary: '2 rescue boats, 1 pumping unit, 3 emergency vehicles, 8 personnel',
    resourceUnits: [
      'Rescue Boat RB-04',
      'Rescue Boat RB-07',
      'Pumping Unit PU-02',
      'Ambulance AMB-12',
      'Emergency Vehicle EV-06',
      'Emergency Vehicle EV-09',
    ],
    socialSignal: SignalInput(
      source: SignalSource.socialPost,
      content: '"G-10 mein pani bhar gaya hai, gaariyan phans gayi hain" '
          '— @citizen_isb · 14:15 PKT · 47 engagements',
      confidence: 0.78,
    ),
    weatherSignal: SignalInput(
      source: SignalSource.weatherAlert,
      content: 'Heavy Rainfall Alert — Islamabad — RED Category — '
          'Expected >75mm in 3 hours — Issued by PMD at 14:32 PKT',
      confidence: 0.97,
    ),
    trafficSignal: SignalInput(
      source: SignalSource.trafficData,
      content: 'G-10 Markaz: 85% congestion spike — '
          'Multiple routes blocked since 14:18 PKT',
      confidence: 0.91,
    ),
    extraSignals: [
      SignalInput(
        source: SignalSource.mockSensor,
        content: 'Water level sensor G10-WL-03: +42cm above normal baseline',
        confidence: 0.95,
      ),
    ],
    verificationType: VerificationType.confirmed,
    verificationNote:
        '3 independent sources corroborate: social reports match weather '
        'advisory and traffic congestion data. Sensor confirms water rise. '
        'Confidence threshold exceeded. Proceeding with full response.',
    responseActions: [
      PlanAction(
        step: 1,
        title: 'Reroute Traffic via I-8 Alternate',
        description: 'Activate alternate routing from G-10 Markaz to I-8 via '
            'Margalla Road. Deploy traffic wardens at 3 diversion points.',
        department: 'Traffic Management · CDA Islamabad',
        priority: 'P1',
        eta: '2 min',
        status: 'Completed',
        resultSummary: 'Route activated. Congestion reduced from 85% to 52%.',
      ),
      PlanAction(
        step: 2,
        title: 'Dispatch Rescue Team to G-10',
        description: 'Deploy 2 rescue boats and 8 personnel from 1122 G-10 depot. '
            'Priority: stranded residents and vehicle rescue.',
        department: 'Rescue 1122 · G-10 Depot',
        priority: 'P1',
        eta: '8 min',
        status: 'In Progress',
        resultSummary: 'RB-04 and RB-07 en route. ETA: 8 minutes.',
      ),
      PlanAction(
        step: 3,
        title: 'Broadcast Public Alert to 4,800 Residents',
        description: 'Send emergency SMS and app notification to registered '
            'residents in G-10 sector advising route avoidance and safety.',
        department: 'PSCA Emergency Broadcast · ICT',
        priority: 'P2',
        eta: '5 min',
        status: 'Completed',
        resultSummary: '4,800 alerts sent. Acknowledged by 1,243 recipients.',
      ),
      PlanAction(
        step: 4,
        title: 'Create Emergency Ticket #CR-2024-0847',
        description: 'Raise formal escalation to NDMA and CDA Drainage Division '
            'for immediate drain clearance and pumping deployment.',
        department: 'NDMA · CDA Drainage Division',
        priority: 'P2',
        eta: '3 min',
        status: 'Completed',
        resultSummary: 'Ticket #CR-2024-0847 raised. CDA team dispatched.',
      ),
      PlanAction(
        step: 5,
        title: 'Notify ICITDMA Emergency Operations',
        description: 'Alert the Islamabad Capital Territory Disaster Management '
            'Authority to stand by for escalation if water levels rise further.',
        department: 'ICITDMA · Federal EOC',
        priority: 'P3',
        eta: '10 min',
        status: 'Completed',
        resultSummary: 'ICITDMA notified. Standby protocol activated.',
      ),
    ],
    simulationMetrics: [
      MetricPair(label: 'Congestion %',       before: '88%',       after: '52%',     delta: '▼ 36%',    isImprovement: true),
      MetricPair(label: 'Response Time',       before: '18 min',    after: '7 min',   delta: '▼ 11 min', isImprovement: true),
      MetricPair(label: 'Risk Level',          before: 'Critical',  after: 'Moderate',delta: '▼ -2',     isImprovement: true),
      MetricPair(label: 'Affected People',     before: '3,200',     after: '850',     delta: '▼ 2,350',  isImprovement: true),
      MetricPair(label: 'Resources Deployed',  before: '0 units',   after: '6 units', delta: '▲ +6',     isImprovement: true),
      MetricPair(label: 'Alerts Sent',         before: '0',         after: '4,800',   delta: '▲ 4,800',  isImprovement: true),
    ],
    possibleSideEffects: [
      'I-8 alternate route may face increased load (+15% congestion)',
      'Rescue boats may face reduced visibility in flooded lanes',
    ],
  ),

  // ── Scenario 2: Road Accident — Faizabad, Rawalpindi ───────────────────
  const DemoScenario(
    id: 'SCN-002',
    title: 'Road Accident — Faizabad, Rawalpindi',
    crisisType: CrisisType.accident,
    location: 'Faizabad Interchange, Rawalpindi',
    coordinates: '33.7215°N, 73.0722°E',
    severity: SeverityLevel.high,
    confidence: 86,
    status: CrisisStatus.active,
    affectedPopulation: 1800,
    expectedDuration: '1–3 hours',
    likelyEvolution:
        'Multi-vehicle collision causing lane blockage. Secondary '
        'accidents risk if not cleared within 30 min. '
        'Casualties require immediate medical dispatch.',
    mapZoneLabel: 'Faizabad — Rawalpindi',
    resourceSummary: '2 ambulances, 2 emergency vehicles, police support, 6 personnel',
    resourceUnits: [
      'Ambulance AMB-05',
      'Ambulance AMB-11',
      'Police Mobile PM-03',
      'Emergency Vehicle EV-02',
    ],
    socialSignal: SignalInput(
      source: SignalSource.socialPost,
      content: '"Faizabad ke paas accident hua hai, traffic ruk gayi hai, '
          'kuch log zakhmi bhi hain" — @rwp_citizen · 09:42 PKT',
      confidence: 0.82,
    ),
    weatherSignal: SignalInput(
      source: SignalSource.weatherAlert,
      content: 'Weather: Clear — No adverse conditions — Visibility normal',
      confidence: 0.99,
      isActive: false,
    ),
    trafficSignal: SignalInput(
      source: SignalSource.trafficData,
      content: 'Faizabad Interchange: 78% congestion — Full lane blockage '
          'on Murree Road side — Abnormal since 09:38 PKT',
      confidence: 0.88,
    ),
    verificationType: VerificationType.confirmed,
    verificationNote:
        'Social report corroborated by traffic data. Weather is clear, '
        'ruling out weather-related cause. High-confidence accident detection. '
        'Casualty reports require immediate medical response.',
    responseActions: [
      PlanAction(
        step: 1,
        title: 'Dispatch Ambulances to Faizabad Interchange',
        description: 'Deploy 2 ambulances from Benazir Bhutto Hospital. '
            'Priority: casualty triage and stabilization.',
        department: 'Rescue 1122 · Rawalpindi',
        priority: 'P1',
        eta: '6 min',
        status: 'In Progress',
        resultSummary: 'AMB-05 and AMB-11 dispatched. ETA 6 minutes.',
      ),
      PlanAction(
        step: 2,
        title: 'Reroute Traffic via Peshawar Road',
        description: 'Divert traffic from Faizabad to Peshawar Road alternate. '
            'Deploy traffic police for manual management.',
        department: 'Rawalpindi Traffic Police',
        priority: 'P1',
        eta: '4 min',
        status: 'Completed',
        resultSummary: 'Diversion active. Congestion down to 41%.',
      ),
      PlanAction(
        step: 3,
        title: 'Broadcast Alert to Commuters',
        description: 'Notify commuters approaching Faizabad about accident '
            'and alternate route via SMS and traffic radio.',
        department: 'PSCA · Punjab Safe Cities Authority',
        priority: 'P2',
        eta: '3 min',
        status: 'Completed',
        resultSummary: '2,100 alerts sent via SMS and radio broadcast.',
      ),
      PlanAction(
        step: 4,
        title: 'Create Emergency Ticket #CR-2024-0848',
        description: 'Log accident to Rawalpindi Emergency Operations Center '
            'for towing and road clearance.',
        department: 'Rawalpindi Emergency OC',
        priority: 'P2',
        eta: '2 min',
        status: 'Completed',
        resultSummary: 'Ticket raised. Towing unit TW-07 dispatched.',
      ),
    ],
    simulationMetrics: [
      MetricPair(label: 'Congestion %',      before: '78%',   after: '41%',     delta: '▼ 37%',   isImprovement: true),
      MetricPair(label: 'Response Time',      before: '14 min', after: '6 min',  delta: '▼ 8 min', isImprovement: true),
      MetricPair(label: 'Risk Level',         before: 'High',  after: 'Low',     delta: '▼ -2',    isImprovement: true),
      MetricPair(label: 'Affected People',    before: '1,800', after: '350',     delta: '▼ 1,450', isImprovement: true),
      MetricPair(label: 'Medical Units',      before: '0',     after: '2 units', delta: '▲ +2',    isImprovement: true),
      MetricPair(label: 'Alerts Sent',        before: '0',     after: '2,100',   delta: '▲ 2,100', isImprovement: true),
    ],
  ),

  // ── Scenario 3: Heatwave — Saddar, Rawalpindi ───────────────────────────
  const DemoScenario(
    id: 'SCN-003',
    title: 'Heatwave Advisory — Saddar, Rawalpindi',
    crisisType: CrisisType.heatwave,
    location: 'Saddar, Rawalpindi',
    coordinates: '33.5996°N, 73.0479°E',
    severity: SeverityLevel.high,
    confidence: 82,
    status: CrisisStatus.active,
    affectedPopulation: 5500,
    expectedDuration: '2–4 days',
    likelyEvolution:
        'Extreme heat advisory at 47°C. Risk of mass heat stroke, '
        'hospital surge, and outdoor worker fatalities. '
        'Urban heat island effect amplifies risk in dense Saddar areas.',
    mapZoneLabel: 'Saddar — Rawalpindi',
    resourceSummary: '3 medical teams, 5 water stations, 2 hospitals on standby',
    resourceUnits: [
      'Medical Team MT-01',
      'Medical Team MT-02',
      'Water Station WS-04',
      'Water Station WS-07',
      'Benazir Bhutto Hospital — Trauma Wing',
    ],
    socialSignal: SignalInput(
      source: SignalSource.socialPost,
      content: '"Bohat zyada garmi hai, log behosh ho rahe hain Saddar mein, '
          'kuch logon ko hospital ley gaye" — @saddar_news · 13:05 PKT',
      confidence: 0.80,
    ),
    weatherSignal: SignalInput(
      source: SignalSource.weatherAlert,
      content: 'Extreme Heat Advisory — Rawalpindi — Temp: 47°C — '
          'Heat index: 52°C — NDMA advisory level RED — Issued 12:00 PKT',
      confidence: 0.97,
    ),
    trafficSignal: SignalInput(
      source: SignalSource.trafficData,
      content: 'Traffic: Normal — No congestion anomalies detected',
      confidence: 0.70,
      isActive: false,
    ),
    extraSignals: [
      SignalInput(
        source: SignalSource.mockSensor,
        content: 'Temp sensor SADDAR-T-02: 47.3°C — above 45°C threshold since 11:30 PKT',
        confidence: 0.99,
      ),
    ],
    verificationType: VerificationType.confirmed,
    verificationNote:
        'Weather advisory and sensor data both confirm extreme heat. '
        'Social reports of casualties match expected heatwave impact. '
        'Traffic is unaffected — crisis is health-only. Full response warranted.',
    responseActions: [
      PlanAction(
        step: 1,
        title: 'Set Up 5 Emergency Water/Cooling Stations',
        description: 'Deploy water distribution and cooling stations at '
            'Saddar market, Committee Chowk, and main bus terminal.',
        department: 'WASA · Rawalpindi Metropolitan',
        priority: 'P1',
        eta: '15 min',
        status: 'In Progress',
        resultSummary: '3 of 5 stations deployed. 2 en route.',
      ),
      PlanAction(
        step: 2,
        title: 'Alert Hospitals for Heat Stroke Surge',
        description: 'Notify Benazir Bhutto Hospital and Holy Family Hospital '
            'to activate surge protocol and allocate heat-stroke beds.',
        department: 'Health Department · Punjab',
        priority: 'P1',
        eta: '5 min',
        status: 'Completed',
        resultSummary: '24 beds allocated. Trauma teams on standby.',
      ),
      PlanAction(
        step: 3,
        title: 'Broadcast Heat Advisory to Residents',
        description: 'Issue emergency health advisory: avoid outdoor activity, '
            'hydration guidelines, emergency helpline 1122.',
        department: 'PSCA · Emergency Broadcast',
        priority: 'P2',
        eta: '5 min',
        status: 'Completed',
        resultSummary: '5,500 alerts sent. Health advisory broadcast on FM.',
      ),
      PlanAction(
        step: 4,
        title: 'Deploy Mobile Medical Teams',
        description: 'Dispatch 3 mobile medical teams for outdoor heat stroke '
            'case identification and treatment.',
        department: 'Rescue 1122 · Rawalpindi',
        priority: 'P2',
        eta: '20 min',
        status: 'Pending',
        resultSummary: null,
      ),
    ],
    simulationMetrics: [
      MetricPair(label: 'At-Risk Population',  before: '5,500',  after: '1,200',   delta: '▼ 4,300',    isImprovement: true),
      MetricPair(label: 'Hospital Capacity',    before: '0 beds', after: '24 beds', delta: '▲ +24',      isImprovement: true),
      MetricPair(label: 'Water Access',         before: '0 pts',  after: '5 pts',   delta: '▲ +5',       isImprovement: true),
      MetricPair(label: 'Risk Level',           before: 'High',   after: 'Moderate',delta: '▼ -1',       isImprovement: true),
      MetricPair(label: 'Medical Units',        before: '0',      after: '3 teams', delta: '▲ +3',       isImprovement: true),
      MetricPair(label: 'Alerts Sent',          before: '0',      after: '5,500',   delta: '▲ 5,500',    isImprovement: true),
    ],
    possibleSideEffects: [
      'Hospital surge may impact non-emergency care availability',
      'Water station deployment may require road closures in busy zones',
    ],
  ),

  // ── Scenario 4: Power Outage — I-8, Islamabad ──────────────────────────
  const DemoScenario(
    id: 'SCN-004',
    title: 'Power Outage — I-8 Industrial Zone, Islamabad',
    crisisType: CrisisType.powerOutage,
    location: 'I-8, Islamabad',
    coordinates: '33.6772°N, 73.0629°E',
    severity: SeverityLevel.moderate,
    confidence: 76,
    status: CrisisStatus.active,
    affectedPopulation: 2100,
    expectedDuration: '2–5 hours',
    likelyEvolution:
        'Feeder 14B failure affecting I-8 industrial and residential sectors. '
        'Risk of medical equipment failure, food spoilage, and '
        'security system outages if not restored within 3 hours.',
    mapZoneLabel: 'I-8 — Islamabad',
    resourceSummary: 'IESCO repair team, generator backup unit, 4 technicians',
    resourceUnits: [
      'IESCO Repair Team RT-04',
      'Generator Unit GEN-02',
      'NDMA Utility Coordinator',
    ],
    socialSignal: SignalInput(
      source: SignalSource.socialPost,
      content: '"I-8 mein 3 ghante se bijli nahi hai, IESCO se koi response '
          'nahi" — @isb_residents · 12:45 PKT',
      confidence: 0.71,
    ),
    weatherSignal: SignalInput(
      source: SignalSource.weatherAlert,
      content: 'Weather: Clear — No storm or weather-related cause detected',
      confidence: 0.95,
      isActive: false,
    ),
    trafficSignal: SignalInput(
      source: SignalSource.trafficData,
      content: 'Traffic: Normal — No congestion linked to outage',
      confidence: 0.80,
      isActive: false,
    ),
    extraSignals: [
      SignalInput(
        source: SignalSource.mockSensor,
        content: 'WAPDA Feeder 14B — Voltage: 0V — Duration: 3h 15min — '
            'Sector: I-8/1 through I-8/4',
        confidence: 0.99,
      ),
    ],
    verificationType: VerificationType.needsVerification,
    verificationNote:
        'Single social source detected. Sensor data confirms outage but '
        'cause is unclear (weather ruled out). Flagging for human verification '
        'before escalating to full emergency response. '
        'IoT sensor is primary evidence.',
    responseActions: [
      PlanAction(
        step: 1,
        title: 'Escalate to IESCO Emergency Team',
        description: 'Contact IESCO operations center for Feeder 14B fault '
            'diagnosis and immediate repair team dispatch.',
        department: 'IESCO · Islamabad Grid Operations',
        priority: 'P1',
        eta: '10 min',
        status: 'In Progress',
        resultSummary: 'IESCO RT-04 dispatched to substation.',
      ),
      PlanAction(
        step: 2,
        title: 'Deploy Backup Generator to Critical Sites',
        description: 'Deliver generator to I-8 Medical Center and '
            'key infrastructure nodes to prevent secondary impacts.',
        department: 'NDMA · Emergency Equipment',
        priority: 'P1',
        eta: '20 min',
        status: 'Pending',
        resultSummary: null,
      ),
      PlanAction(
        step: 3,
        title: 'Send Outage Alert to I-8 Residents',
        description: 'Notify residents of outage, estimated restoration time '
            '(2–5 hours), and safety precautions.',
        department: 'IESCO Customer Services · ICT',
        priority: 'P2',
        eta: '5 min',
        status: 'Completed',
        resultSummary: '2,100 residents notified. ETA communicated as 2–5 hours.',
      ),
      PlanAction(
        step: 4,
        title: 'Create Utility Escalation Ticket #CR-2024-0849',
        description: 'Log formal escalation for NEPRA monitoring and '
            'NDMA infrastructure coordination.',
        department: 'NEPRA · Utility Oversight',
        priority: 'P3',
        eta: '5 min',
        status: 'Completed',
        resultSummary: 'Ticket raised. NEPRA monitoring log updated.',
      ),
    ],
    simulationMetrics: [
      MetricPair(label: 'Power Restored',       before: '0%',      after: '60%',     delta: '▲ +60%',  isImprovement: true),
      MetricPair(label: 'Response Time',         before: 'Unknown', after: '20 min',  delta: '▼ -',     isImprovement: true),
      MetricPair(label: 'Risk Level',            before: 'Moderate',after: 'Low',     delta: '▼ -1',    isImprovement: true),
      MetricPair(label: 'Affected Population',   before: '2,100',   after: '400',     delta: '▼ 1,700', isImprovement: true),
      MetricPair(label: 'Backup Power Sites',    before: '0',       after: '2 sites', delta: '▲ +2',    isImprovement: true),
      MetricPair(label: 'Alerts Sent',           before: '0',       after: '2,100',   delta: '▲ 2,100', isImprovement: true),
    ],
  ),

  // ── Scenario 5: Road Blockage — Blue Area, Islamabad ───────────────────
  const DemoScenario(
    id: 'SCN-005',
    title: 'Road Blockage — Blue Area, Islamabad',
    crisisType: CrisisType.roadBlockage,
    location: 'Blue Area, Islamabad',
    coordinates: '33.7289°N, 73.0933°E',
    severity: SeverityLevel.high,
    confidence: 88,
    status: CrisisStatus.active,
    affectedPopulation: 2800,
    expectedDuration: '1–2 hours',
    likelyEvolution:
        'Major road blockage on Jinnah Avenue causing cascade congestion '
        'across adjacent commercial zones. Government offices affected. '
        'High commuter impact if not cleared within 45 minutes.',
    mapZoneLabel: 'Blue Area — Islamabad',
    resourceSummary: '4 traffic wardens, 1 towing unit, 2 police mobiles',
    resourceUnits: [
      'Traffic Warden TW-01',
      'Traffic Warden TW-02',
      'Police Mobile PM-05',
      'Towing Unit TW-09',
    ],
    socialSignal: SignalInput(
      source: SignalSource.socialPost,
      content: '"Blue Area road blocked hai, bari gariyan phansi hui hain '
          'Jinnah Avenue par, office jaane wale pareshan" — @isb_traffic · 08:55 PKT',
      confidence: 0.85,
    ),
    weatherSignal: SignalInput(
      source: SignalSource.weatherAlert,
      content: 'Weather: Partly cloudy — No adverse weather conditions',
      confidence: 0.95,
      isActive: false,
    ),
    trafficSignal: SignalInput(
      source: SignalSource.trafficData,
      content: 'Blue Area — Jinnah Avenue: 88% congestion spike — '
          'Standstill on both lanes — Abnormal since 08:50 PKT',
      confidence: 0.93,
    ),
    verificationType: VerificationType.confirmed,
    verificationNote:
        'Social report and traffic data strongly corroborate. '
        'Weather is clear, so blockage is non-weather-related. '
        'High-confidence road blockage classification. '
        'Commercial zone priority warrants immediate response.',
    responseActions: [
      PlanAction(
        step: 1,
        title: 'Deploy Traffic Wardens to Jinnah Avenue',
        description: 'Dispatch 4 traffic wardens to Blue Area to manually '
            'manage congestion and identify blockage cause.',
        department: 'Islamabad Traffic Police',
        priority: 'P1',
        eta: '5 min',
        status: 'Completed',
        resultSummary: 'Wardens deployed. Blockage identified as overturned truck.',
      ),
      PlanAction(
        step: 2,
        title: 'Dispatch Towing Unit for Blocked Vehicle',
        description: 'Remove blocking heavy vehicle from Jinnah Avenue using '
            'towing unit TW-09 from F-8 depot.',
        department: 'CDA Road Operations',
        priority: 'P1',
        eta: '12 min',
        status: 'In Progress',
        resultSummary: 'TW-09 en route. ETA 12 minutes.',
      ),
      PlanAction(
        step: 3,
        title: 'Activate Alternate Route via Khayaban-e-Suharwardy',
        description: 'Redirect Blue Area-bound traffic via alternate commercial '
            'corridor to reduce Jinnah Avenue load.',
        department: 'CDA Traffic Management',
        priority: 'P2',
        eta: '3 min',
        status: 'Completed',
        resultSummary: 'Route active. 40% of traffic diverted successfully.',
      ),
      PlanAction(
        step: 4,
        title: 'Broadcast Commuter Alert',
        description: 'Issue traffic alert to commuters heading to Blue Area '
            'via PSCA systems, radio, and traffic app.',
        department: 'PSCA · ICT Emergency',
        priority: 'P2',
        eta: '3 min',
        status: 'Completed',
        resultSummary: '2,800 alerts sent. Route advisory active.',
      ),
    ],
    simulationMetrics: [
      MetricPair(label: 'Congestion %',      before: '88%',   after: '34%',     delta: '▼ 54%',   isImprovement: true),
      MetricPair(label: 'Response Time',      before: '22 min',after: '5 min',   delta: '▼ 17 min',isImprovement: true),
      MetricPair(label: 'Risk Level',         before: 'High',  after: 'Low',     delta: '▼ -2',    isImprovement: true),
      MetricPair(label: 'Affected People',    before: '2,800', after: '420',     delta: '▼ 2,380', isImprovement: true),
      MetricPair(label: 'Units Deployed',     before: '0',     after: '4 units', delta: '▲ +4',    isImprovement: true),
      MetricPair(label: 'Alerts Sent',        before: '0',     after: '2,800',   delta: '▲ 2,800', isImprovement: true),
    ],
    possibleSideEffects: [
      'Khayaban-e-Suharwardy may see 20% congestion increase during diversion',
    ],
  ),
];

/// Convenience getter by ID.
DemoScenario scenarioById(String id) =>
    mockDemoScenarios.firstWhere((s) => s.id == id);
