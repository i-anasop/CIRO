// CIRO — App Config Service
// Loads API keys from .env via flutter_dotenv.
// Exposes readiness flags without exposing key values in UI.
// Never crashes on missing keys — all getters are safe fallbacks.

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // ── Singleton ────────────────────────────────────────────────────────────
  static final AppConfig instance = AppConfig._();
  AppConfig._();

  /// Load .env file. Call once in main() before runApp().
  /// Silently continues if file is missing.
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // .env missing or unreadable — app continues in Demo Mode
    }
  }

  // ── Key accessors (never exposed in UI — only boolean status) ───────────
  String get _googleMapsKey  => dotenv.maybeGet('GOOGLE_MAPS_API_KEY')  ?? '';
  String get _openWeatherKey => dotenv.maybeGet('OPENWEATHER_API_KEY')  ?? '';
  String get _newsApiKey     => dotenv.maybeGet('NEWS_API_KEY')         ?? '';
  String get _geminiApiKey   => dotenv.maybeGet('GEMINI_API_KEY')       ?? '';
  String get _groqApiKey     => dotenv.maybeGet('GROQ_API_KEY')         ?? '';
  String get _gnewsApiKey    => dotenv.maybeGet('GNEWS_API_KEY')        ?? '';

  /// Returns key only for internal service use — never pass to UI.
  String get googleMapsApiKey  => _googleMapsKey;
  String get openWeatherApiKey => _openWeatherKey;
  String get newsApiKey        => _newsApiKey;
  String get geminiApiKey      => _geminiApiKey;
  String get groqApiKey        => _groqApiKey;
  String get gnewsApiKey       => _gnewsApiKey;

  // ── Readiness flags ───────────────────────────────────────────────────────
  bool get hasGoogleMapsKey =>
      _googleMapsKey.isNotEmpty &&
      !_googleMapsKey.contains('PASTE_YOUR');

  bool get hasOpenWeatherKey =>
      _openWeatherKey.isNotEmpty &&
      !_openWeatherKey.contains('PASTE_YOUR');

  bool get hasNewsApiKey =>
      _newsApiKey.isNotEmpty &&
      !_newsApiKey.contains('PASTE_YOUR');

  bool get hasGeminiKey =>
      _geminiApiKey.isNotEmpty &&
      !_geminiApiKey.contains('PASTE_YOUR');

  bool get hasGroqKey =>
      _groqApiKey.isNotEmpty &&
      !_groqApiKey.contains('PASTE_YOUR');

  bool get hasGnewsKey =>
      _gnewsApiKey.isNotEmpty &&
      !_gnewsApiKey.contains('PASTE_YOUR');

  /// AI is available if either Groq (primary) or Gemini (fallback) key is set.
  bool get hasAiKey => hasGroqKey || hasGeminiKey;

  /// Real Mode is fully available when AI + at least one signal key is present.
  bool get isRealModeAvailable =>
      hasAiKey && (hasGoogleMapsKey || hasOpenWeatherKey || hasNewsApiKey || hasGnewsKey);

  /// Real Mode is partially available with at least one key.
  bool get isRealModePartial =>
      hasGoogleMapsKey || hasOpenWeatherKey || hasNewsApiKey || hasGnewsKey;

  /// Summary string for UI display (no key values).
  String get modeLabel {
    if (isRealModeAvailable) return 'Real Mode Available';
    if (isRealModePartial)   return 'Real Mode Limited';
    return 'Demo Mode Only';
  }

  /// Which AI engine is active.
  String get aiEngineLabel {
    if (hasGroqKey)   return 'Groq (Llama 3.3)';
    if (hasGeminiKey) return 'Gemini 2.0 Flash';
    return 'Local Deterministic';
  }
}

