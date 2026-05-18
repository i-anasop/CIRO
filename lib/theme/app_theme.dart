// CIRO — Light Mode App Theme v3
// Assembles Flutter ThemeData for a premium light mobile experience.
// Inspired by clean consumer-grade mobile apps.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'spacing.dart';

class CiroTheme {
  CiroTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: CiroColors.bg1,

      colorScheme: const ColorScheme.light(
        primary:            CiroColors.brand,
        secondary:          CiroColors.brandAccent,
        surface:            CiroColors.bg3,
        error:              CiroColors.critical,
        onPrimary:          Colors.white,
        onSecondary:        Colors.white,
        onSurface:          CiroColors.textPrimary,
        onError:            Colors.white,
        primaryContainer:   CiroColors.bg4,
        onPrimaryContainer: CiroColors.textPrimary,
      ),

      // ── App Bar ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor:    CiroColors.bg1,
        foregroundColor:    CiroColors.textPrimary,
        elevation:          0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17, fontWeight: FontWeight.w700,
          color: CiroColors.textPrimary,
        ),
        iconTheme:        const IconThemeData(color: CiroColors.textSecondary, size: 22),
        actionsIconTheme: const IconThemeData(color: CiroColors.textSecondary),
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:      Colors.white,
        selectedItemColor:    CiroColors.brand,
        unselectedItemColor:  CiroColors.textMuted,
        type:                 BottomNavigationBarType.fixed,
        elevation:            0,
        selectedLabelStyle:   GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w500),
      ),

      // ── Card ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color:     CiroColors.bg3,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CiroSpacing.radiusXl),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: CiroColors.border, thickness: 1, space: 1,
      ),

      // ── Elevated Button (dark primary CTA — like reference images) ────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:          const Color(0xFF0F172A), // dark slate
          foregroundColor:          Colors.white,
          disabledBackgroundColor:  CiroColors.borderLight,
          disabledForegroundColor:  CiroColors.textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CiroSpacing.radiusXl),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── Outlined Button ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CiroColors.brand,
          side: const BorderSide(color: CiroColors.brand, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CiroSpacing.radiusXl),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Text Button ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CiroColors.brand,
          textStyle: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Input Decoration ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: CiroColors.bg4,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CiroSpacing.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CiroSpacing.radiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CiroSpacing.radiusLg),
          borderSide: const BorderSide(color: CiroColors.brand, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        labelStyle: GoogleFonts.inter(
            color: CiroColors.textSecondary, fontWeight: FontWeight.w500),
        hintStyle:  GoogleFonts.inter(color: CiroColors.textMuted),
      ),

      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor:  CiroColors.bg4,
        selectedColor:    CiroColors.brand.withValues(alpha: 0.12),
        labelStyle: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w500,
          color: CiroColors.textSecondary,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CiroSpacing.radiusCirc),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      ),

      // ── Switch ────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return CiroColors.brand;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CiroColors.brand.withValues(alpha: 0.5);
          }
          return CiroColors.border;
        }),
      ),

      // ── Text Theme ────────────────────────────────────────────────────────
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
        bodyColor:    CiroColors.textPrimary,
        displayColor: CiroColors.textPrimary,
      ),
    );
  }
}
