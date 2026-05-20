// CIRO — Gemini AI Service
// Core wrapper around the google_generative_ai package.
// Provides structured JSON generation via Gemini 2.0 Flash.
// Never throws — all failures return null and callers handle gracefully.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'app_config.dart';

class GeminiService {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final GeminiService instance = GeminiService._();
  GeminiService._();

  GenerativeModel? _model;
  bool _initialized = false;
  bool _lastCallSucceeded = true;

  /// Whether the last call to Gemini succeeded.
  bool get lastCallSucceeded => _lastCallSucceeded;

  /// Reset the last call status.
  void resetLastCallStatus() {
    _lastCallSucceeded = true;
  }

  /// Initialize the Gemini model. Safe to call multiple times.
  void _ensureInitialized() {
    if (_initialized) return;
    final key = AppConfig.instance.geminiApiKey;
    if (key.isEmpty) return;

    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: key,
      generationConfig: GenerationConfig(
        temperature: 0.3,       // Low temperature for factual, consistent output
        maxOutputTokens: 2048,
        responseMimeType: 'application/json',
      ),
    );
    _initialized = true;
  }

  /// Whether the service is ready to make calls.
  bool get isAvailable {
    _ensureInitialized();
    return _model != null;
  }

  /// Send a prompt to Gemini and get back parsed JSON.
  /// Returns null on any failure (network, parsing, quota, etc.)
  Future<Map<String, dynamic>?> generateJson(String prompt) async {
    _ensureInitialized();
    if (_model == null) {
      _lastCallSucceeded = false;
      return null;
    }

    try {
      final response = await _model!.generateContent(
        [Content.text(prompt)],
      ).timeout(const Duration(seconds: 30));

      final text = response.text;
      if (text == null || text.isEmpty) {
        _lastCallSucceeded = false;
        return null;
      }

      // Clean up response — Gemini sometimes wraps JSON in markdown code fences
      String cleaned = text.trim();
      if (cleaned.startsWith('```json')) {
        cleaned = cleaned.substring(7);
      } else if (cleaned.startsWith('```')) {
        cleaned = cleaned.substring(3);
      }
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3);
      }
      cleaned = cleaned.trim();

      final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
      _lastCallSucceeded = true;
      return parsed;
    } catch (e) {
      debugPrint('[GeminiService] Error: $e');
      _lastCallSucceeded = false;
      return null;
    }
  }

  /// Send a prompt and get back raw text.
  /// Returns null on any failure.
  Future<String?> generateText(String prompt) async {
    _ensureInitialized();
    if (_model == null) {
      _lastCallSucceeded = false;
      return null;
    }

    try {
      // For text output, create a temporary model without JSON mime type
      final textModel = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: AppConfig.instance.geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0.3,
          maxOutputTokens: 1024,
        ),
      );

      final response = await textModel.generateContent(
        [Content.text(prompt)],
      ).timeout(const Duration(seconds: 20));

      final text = response.text;
      if (text != null) {
        _lastCallSucceeded = true;
      } else {
        _lastCallSucceeded = false;
      }
      return text;
    } catch (e) {
      debugPrint('[GeminiService] Text generation error: $e');
      _lastCallSucceeded = false;
      return null;
    }
  }
}
