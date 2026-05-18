// CIRO — Weather Service
// Fetches current weather from OpenWeather API (current weather endpoint).
// Detects crisis risk indicators: heavy rain, heatwave, storm, flood risk.
// Always returns a typed WeatherResult — never throws.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_result.dart';
import 'app_config.dart';

class WeatherService {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final WeatherService instance = WeatherService._();
  WeatherService._();

  static const _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherResult> getWeather(double lat, double lon) async {
    if (!AppConfig.instance.hasOpenWeatherKey) {
      return WeatherResult.failure('OpenWeather key not configured');
    }

    try {
      final uri = Uri.parse(
        '$_baseUrl?lat=$lat&lon=$lon'
        '&appid=${AppConfig.instance.openWeatherApiKey}'
        '&units=metric',
      );
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) {
        return WeatherResult.failure(
            'Weather API error ${resp.statusCode}');
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return _parse(data);
    } catch (e) {
      return WeatherResult.failure('Weather request failed: ${e.runtimeType}');
    }
  }

  WeatherResult _parse(Map<String, dynamic> d) {
    final main    = d['main']    as Map<String, dynamic>? ?? {};
    final wind    = d['wind']    as Map<String, dynamic>? ?? {};
    final rain    = d['rain']    as Map<String, dynamic>? ?? {};
    final weather = (d['weather'] as List<dynamic>?)?.first
        as Map<String, dynamic>? ?? {};

    final temp        = (main['temp']       as num?)?.toDouble() ?? 0;
    final feelsLike   = (main['feels_like'] as num?)?.toDouble() ?? 0;
    final humidity    = (main['humidity']   as num?)?.toInt()    ?? 0;
    final windSpeed   = (wind['speed']      as num?)?.toDouble() ?? 0;
    final rainfall1h  = (rain['1h']         as num?)?.toDouble() ?? 0;
    final condition   = weather['main']        as String? ?? '';
    final description = weather['description'] as String? ?? '';

    final risk   = _detectRisk(temp, condition, rainfall1h, windSpeed);
    final summary = _buildSummary(
        temp, condition, description, risk, humidity, rainfall1h);

    return WeatherResult(
      temperature:      temp,
      feelsLike:        feelsLike,
      humidity:         humidity,
      condition:        condition,
      description:      description,
      windSpeed:        windSpeed,
      rainfallLastHour: rainfall1h,
      alertLevel:       risk,
      rawSummary:       summary,
      isSuccess:        true,
    );
  }

  /// Classify weather into crisis risk tier.
  WeatherRisk _detectRisk(
    double temp, String condition, double rainfall, double windSpeed) {
    // Heatwave: feels like > 42°C
    if (temp >= 42) return WeatherRisk.heatwave;
    // Storm: Thunderstorm condition + high wind
    if (condition.contains('Thunderstorm') && windSpeed > 10) {
      return WeatherRisk.storm;
    }
    // Flood risk: heavy rain > 10mm/h
    if (rainfall > 10) return WeatherRisk.floodRisk;
    // Heavy rain: any rain > 3mm/h
    if (rainfall > 3 ||
        condition.contains('Rain') ||
        description.contains('heavy') ||
        description.contains('intense')) {
      return WeatherRisk.heavyRain;
    }
    return WeatherRisk.none;
  }

  String get description => '';

  String _buildSummary(double temp, String condition, String desc,
      WeatherRisk risk, int humidity, double rainfall) {
    final riskSuffix = risk != WeatherRisk.none
        ? ' ⚠️ ${_riskLabel(risk)}'
        : '';
    final rainSuffix = rainfall > 0 ? ' | Rain: ${rainfall.toStringAsFixed(1)}mm/h' : '';
    return '${temp.toStringAsFixed(1)}°C · $desc'
        ' · Humidity $humidity%$rainSuffix$riskSuffix';
  }

  String _riskLabel(WeatherRisk r) {
    switch (r) {
      case WeatherRisk.heatwave:  return 'HEATWAVE';
      case WeatherRisk.floodRisk: return 'FLOOD RISK';
      case WeatherRisk.heavyRain: return 'HEAVY RAIN';
      case WeatherRisk.storm:     return 'STORM';
      default:                    return '';
    }
  }
}
