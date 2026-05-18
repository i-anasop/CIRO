// CIRO — Mock Signals Data
// Raw input signals from all sources before fusion.
// Conforms to Signal model in lib/models/signal.dart.

import '../models/signal.dart';

final List<Signal> mockSignals = [
  Signal(
    id: 'SIG-001',
    source: SignalSource.socialPost,
    content: '"G-10 mein pani bhar gaya hai, gaariyan phans gayi hain" '
        '— @citizen_isb · 14:15 PKT',
    location: 'G-10, Islamabad',
    timestamp: DateTime(2024, 6, 15, 14, 15),
    confidence: 0.78,
    metadata: {'language': 'ur', 'platform': 'Twitter', 'likes': 47},
  ),
  Signal(
    id: 'SIG-002',
    source: SignalSource.weatherAlert,
    content: 'Heavy Rainfall Alert — Islamabad — RED Category — '
        'Expected >75mm rainfall in 3 hours — Issued by PMD at 14:32 PKT',
    location: 'Islamabad',
    timestamp: DateTime(2024, 6, 15, 14, 32),
    confidence: 0.97,
    metadata: {'category': 'RED', 'rainfall_mm': 75, 'issued_by': 'PMD'},
  ),
  Signal(
    id: 'SIG-003',
    source: SignalSource.trafficData,
    content: 'G-10 Markaz: 85% congestion spike — Multiple routes blocked — '
        'Abnormal since 14:18 PKT',
    location: 'G-10, Islamabad',
    timestamp: DateTime(2024, 6, 15, 14, 22),
    confidence: 0.91,
    metadata: {'congestion_pct': 85, 'blocked_routes': 3},
  ),
  Signal(
    id: 'SIG-004',
    source: SignalSource.trafficData,
    content: 'Murree Road: 92% congestion, full standstill from Faizabad to Kacheri',
    location: 'Murree Road, Rawalpindi',
    timestamp: DateTime(2024, 6, 15, 13, 45),
    confidence: 0.88,
    metadata: {'congestion_pct': 92},
  ),
  Signal(
    id: 'SIG-005',
    source: SignalSource.mockSensor,
    content: 'WAPDA Feeder 14B — Voltage: 0V — Duration: 12+ minutes',
    location: 'I-9, Islamabad',
    timestamp: DateTime(2024, 6, 15, 12, 30),
    confidence: 0.99,
    metadata: {'feeder': '14B', 'voltage': 0, 'duration_min': 12},
  ),
];
