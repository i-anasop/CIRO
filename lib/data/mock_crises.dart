// CIRO — Mock Crisis Data
// Pre-detected crisis scenarios for the MVP prototype.
// Replace this file with real API responses when integrating live data.
// All entries conform to the Crisis model in lib/models/crisis.dart.

import '../models/crisis.dart';

final List<Crisis> mockCrises = [
  // ── Primary Demo Scenario: Urban Flooding in G-10, Islamabad ──────────────
  Crisis(
    id: 'CRS-2024-001',
    type: CrisisType.urbanFlooding,
    title: 'Urban Flooding — G-10 Markaz',
    location: 'G-10, Islamabad',
    coordinates: '33.6844,73.0479',
    severity: SeverityLevel.critical,
    status: CrisisStatus.active,
    confidencePercent: 91,
    affectedPeople: 3200,
    detectedAt: DateTime(2024, 6, 15, 14, 22),
    estimatedDuration: '4–6 hours',
    signalSummaries: [
      'Social: "G-10 mein pani bhar gaya hai, gaariyan phans gayi hain"',
      'Weather: Heavy Rainfall Alert — Red Category — Islamabad',
      'Traffic: G-10 Markaz 85% congestion spike, multiple routes blocked',
    ],
    detectionReasoning:
        'Three corroborating signals detected within 15 minutes. '
        'Social post in Urdu reports standing water and stranded vehicles. '
        'Red-category weather alert active for the sector. '
        'Traffic data confirms abnormal congestion consistent with road submersion. '
        'Geo-clustering places event epicentre at G-10 Markaz intersection.',
    verificationState: '✅ Confirmed Crisis',
  ),

  // ── Secondary Crisis: Road Blockage on Murree Road ──────────────────────
  Crisis(
    id: 'CRS-2024-002',
    type: CrisisType.roadBlockage,
    title: 'Major Traffic Blockage — Murree Road',
    location: 'Murree Road, Rawalpindi',
    coordinates: '33.5971,73.0516',
    severity: SeverityLevel.high,
    status: CrisisStatus.monitoring,
    confidencePercent: 78,
    affectedPeople: 1500,
    detectedAt: DateTime(2024, 6, 15, 13, 45),
    estimatedDuration: '2–3 hours',
    signalSummaries: [
      'Traffic: Murree Road 92% congestion, full standstill from Faizabad to Kacheri',
      'Social: Multiple posts reporting a multi-vehicle accident near Faizabad',
    ],
    detectionReasoning:
        'Traffic sensors show sustained 92% congestion for 40+ minutes. '
        'Social signals confirm a vehicle collision as the likely cause. '
        'Confidence is 78% — weather and emergency call data not yet corroborated.',
    verificationState: '⚠️ Needs Verification',
  ),

  // ── Tertiary Crisis: Heavy Rainfall in F-7 / F-8 ─────────────────────────
  Crisis(
    id: 'CRS-2024-003',
    type: CrisisType.urbanFlooding,
    title: 'Heavy Rainfall & Drainage Overflow — F-7 / F-8 Sectors',
    location: 'F-7 & F-8, Islamabad',
    coordinates: '33.7215,73.0433',
    severity: SeverityLevel.moderate,
    status: CrisisStatus.monitoring,
    confidencePercent: 88,
    affectedPeople: 4500,
    detectedAt: DateTime(2024, 6, 15, 11, 00),
    estimatedDuration: '2–4 hours',
    signalSummaries: [
      'Weather: Heavy Rainfall Alert — Amber Category — Islamabad',
      'Citizen Reports: 12 reports of localized drainage choke points in F-7/F-8',
      'Sensor: F-7 rain gauge detects 48mm precipitation in 90 minutes',
    ],
    detectionReasoning:
        'PMD Amber-category rainfall advisory active. Rain gauge detects '
        'extreme precipitation volume (48mm). Localized drainage blocks reported '
        'by residents. Secondary flooding risk if stormwater system overflows.',
    verificationState: '✅ Confirmed Threat',
  ),

  // ── Quaternary Crisis: Margalla Hills Landslide ──────────────────────────
  Crisis(
    id: 'CRS-2024-006',
    type: CrisisType.roadBlockage,
    title: 'Landslide Debris Blockage — Margalla Road',
    location: 'Margalla Hills, Islamabad',
    coordinates: '33.7580,73.0640',
    severity: SeverityLevel.high,
    status: CrisisStatus.active,
    confidencePercent: 92,
    affectedPeople: 1200,
    detectedAt: DateTime(2024, 6, 15, 14, 40),
    estimatedDuration: '4–6 hours',
    signalSummaries: [
      'Weather: Heavy rainfall trigger (95mm cumulative over Margalla Hills)',
      'Traffic: Margalla Road 90% congestion, full standstill near Zoo intersection',
      'Police Reports: Rescue 1122 confirms debris slide blocking both lanes',
    ],
    detectionReasoning:
        'Prolonged heavy rainfall has triggered a localized mud and rock slide '
        'on Margalla Road. Commuter flow completely blocked. Heavy road operations '
        'wardens dispatched for immediate clearance.',
    verificationState: '✅ Confirmed Crisis',
  ),

  // ── Power Outage — I-9 Industrial Zone ───────────────────────────────────
  Crisis(
    id: 'CRS-2024-004',
    type: CrisisType.powerOutage,
    title: 'Grid Failure — I-9 Industrial Zone',
    location: 'I-9, Islamabad',
    coordinates: '33.6504,73.0850',
    severity: SeverityLevel.high,
    status: CrisisStatus.active,
    confidencePercent: 93,
    affectedPeople: 2100,
    detectedAt: DateTime(2024, 6, 15, 12, 30),
    estimatedDuration: '6–12 hours',
    signalSummaries: [
      'Sensor: WAPDA feeder 14B voltage drop detected — 0V reading',
      'Citizen Reports: 47 complaint tickets raised in I-9 in 20 minutes',
    ],
    detectionReasoning:
        'WAPDA feeder sensor reports complete voltage drop. '
        'Surge of citizen complaint tickets from I-9 confirms widespread outage. '
        'Industrial zone impact assessment triggered.',
    verificationState: '✅ Confirmed Crisis',
  ),

  // ── False Positive Recovery: Accident in E-11 ────────────────────────────
  Crisis(
    id: 'CRS-2024-005',
    type: CrisisType.accident,
    title: 'Vehicle Collision Report — E-11 Expressway',
    location: 'E-11, Islamabad',
    coordinates: '33.7361,73.0175',
    severity: SeverityLevel.low,
    status: CrisisStatus.resolved,
    confidencePercent: 42,
    affectedPeople: 0,
    detectedAt: DateTime(2024, 6, 15, 10, 15),
    estimatedDuration: 'N/A',
    signalSummaries: [
      'Social: Single post reporting fender-bender on E-11 expressway',
    ],
    detectionReasoning:
        'Single low-confidence social signal with no corroboration from '
        'traffic or weather data. System flagged as potential false positive. '
        'Field team confirmed minor incident — no emergency response required.',
    verificationState: '🔴 False Positive Recovery',
  ),
];
