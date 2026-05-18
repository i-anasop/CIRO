// CIRO — Light Mode Color Design System v3
// Premium off-white / soft-card light theme.
// Severity colors unchanged per AGENTS.md §8.
// Backward-compatible aliases preserved.

import 'package:flutter/material.dart';

class CiroColors {
  CiroColors._();

  // ── Background Layers (Light) ─────────────────────────────────────────────
  static const Color bg0 = Color(0xFFFFFFFF); // Pure white surface
  static const Color bg1 = Color(0xFFF4F6FB); // Primary scaffold (off-white/lavender tint)
  static const Color bg2 = Color(0xFFF9FAFF); // Section background
  static const Color bg3 = Color(0xFFFFFFFF); // Card surface
  static const Color bg4 = Color(0xFFF4F6FB); // Elevated card / soft tint
  static const Color bg5 = Color(0xFFE8EEFE); // Hover / pressed state

  // Aliases for backward compat
  static const Color backgroundPrimary   = bg1;
  static const Color backgroundSecondary = bg2;
  static const Color backgroundCard      = bg3;
  static const Color backgroundElevated  = bg4;

  // ── Brand / Intelligence Accents ──────────────────────────────────────────
  static const Color brand       = Color(0xFF5A5CE5); // Deep Indigo
  static const Color brandLight  = Color(0xFF8183F4); // Lighter indigo
  static const Color brandAccent = Color(0xFF5A5CE5); // Indigo
  static const Color brandGlow   = Color(0x225A5CE5); // Translucent glow

  // Pastel accents for category cards
  static const Color pastelBlue    = Color(0xFFEFF6FF); // Blue tint card bg
  static const Color pastelLavender = Color(0xFFF0EFFE); // Lavender tint card bg
  static const Color pastelPeach   = Color(0xFFFFF7ED); // Peach tint card bg
  static const Color pastelGreen   = Color(0xFFF0FDF4); // Green tint card bg
  static const Color pastelRed     = Color(0xFFFEF2F2); // Red tint card bg

  // ── Severity — AGENTS.md §8 ────────────────────────────────────────────────
  static const Color critical  = Color(0xFFFF3B30); // Critical — red
  static const Color high      = Color(0xFFFF9500); // High — orange
  static const Color moderate  = Color(0xFFFFCC00); // Moderate — yellow
  static const Color low       = Color(0xFF34C759); // Low — green
  static const Color unknown   = Color(0xFF8E8E93); // Pending — slate

  // Translucent severity fills (light mode — more subtle)
  static const Color criticalFill  = Color(0x14EF4444);
  static const Color highFill      = Color(0x14F97316);
  static const Color moderateFill  = Color(0x14EAB308);
  static const Color lowFill       = Color(0x1422C55E);
  static const Color unknownFill   = Color(0x1294A3B8);

  // Severity border
  static const Color criticalBorder  = Color(0x40EF4444);
  static const Color highBorder      = Color(0x40F97316);
  static const Color moderateBorder  = Color(0x40EAB308);
  static const Color lowBorder       = Color(0x4022C55E);

  // Backward compat aliases
  static const Color criticalBg = criticalFill;
  static const Color highBg     = highFill;
  static const Color moderateBg = moderateFill;
  static const Color lowBg      = lowFill;
  static const Color unknownBg  = unknownFill;

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color statusActive     = Color(0xFFEF4444);
  static const Color statusMonitoring = Color(0xFFF97316);
  static const Color statusResolved   = Color(0xFF22C55E);
  static const Color statusVerify     = Color(0xFF6366F1);

  // ── Text (Dark on light) ──────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1E1E2D); // Near-black
  static const Color textSecondary = Color(0xFF5E6278); // Dark slate
  static const Color textMuted     = Color(0xFFA1A5B7); // Slate gray
  static const Color textDisabled  = Color(0xFFE4E6EF); // Light gray
  static const Color textOnDark    = Color(0xFFFFFFFF); // White on dark elements
  static const Color textOnBrand   = Color(0xFFFFFFFF);

  // ── Borders ───────────────────────────────────────────────────────────────
  static const Color border      = Color(0xFFE2E8F0); // Very light border
  static const Color borderLight = Color(0xFFF1F5F9); // Almost invisible
  static const Color borderGlow  = Color(0xFF6366F1); // Active / focus border

  // ── Utility ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error   = Color(0xFFEF4444);
  static const Color info    = Color(0xFF3B82F6);

  // ── Map / Geo ─────────────────────────────────────────────────────────────
  static const Color mapSurface    = Color(0xFFF0F4FF);
  static const Color mapGrid       = Color(0xFFE2E8F0);
  static const Color mapZoneRed    = Color(0x33EF4444);
  static const Color mapZoneAmber  = Color(0x33F97316);
  static const Color mapRoute      = Color(0xFF3B82F6);
  static const Color mapRouteAlt   = Color(0xFF22C55E);
  static const Color mapPin        = Color(0xFF3B82F6);

  // ── Gradient Presets ──────────────────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF5A5CE5), Color(0xFF7E7FF0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient criticalGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroBluePurple = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Legacy dark gradient (still used by maps / agent log accents)
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF0F4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Box Shadow Presets ────────────────────────────────────────────────────

  /// Soft card shadow for light mode (matching design image).
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF5A5CE5).withValues(alpha: 0.04), // faint brand tint
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.02),
      blurRadius: 8,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    ),
  ];

  /// Blue glow for active/brand elements.
  static List<BoxShadow> get glowCyan => [
    BoxShadow(
      color: brand.withValues(alpha: 0.18),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  /// Red glow for critical crisis elements.
  static List<BoxShadow> get glowCritical => [
    BoxShadow(
      color: critical.withValues(alpha: 0.2),
      blurRadius: 16,
      spreadRadius: 1,
    ),
  ];

  // ── Severity Helpers ─────────────────────────────────────────────────────
  static Color bySeverity(String s) {
    switch (s.toLowerCase()) {
      case 'critical': return critical;
      case 'high':     return high;
      case 'moderate': return moderate;
      case 'low':      return low;
      default:         return unknown;
    }
  }

  static Color bySeverityBg(String s) {
    switch (s.toLowerCase()) {
      case 'critical': return criticalFill;
      case 'high':     return highFill;
      case 'moderate': return moderateFill;
      case 'low':      return lowFill;
      default:         return unknownFill;
    }
  }

  static Color bySeverityBorder(String s) {
    switch (s.toLowerCase()) {
      case 'critical': return criticalBorder;
      case 'high':     return highBorder;
      case 'moderate': return moderateBorder;
      case 'low':      return lowBorder;
      default:         return border;
    }
  }

  /// Pastel card background per severity (for category cards).
  static Color pastelBySeverity(String s) {
    switch (s.toLowerCase()) {
      case 'critical': return pastelRed;
      case 'high':     return pastelPeach;
      case 'moderate': return const Color(0xFFFFFBEB);
      case 'low':      return pastelGreen;
      default:         return pastelBlue;
    }
  }
}
