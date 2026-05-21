// CIRO — Groq AI Service
// Uses Groq's OpenAI-compatible REST API.
// Model: llama-3.3-70b-versatile (free tier: 14,400 req/day, 30 req/min)
// Fast cloud AI path with generous free quota.
// Zero extra dependencies — uses dart:convert + http (already in project).
// Never throws — all failures return null and callers handle gracefully.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class GroqService {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final GroqService instance = GroqService._();
  GroqService._();

  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  // Primary model — fast, free, powerful (70B params)
  static const _primaryModel = 'llama-3.3-70b-versatile';

  bool _lastCallSucceeded = true;
  DateTime? _rateLimitedUntil;
  String? _lastRateLimitMessage;

  bool get lastCallSucceeded => _lastCallSucceeded;
  bool get isRateLimited =>
      _rateLimitedUntil != null && DateTime.now().isBefore(_rateLimitedUntil!);

  void resetLastCallStatus() {
    _lastCallSucceeded = !isRateLimited;
  }

  bool get isAvailable => AppConfig.instance.hasGroqKey;

  // ── Core JSON generation ──────────────────────────────────────────────────

  /// Send a prompt to Groq and get back parsed JSON.
  /// Returns null on any failure — callers must handle gracefully.
  Future<Map<String, dynamic>?> generateJson(String prompt) async {
    if (!isAvailable) {
      _lastCallSucceeded = false;
      return null;
    }
    if (isRateLimited) {
      _lastCallSucceeded = false;
      return null;
    }

    try {
      final body = jsonEncode({
        'model': _primaryModel,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a crisis intelligence AI. Always respond with ONLY valid JSON. '
                'No explanation, no markdown fences, no extra text — pure JSON only.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.25,
        'max_tokens': 2048,
        'top_p': 1,
        'stream': false,
      });

      final resp = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer ${AppConfig.instance.groqApiKey}',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 20));

      if (resp.statusCode != 200) {
        _handleHttpFailure(resp.statusCode, resp.body);
        _lastCallSucceeded = false;
        return null;
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final content =
          (data['choices'] as List?)?.firstOrNull?['message']?['content']
              as String?;

      if (content == null || content.isEmpty) {
        _lastCallSucceeded = false;
        return null;
      }

      final cleaned = _stripFences(content);
      final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
      _lastCallSucceeded = true;
      return parsed;
    } catch (e) {
      debugPrint('[GroqService] Error: $e');
      _lastCallSucceeded = false;
      return null;
    }
  }

  /// Send a prompt to Groq and get back raw text.
  Future<String?> generateText(String prompt) async {
    if (!isAvailable) {
      _lastCallSucceeded = false;
      return null;
    }
    if (isRateLimited) {
      _lastCallSucceeded = false;
      return null;
    }

    try {
      final body = jsonEncode({
        'model': _primaryModel,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.3,
        'max_tokens': 512,
        'stream': false,
      });

      final resp = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer ${AppConfig.instance.groqApiKey}',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (resp.statusCode != 200) {
        _handleHttpFailure(resp.statusCode, resp.body);
        _lastCallSucceeded = false;
        return null;
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final content =
          (data['choices'] as List?)?.firstOrNull?['message']?['content']
              as String?;

      _lastCallSucceeded = content != null;
      return content;
    } catch (e) {
      debugPrint('[GroqService] Text generation error: $e');
      _lastCallSucceeded = false;
      return null;
    }
  }

  // ── Utility ───────────────────────────────────────────────────────────────

  /// Strip markdown code fences if the model wraps JSON anyway.
  String _stripFences(String s) {
    String c = s.trim();
    if (c.startsWith('```json')) {
      c = c.substring(7);
    } else if (c.startsWith('```')) {
      c = c.substring(3);
    }
    if (c.endsWith('```')) {
      c = c.substring(0, c.length - 3);
    }
    return c.trim();
  }

  void _handleHttpFailure(int statusCode, String body) {
    if (statusCode == 429) {
      final message = _extractErrorMessage(body);
      _rateLimitedUntil = DateTime.now().add(_parseRetryDelay(message));
      if (_lastRateLimitMessage != message) {
        debugPrint(
          '[GroqService] Rate limited. Switching to local fallback. $message',
        );
        _lastRateLimitMessage = message;
      }
      return;
    }
    debugPrint('[GroqService] HTTP $statusCode: $body');
  }

  String _extractErrorMessage(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        return error['message'] as String? ?? body;
      }
      return body;
    } catch (_) {
      return body;
    }
  }

  Duration _parseRetryDelay(String message) {
    final minuteMatch = RegExp(r'in\s+(\d+)m').firstMatch(message);
    final secondMatch = RegExp(
      r'in\s+(?:(?:\d+)m)?\s*(\d+(?:\.\d+)?)s',
    ).firstMatch(message);

    final minutes = int.tryParse(minuteMatch?.group(1) ?? '') ?? 0;
    final seconds = double.tryParse(secondMatch?.group(1) ?? '') ?? 0;
    final parsed = Duration(minutes: minutes, seconds: seconds.ceil());
    return parsed > Duration.zero ? parsed : const Duration(minutes: 30);
  }
}
