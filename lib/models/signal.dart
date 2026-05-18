// CIRO — Signal Data Model
// Defines the typed Signal entity collected by the Signal Agent.
// Signals are the raw inputs before fusion and detection.

/// Source type of a collected signal.
enum SignalSource {
  socialPost,
  weatherAlert,
  trafficData,
  citizenReport,
  emergencyCall,
  mockSensor,
  fieldReport,
}

class Signal {
  final String id;
  final SignalSource source;
  final String content;      // Human-readable raw signal text
  final String location;     // Location string extracted from signal
  final DateTime timestamp;
  final double confidence;   // 0.0–1.0 confidence of this signal's relevance
  final Map<String, dynamic> metadata; // Extra source-specific data

  const Signal({
    required this.id,
    required this.source,
    required this.content,
    required this.location,
    required this.timestamp,
    required this.confidence,
    this.metadata = const {},
  });

  /// Human-readable label for the signal source.
  String get sourceLabel {
    switch (source) {
      case SignalSource.socialPost:    return 'Social Post';
      case SignalSource.weatherAlert:  return 'Weather Alert';
      case SignalSource.trafficData:   return 'Traffic Data';
      case SignalSource.citizenReport: return 'Citizen Report';
      case SignalSource.emergencyCall: return 'Emergency Call';
      case SignalSource.mockSensor:    return 'IoT Sensor';
      case SignalSource.fieldReport:   return 'Field Report';
    }
  }

  /// Short icon identifier for UI display.
  String get sourceIcon {
    switch (source) {
      case SignalSource.socialPost:    return 'chat_bubble';
      case SignalSource.weatherAlert:  return 'cloud';
      case SignalSource.trafficData:   return 'directions_car';
      case SignalSource.citizenReport: return 'person_pin';
      case SignalSource.emergencyCall: return 'phone_in_talk';
      case SignalSource.mockSensor:    return 'sensors';
      case SignalSource.fieldReport:   return 'assignment';
    }
  }
}
