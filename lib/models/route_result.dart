// CIRO — RouteResult Model
// Typed result from Google Routes API via RoutesService.
// Includes traffic-aware congestion estimation.

/// Congestion tier derived from traffic delay ratio.
enum CongestionLevel { low, medium, high, unknown }

class RouteResult {
  final int normalDurationMinutes;
  final int trafficDurationMinutes;
  final double distanceKm;
  final CongestionLevel congestionLevel;
  final String routeSummary;
  final bool isSuccess;
  final String? errorMessage;

  const RouteResult({
    this.normalDurationMinutes  = 0,
    this.trafficDurationMinutes = 0,
    this.distanceKm             = 0,
    this.congestionLevel        = CongestionLevel.unknown,
    this.routeSummary           = '',
    this.isSuccess              = true,
    this.errorMessage,
  });

  factory RouteResult.failure(String message) => RouteResult(
        isSuccess:    false,
        errorMessage: message,
        routeSummary: 'Route data unavailable',
      );

  /// Delay ratio: trafficDuration / normalDuration.
  double get delayRatio {
    if (normalDurationMinutes == 0) return 1.0;
    return trafficDurationMinutes / normalDurationMinutes;
  }

  /// Extra delay in minutes due to traffic.
  int get delayMinutes =>
      (trafficDurationMinutes - normalDurationMinutes).clamp(0, 999);

  String get congestionLabel {
    switch (congestionLevel) {
      case CongestionLevel.low:     return 'Low';
      case CongestionLevel.medium:  return 'Medium';
      case CongestionLevel.high:    return 'High';
      case CongestionLevel.unknown: return 'Unknown';
    }
  }

  /// Estimate congestion % for UI display.
  int get congestionPercent {
    switch (congestionLevel) {
      case CongestionLevel.low:     return 25;
      case CongestionLevel.medium:  return 55;
      case CongestionLevel.high:    return 85;
      case CongestionLevel.unknown: return 0;
    }
  }
}
