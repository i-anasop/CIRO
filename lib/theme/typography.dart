// CIRO — Light Mode Typography System v3
// Inter for all text — clean, modern, highly readable on light backgrounds.
// Space Grotesk for numeric/display emphasis.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class CiroTypography {
  CiroTypography._();

  // ── Display ───────────────────────────────────────────────────────────────
  static TextStyle get displayXl => GoogleFonts.plusJakartaSans(
    fontSize: 34, fontWeight: FontWeight.w800,
    color: CiroColors.textPrimary, letterSpacing: -1.0, height: 1.1,
  );

  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
    fontSize: 28, fontWeight: FontWeight.w800,
    color: CiroColors.textPrimary, letterSpacing: -0.6, height: 1.15,
  );

  static TextStyle get displayMedium => GoogleFonts.plusJakartaSans(
    fontSize: 22, fontWeight: FontWeight.w700,
    color: CiroColors.textPrimary, letterSpacing: -0.3, height: 1.2,
  );

  // ── Headings ──────────────────────────────────────────────────────────────
  static TextStyle get headingXl => GoogleFonts.plusJakartaSans(
    fontSize: 20, fontWeight: FontWeight.w700,
    color: CiroColors.textPrimary, letterSpacing: -0.2,
  );

  static TextStyle get headingLarge => GoogleFonts.plusJakartaSans(
    fontSize: 18, fontWeight: FontWeight.w700,
    color: CiroColors.textPrimary, letterSpacing: -0.1,
  );

  static TextStyle get headingMedium => GoogleFonts.plusJakartaSans(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: CiroColors.textPrimary,
  );

  static TextStyle get headingSmall => GoogleFonts.plusJakartaSans(
    fontSize: 14, fontWeight: FontWeight.w600,
    color: CiroColors.textPrimary,
  );

  // ── Body ──────────────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: CiroColors.textPrimary, height: 1.55,
  );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: CiroColors.textSecondary, height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: CiroColors.textMuted, height: 1.45,
  );

  // ── Labels ────────────────────────────────────────────────────────────────
  static TextStyle get labelXl => GoogleFonts.plusJakartaSans(
    fontSize: 15, fontWeight: FontWeight.w700,
    color: CiroColors.textPrimary,
  );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
    fontSize: 14, fontWeight: FontWeight.w600,
    color: CiroColors.textPrimary,
  );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
    fontSize: 13, fontWeight: FontWeight.w600,
    color: CiroColors.textSecondary,
  );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
    fontSize: 12, fontWeight: FontWeight.w600,
    color: CiroColors.textMuted, letterSpacing: 0.2,
  );

  static TextStyle get overline => GoogleFonts.plusJakartaSans(
    fontSize: 11, fontWeight: FontWeight.w700,
    color: CiroColors.textMuted, letterSpacing: 0.8,
  );

  // ── Special ───────────────────────────────────────────────────────────────
  static TextStyle get badge => GoogleFonts.plusJakartaSans(
    fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5,
  );

  static TextStyle get caption => GoogleFonts.plusJakartaSans(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: CiroColors.textMuted,
  );

  static TextStyle get numericLarge => GoogleFonts.plusJakartaSans(
    fontSize: 32, fontWeight: FontWeight.w800,
    color: CiroColors.textPrimary, letterSpacing: -0.5,
  );

  static TextStyle get numericMedium => GoogleFonts.plusJakartaSans(
    fontSize: 24, fontWeight: FontWeight.w700,
    color: CiroColors.textPrimary, letterSpacing: -0.3,
  );

  static TextStyle get numericSmall => GoogleFonts.plusJakartaSans(
    fontSize: 18, fontWeight: FontWeight.w700,
    color: CiroColors.textPrimary,
  );

  static TextStyle get monospace => TextStyle(
    fontFamily: 'monospace', fontSize: 11,
    color: CiroColors.brandAccent, height: 1.6,
    letterSpacing: 0.3,
  );
}
