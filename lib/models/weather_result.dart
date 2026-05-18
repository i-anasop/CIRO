// CIRO — WeatherResult Model
// Typed result from OpenWeather API via WeatherService.
// Includes crisis risk indicators for signal generation.

/// Overall crisis risk derived from weather data.
enum WeatherRisk {
  none,
  heatwave,
  heavyRain,
  floodRisk,
  storm,
  unknown,
}

class WeatherResult {
  final double temperature;    // Celsius
  final double feelsLike;      // Celsius
  final int humidity;          // Percentage
  final String condition;      // e.g. "Rain", "Thunderstorm", "Clear"
  final String description;    // e.g. "heavy intensity rain"
  final double windSpeed;      // m/s
  final double rainfallLastHour; // mm (0.0 if not available)
  final WeatherRisk alertLevel;
  final String rawSummary;     // One-line human-readable
  final bool isSuccess;
  final String? errorMessage;

  const WeatherResult({
    this.temperature      = 0,
    this.feelsLike        = 0,
    this.humidity         = 0,
    this.condition        = '',
    this.description      = '',
    this.windSpeed        = 0,
    this.rainfallLastHour = 0,
    this.alertLevel       = WeatherRisk.none,
    this.rawSummary       = '',
    this.isSuccess        = true,
    this.errorMessage,
  });

  factory WeatherResult.failure(String message) => WeatherResult(
        isSuccess:    false,
        errorMessage: message,
        rawSummary:   'Weather data unavailable',
      );

  /// Returns true if weather warrants a crisis signal.
  bool get isCrisisRelevant =>
      alertLevel != WeatherRisk.none && alertLevel != WeatherRisk.unknown;

  String get alertLabel {
    switch (alertLevel) {
      case WeatherRisk.heatwave:  return 'Heatwave Advisory';
      case WeatherRisk.heavyRain: return 'Heavy Rainfall Alert';
      case WeatherRisk.floodRisk: return 'Flood Risk — RED Category';
      case WeatherRisk.storm:     return 'Storm Warning';
      default:                    return 'No Alert';
    }
  }

  String get temperatureLabel => '${temperature.toStringAsFixed(1)}°C';
  String get feelsLikeLabel   => '${feelsLike.toStringAsFixed(1)}°C';
  String get rainfallLabel    =>
      rainfallLastHour > 0 ? '${rainfallLastHour.toStringAsFixed(1)}mm/h' : 'None';
}
