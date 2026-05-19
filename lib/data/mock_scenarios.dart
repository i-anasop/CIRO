// CIRO — Mock Demo Scenarios
// All 5 pre-built demo scenarios per AGENTS.md §14.
// Each scenario fully defines signals, response plan, and simulation metrics.
// Agent pipeline reads these and generates reasoning narratives from them.

import '../models/demo_scenario.dart';
import '../models/crisis.dart';
import '../models/signal.dart';
import '../models/orchestration_models.dart';

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

  // ── Scenario 3: Torrential Rain — Saddar, Rawalpindi ─────────────────────
  const DemoScenario(
    id: 'SCN-003',
    title: 'Torrential Rain & Canal Inundation — Saddar, Rawalpindi',
    crisisType: CrisisType.urbanFlooding,
    location: 'Saddar, Rawalpindi',
    coordinates: '33.5996°N, 73.0479°E',
    severity: SeverityLevel.high,
    confidence: 82,
    status: CrisisStatus.active,
    affectedPopulation: 5500,
    expectedDuration: '4–8 hours',
    likelyEvolution:
        'Torrential rain causing Leh Nullah canal overflow. Risk of low-lying area '
        'inundation, power failures, and commercial damage in Saddar markets.',
    mapZoneLabel: 'Saddar — Rawalpindi',
    resourceSummary: '2 rescue teams, 4 dewatering pumps, 3 traffic units standby',
    resourceUnits: [
      'Rescue Team RT-01',
      'Rescue Team RT-02',
      'Dewatering Pump DP-04',
      'Dewatering Pump DP-07',
      'Rawalpindi Drainage Coordinator',
    ],
    socialSignal: SignalInput(
      source: SignalSource.socialPost,
      content: '"Bohat zyada tez baarish ho rahi hai Saddar mein, Leh Nullah ka '
          'pani road par aa gaya hai" — @saddar_news · 13:05 PKT',
      confidence: 0.80,
    ),
    weatherSignal: SignalInput(
      source: SignalSource.weatherAlert,
      content: 'Torrential Rainfall Advisory — Rawalpindi — Temp: 22°C — '
          'Cumulative rain: 85mm — PMD alert level RED — Issued 12:00 PKT',
      confidence: 0.97,
    ),
    trafficSignal: SignalInput(
      source: SignalSource.trafficData,
      content: 'Traffic: Standstill at Committee Chowk and Murree Road detour lanes',
      confidence: 0.88,
    ),
    extraSignals: [
      SignalInput(
        source: SignalSource.mockSensor,
        content: 'Nullah Leh sensor SADDAR-WL-02: +1.8m above warning line since 11:30 PKT',
        confidence: 0.99,
      ),
    ],
    verificationType: VerificationType.confirmed,
    verificationNote:
        'PMD weather radar and Nullah Leh sensors confirm critical canal overflow. '
        'Social reports corroborate extensive street flooding. Full emergency '
        'evacuation and drainage response initiated.',
    responseActions: [
      PlanAction(
        step: 1,
        title: 'Deploy Dewatering Pumps to Saddar Markets',
        description: 'Deploy WASA water extraction pumps to Saddar commercial centers, '
            'Committee Chowk, and low-lying transit junctions.',
        department: 'WASA · Rawalpindi Metropolitan',
        priority: 'P1',
        eta: '15 min',
        status: 'In Progress',
        resultSummary: '3 of 4 pumps active. Restricting canal return backflow.',
      ),
      PlanAction(
        step: 2,
        title: 'Alert Saddar Low-Lying Sectors to Evacuate',
        description: 'Establish evacuation pathways and temporary holding camps '
            'at higher elevation spots.',
        department: 'Civil Defense · Rawalpindi',
        priority: 'P1',
        eta: '5 min',
        status: 'Completed',
        resultSummary: '450 families evacuated to secure community centers.',
      ),
      PlanAction(
        step: 3,
        title: 'Broadcast Localized Canal Flood Alert',
        description: 'Issue emergency safety warnings advising immediate second-floor '
            'relocation, electricity shutoffs, and coordinate with 1122.',
        department: 'PSCA · Emergency Broadcast',
        priority: 'P2',
        eta: '5 min',
        status: 'Completed',
        resultSummary: '5,500 alerts broadcasted. Canal evacuation signs active.',
      ),
      PlanAction(
        step: 4,
        title: 'Dispatch Rescue Boats for Stranded Residents',
        description: 'Mobilize 2 rescue teams and 6 personnel to evacuate stranded '
            'shopkeepers and shoppers from submersed markets.',
        department: 'Rescue 1122 · Saddar Station',
        priority: 'P2',
        eta: '20 min',
        status: 'Pending',
        resultSummary: null,
      ),
    ],
    simulationMetrics: [
      MetricPair(label: 'At-Risk Population',  before: '5,500',  after: '1,200',   delta: '▼ 4,300',    isImprovement: true),
      MetricPair(label: 'Evacuated Families',  before: '0 families', after: '450 families', delta: '▲ +450', isImprovement: true),
      MetricPair(label: 'Dewatered Volume',    before: '0 L/m',  after: '6,000 L/m', delta: '▲ +6k',     isImprovement: true),
      MetricPair(label: 'Risk Level',           before: 'Critical', after: 'Moderate',delta: '▼ -2',     isImprovement: true),
      MetricPair(label: 'Rescue Teams',        before: '0',      after: '2 teams', delta: '▲ +2',       isImprovement: true),
      MetricPair(label: 'Alerts Sent',          before: '0',      after: '5,500',   delta: '▲ 5,500',    isImprovement: true),
    ],
    possibleSideEffects: [
      'Evacuation flow may restrict commuter movement on Murree Road detour links',
      'High silt levels in Leh Nullah may reduce water pumping turbine efficiency',
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

  // Scenario 6: Multi-crisis resource trade-off demo
  const DemoScenario(
    id: 'SCN-006',
    title: 'Multi-Crisis Coordination - Flood + Heat Emergency',
    crisisType: CrisisType.urbanFlooding,
    location: 'G-10 and I-10, Islamabad',
    coordinates: '33.6946N, 73.0179E',
    severity: SeverityLevel.critical,
    confidence: 89,
    status: CrisisStatus.active,
    affectedPopulation: 6900,
    expectedDuration: '4-8 hours',
    likelyEvolution:
        'Flooding in G-10 will spread traffic pressure toward I-10 while a nearby heat emergency raises medical demand. Shared ambulances and field teams must be split carefully.',
    mapZoneLabel: 'G-10 / I-10 coordination zone',
    resourceSummary:
        'Constrained pool: 2 rescue boats, 2 ambulances, 1 pumping unit, 2 medical teams, 3 traffic units',
    resourceUnits: [
      'Rescue Boat RB-04',
      'Rescue Boat RB-07',
      'Pumping Unit PU-02',
      'Ambulance AMB-12',
      'Ambulance AMB-18',
      'Medical Team MT-05',
      'Traffic Unit TU-03',
    ],
    socialSignal: SignalInput(
      source: SignalSource.socialPost,
      content:
          'Multiple citizen posts: G-10 lanes flooded while I-10 low-income blocks report heat exhaustion cases.',
      confidence: 0.82,
    ),
    weatherSignal: SignalInput(
      source: SignalSource.weatherAlert,
      content:
          'PMD dual advisory: heavy rain cells over G-10 plus heat index 45C across I-10 industrial belt.',
      confidence: 0.93,
    ),
    trafficSignal: SignalInput(
      source: SignalSource.trafficData,
      content:
          'Traffic API: 88% congestion in G-10, 52% detour load toward I-10 medical corridor.',
      confidence: 0.90,
    ),
    extraSignals: [
      SignalInput(
        source: SignalSource.emergencyCall,
        content:
            '1122 call frequency doubled in 20 minutes: stranded vehicles and heat illness requests competing for ambulances.',
        confidence: 0.86,
      ),
    ],
    verificationType: VerificationType.confirmed,
    verificationNote:
        'Four source families agree that two incidents are active. CIRO prioritizes flood rescue for immediate life safety while reserving one ambulance and one medical team for heat cases.',
    responseActions: [
      PlanAction(
        step: 1,
        title: 'Prioritize G-10 Flood Rescue',
        description:
            'Assign both rescue boats and one pump to flooded lanes while keeping medical corridor open.',
        department: 'Rescue 1122 / CDA Drainage',
        priority: 'P1',
        eta: '8 min',
        status: 'In Progress',
        resultSummary: 'Water rescue resources assigned; pump team dispatched.',
      ),
      PlanAction(
        step: 2,
        title: 'Reserve Ambulance for I-10 Heat Emergency',
        description:
            'Hold one ambulance and one medical team for heatstroke triage instead of sending all medical units to G-10.',
        department: 'Health Department',
        priority: 'P1',
        eta: '10 min',
        status: 'Completed',
        resultSummary: 'Medical reserve protected for I-10.',
      ),
      PlanAction(
        step: 3,
        title: 'Stage Public Alerts by Sector',
        description:
            'Send flood alerts to G-10 first, then heat advisory to I-10 to prevent simultaneous evacuation congestion.',
        department: 'PSCA Broadcast',
        priority: 'P2',
        eta: '5 min',
        status: 'Completed',
        resultSummary: 'Staged alerting reduced detour overload.',
      ),
      PlanAction(
        step: 4,
        title: 'Open Hospital Prep Channel',
        description:
            'Notify PIMS and nearby clinics to split beds between trauma, hypothermia, and heatstroke intake.',
        department: 'Hospital Coordination Cell',
        priority: 'P2',
        eta: '7 min',
        status: 'Completed',
      ),
    ],
    simulationMetrics: [
      MetricPair(label: 'Flood Response Time', before: '20 min', after: '8 min', delta: 'down 12 min', isImprovement: true),
      MetricPair(label: 'Heat Triage Capacity', before: '0 teams', after: '1 team', delta: 'up 1', isImprovement: true),
      MetricPair(label: 'Congestion Spillover', before: '52%', after: '31%', delta: 'down 21%', isImprovement: true),
      MetricPair(label: 'Uncovered Incidents', before: '1', after: '0', delta: 'down 1', isImprovement: true),
    ],
    possibleSideEffects: [
      'Flood rescue receives fewer ambulances than ideal because one unit is reserved for heat cases',
      'Staged alerts delay some non-critical public messaging by five minutes',
    ],
    orchestration: ScenarioOrchestrationHints(
      resourceConstraint:
          'Only 2 ambulances and 2 field medical teams available across two simultaneous incidents.',
      affectedRadius: '3.8 km combined corridor',
      peakImpactTime: '45 min',
      spreadRisk: 'High: flood detours can overload the I-10 medical corridor.',
      uncertaintyRange: '+/- 18%',
      relatedIncidents: [
        RelatedIncident(
          title: 'Heat Emergency - I-10 low-income blocks',
          type: CrisisType.heatwave,
          location: 'I-10, Islamabad',
          severity: SeverityLevel.high,
          affectedPopulation: 3700,
          confidence: 84,
          coordinationNeed:
              'Protect ambulance and medical team capacity while flood rescue consumes mobility resources.',
        ),
      ],
      resourceTradeOffs: [
        'AMB-18 reserved for heatstroke instead of flood evacuation.',
        'Traffic units prioritize ambulance corridor before general commuter relief.',
        'Public alerts are staged to avoid evacuation surge on the same detour route.',
      ],
      stakeholderMessages: {
        'Public':
            'G-10 residents avoid flooded roads; I-10 residents follow heat advisory and use cooling points.',
        'Hospitals':
            'Prepare split surge: water rescue injuries plus heatstroke triage expected within 45 minutes.',
      },
    ),
  ),

  // Scenario 7: Conflicting signals demo
  const DemoScenario(
    id: 'SCN-007',
    title: 'Conflicting Signals - Flood Report vs Water Main',
    crisisType: CrisisType.urbanFlooding,
    location: 'G-10 Markaz, Islamabad',
    coordinates: '33.6946N, 73.0179E',
    severity: SeverityLevel.moderate,
    confidence: 61,
    status: CrisisStatus.needsVerification,
    affectedPopulation: 900,
    expectedDuration: '1-2 hours',
    likelyEvolution:
        'If the field report is correct, the event is a localized water-main burst. If rainfall resumes, low-lying roads may still flood.',
    mapZoneLabel: 'G-10 verification zone',
    resourceSummary:
        '1 field verification team, 1 utility crew, traffic warden standby',
    resourceUnits: [
      'Field Team FT-02',
      'CDA Water Crew WC-05',
      'Traffic Warden TW-08',
    ],
    socialSignal: SignalInput(
      source: SignalSource.socialPost,
      content:
          'Citizen posts say G-10 is flooded and vehicles are slowing near Markaz.',
      confidence: 0.72,
    ),
    weatherSignal: SignalInput(
      source: SignalSource.weatherAlert,
      content:
          'Weather radar: rain has stopped; no active heavy rainfall cell over G-10.',
      confidence: 0.88,
    ),
    trafficSignal: SignalInput(
      source: SignalSource.trafficData,
      content:
          'Traffic API: moderate congestion, no full route closure detected.',
      confidence: 0.79,
    ),
    extraSignals: [
      SignalInput(
        source: SignalSource.fieldReport,
        content:
            'Responder report: visible water source appears to be a broken main, not area-wide flooding.',
        confidence: 0.91,
      ),
    ],
    verificationType: VerificationType.conflictingSignals,
    verificationNote:
        'Social reports indicate flooding, but weather and traffic are below flood thresholds and field report suggests a water-main burst. CIRO holds public flood alert and escalates utility verification.',
    responseActions: [
      PlanAction(
        step: 1,
        title: 'Hold Full Flood Alert',
        description:
            'Prevent panic messaging until field verification confirms crisis type.',
        department: 'Command Center',
        priority: 'P1',
        eta: 'Immediate',
        status: 'Completed',
        resultSummary: 'Flood broadcast paused pending verification.',
      ),
      PlanAction(
        step: 2,
        title: 'Dispatch CDA Water Crew',
        description:
            'Verify suspected broken water main and isolate valve if confirmed.',
        department: 'CDA Water Utility',
        priority: 'P1',
        eta: '9 min',
        status: 'In Progress',
      ),
      PlanAction(
        step: 3,
        title: 'Monitor Traffic Escalation',
        description:
            'Keep one warden on standby and trigger reroute only if congestion exceeds 75%.',
        department: 'Traffic Police',
        priority: 'P2',
        eta: 'Ongoing',
        status: 'Pending',
      ),
    ],
    simulationMetrics: [
      MetricPair(label: 'False Alert Risk', before: 'High', after: 'Low', delta: 'down', isImprovement: true),
      MetricPair(label: 'Verification ETA', before: '25 min', after: '9 min', delta: 'down 16 min', isImprovement: true),
      MetricPair(label: 'Resource Cost', before: '6 units', after: '3 units', delta: 'down 3', isImprovement: true),
    ],
    possibleSideEffects: [
      'Holding the public alert may delay warning if rainfall suddenly resumes',
    ],
    orchestration: ScenarioOrchestrationHints(
      resourceConstraint:
          'Do not consume flood rescue assets until field report resolves the contradiction.',
      affectedRadius: '0.8 km',
      peakImpactTime: 'Unknown pending verification',
      spreadRisk: 'Low-to-moderate, depends on valve isolation and rainfall return.',
      uncertaintyRange: '+/- 30%',
      resourceTradeOffs: [
        'Utility crew dispatched before rescue boats to reduce false positive cost.',
        'Traffic reroute remains standby to avoid unnecessary congestion.',
      ],
      stakeholderMessages: {
        'Public':
            'Localized water disruption under verification near G-10 Markaz. Avoid the immediate lane; no evacuation order issued.',
        'Utilities':
            'Urgent field verification requested for suspected water-main burst at G-10 Markaz.',
      },
    ),
  ),

  // Scenario 8: False positive recovery demo
  const DemoScenario(
    id: 'SCN-008',
    title: 'False Positive Recovery - Flood Alert Retracted',
    crisisType: CrisisType.urbanFlooding,
    location: 'F-11 Underpass, Islamabad',
    coordinates: '33.6844N, 72.9882E',
    severity: SeverityLevel.low,
    confidence: 42,
    status: CrisisStatus.resolved,
    affectedPopulation: 120,
    expectedDuration: 'Resolved',
    likelyEvolution:
        'No crisis evolution expected. Image repost and stale traffic report caused an early false flood classification.',
    mapZoneLabel: 'F-11 resolved alert',
    resourceSummary: 'No emergency dispatch; alert correction and log update only',
    resourceUnits: [
      'Verification Desk VD-01',
      'Public Information Officer PIO-02',
    ],
    socialSignal: SignalInput(
      source: SignalSource.socialPost,
      content:
          'Viral image claims F-11 underpass is flooded, but metadata is from last monsoon season.',
      confidence: 0.38,
    ),
    weatherSignal: SignalInput(
      source: SignalSource.weatherAlert,
      content: 'Weather API: clear skies, 0mm rainfall in the last hour.',
      confidence: 0.96,
    ),
    trafficSignal: SignalInput(
      source: SignalSource.trafficData,
      content: 'Traffic API: normal flow, no closure, no congestion spike.',
      confidence: 0.93,
    ),
    extraSignals: [
      SignalInput(
        source: SignalSource.fieldReport,
        content:
            'Field team confirms the underpass is dry. Original image was stale.',
        confidence: 0.98,
      ),
    ],
    verificationType: VerificationType.falsePositiveRisk,
    verificationNote:
        'CIRO recovered from a low-confidence flood rumor. Official weather, traffic, and field verification contradict the viral post. Public correction issued and model log updated.',
    responseActions: [
      PlanAction(
        step: 1,
        title: 'Retract Draft Flood Alert',
        description:
            'Cancel pending public flood alert before it reaches broadcast queue.',
        department: 'PSCA Broadcast',
        priority: 'P1',
        eta: 'Immediate',
        status: 'Completed',
        resultSummary: 'Alert cancelled before mass delivery.',
      ),
      PlanAction(
        step: 2,
        title: 'Issue Public Correction',
        description:
            'Publish correction that the F-11 image is stale and no flood response is active.',
        department: 'Media Cell',
        priority: 'P2',
        eta: '4 min',
        status: 'Completed',
        resultSummary: 'Correction sent to app feed and command center.',
      ),
      PlanAction(
        step: 3,
        title: 'Update Misinformation Signature',
        description:
            'Flag reposted media pattern for lower credibility in future flood detections.',
        department: 'Verification Agent',
        priority: 'P3',
        eta: '2 min',
        status: 'Completed',
      ),
    ],
    simulationMetrics: [
      MetricPair(label: 'False Dispatches', before: '4 units', after: '0 units', delta: 'down 4', isImprovement: true),
      MetricPair(label: 'Public Confusion', before: 'High', after: 'Low', delta: 'down', isImprovement: true),
      MetricPair(label: 'Resource Waste', before: 'High', after: 'None', delta: 'down', isImprovement: true),
    ],
    possibleSideEffects: [
      'Correction must be worded carefully to preserve trust for future alerts',
    ],
    orchestration: ScenarioOrchestrationHints(
      resourceConstraint:
          'Emergency units remain available because verification blocks false dispatch.',
      affectedRadius: '0 km confirmed',
      peakImpactTime: 'No peak impact',
      spreadRisk: 'Misinformation spread risk only.',
      uncertaintyRange: '+/- 8%',
      resourceTradeOffs: [
        'No rescue resources assigned; verification and media correction only.',
      ],
      stakeholderMessages: {
        'Public':
            'Correction: no active flood at F-11 underpass. Earlier image was stale. Continue normal travel with caution.',
        'Media/Command Center':
            'Retract flood mention and cite verified field report plus weather/traffic contradiction.',
      },
    ),
  ),

  // Scenario 9: False negative escalation demo
  const DemoScenario(
    id: 'SCN-009',
    title: 'False Negative Escalation - Outage Becomes Critical',
    crisisType: CrisisType.powerOutage,
    location: 'I-9 Industrial Area, Islamabad',
    coordinates: '33.6647N, 73.0551E',
    severity: SeverityLevel.high,
    confidence: 81,
    status: CrisisStatus.active,
    affectedPopulation: 4300,
    expectedDuration: '3-6 hours',
    likelyEvolution:
        'Initial sparse outage complaints were under-rated. Sensor and hospital generator alerts now indicate a critical infrastructure risk.',
    mapZoneLabel: 'I-9 escalation zone',
    resourceSummary:
        'Utility repair crew, mobile generator, police support for dark intersections',
    resourceUnits: [
      'IESCO Repair Crew RC-06',
      'Generator Unit GEN-05',
      'Police Mobile PM-09',
      'Field Team FT-09',
    ],
    socialSignal: SignalInput(
      source: SignalSource.socialPost,
      content:
          'Early posts said "lights are flickering" and were initially below alert threshold.',
      confidence: 0.55,
    ),
    weatherSignal: SignalInput(
      source: SignalSource.weatherAlert,
      content: 'Weather: clear. No storm cause detected for outage.',
      confidence: 0.82,
      isActive: false,
    ),
    trafficSignal: SignalInput(
      source: SignalSource.trafficData,
      content:
          'Traffic signal outages causing growing congestion at I-9 industrial intersections.',
      confidence: 0.83,
    ),
    extraSignals: [
      SignalInput(
        source: SignalSource.mockSensor,
        content:
            'Grid sensor: feeder voltage dropped to 0V across I-9/3 and hospital backup line unstable.',
        confidence: 0.97,
      ),
      SignalInput(
        source: SignalSource.emergencyCall,
        content:
            'Hospital desk reports generator fuel reserve under 90 minutes.',
        confidence: 0.89,
      ),
    ],
    verificationType: VerificationType.escalationRequired,
    verificationNote:
        'False negative recovered: early social signals were weak, but later grid sensors and hospital calls push severity to High. CIRO escalates utility and generator response.',
    responseActions: [
      PlanAction(
        step: 1,
        title: 'Escalate IESCO Repair Crew',
        description:
            'Dispatch repair crew to feeder fault and prioritize hospital backup line.',
        department: 'IESCO Grid Operations',
        priority: 'P1',
        eta: '12 min',
        status: 'In Progress',
        resultSummary: 'Repair crew accepted critical ticket.',
      ),
      PlanAction(
        step: 2,
        title: 'Deploy Mobile Generator to Clinic',
        description:
            'Move generator unit to the highest-risk clinic before fuel reserve drops below threshold.',
        department: 'NDMA Utilities',
        priority: 'P1',
        eta: '18 min',
        status: 'Pending',
      ),
      PlanAction(
        step: 3,
        title: 'Secure Dark Intersections',
        description:
            'Send police mobile to manually control traffic lights until grid restores.',
        department: 'Traffic Police',
        priority: 'P2',
        eta: '8 min',
        status: 'Completed',
      ),
    ],
    simulationMetrics: [
      MetricPair(label: 'Escalation Delay', before: '45 min', after: '12 min', delta: 'down 33 min', isImprovement: true),
      MetricPair(label: 'Critical Sites Powered', before: '0', after: '2', delta: 'up 2', isImprovement: true),
      MetricPair(label: 'Intersection Risk', before: 'High', after: 'Moderate', delta: 'down', isImprovement: true),
    ],
    possibleSideEffects: [
      'Generator deployment leaves one shelter without backup power for 30 minutes',
    ],
    orchestration: ScenarioOrchestrationHints(
      resourceConstraint:
          'Only one mobile generator is available; critical clinic receives priority over shelter standby.',
      affectedRadius: '2.4 km',
      peakImpactTime: '60-90 min',
      spreadRisk: 'High if hospital backup power is not stabilized.',
      uncertaintyRange: '+/- 20%',
      resourceTradeOffs: [
        'Generator GEN-05 sent to clinic instead of shelter standby.',
        'Police support assigned to intersections while utility crew repairs feeder.',
      ],
      stakeholderMessages: {
        'Hospitals':
            'Activate generator conservation mode. Mobile generator ETA 18 minutes.',
        'Utilities':
            'Critical feeder outage escalation: prioritize I-9/3 and clinic backup line.',
      },
    ),
  ),
];

/// Convenience getter by ID.
DemoScenario scenarioById(String id) =>
    mockDemoScenarios.firstWhere((s) => s.id == id);
