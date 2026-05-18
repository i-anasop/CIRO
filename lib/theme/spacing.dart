// CIRO — Premium Spacing & Radius Design Tokens v3
// Increased card radii (22–28) for premium mobile feel per AGENTS.md §8 revamp.

class CiroSpacing {
  CiroSpacing._();

  // ── Base scale ─────────────────────────────────────────────────────────────
  static const double xxs  = 2.0;
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double xxl  = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;

  // ── Semantic layout ────────────────────────────────────────────────────────
  static const double screenPadding    = 20.0;
  static const double screenPaddingTop = 8.0;
  static const double cardPadding      = 18.0;
  static const double cardPaddingLg    = 22.0;
  static const double sectionSpacing   = 24.0;
  static const double itemSpacing      = 12.0;

  // ── Border radius (premium large) ──────────────────────────────────────────
  static const double radiusXs   = 8.0;    // Chips, micro-badges
  static const double radiusSm   = 12.0;   // Small elements
  static const double radiusMd   = 18.0;   // Standard card
  static const double radiusLg   = 22.0;   // Large card / hero card
  static const double radiusXl   = 28.0;   // Bottom sheet / modal / CTA button
  static const double radiusCirc = 999.0;  // Full pill

  // Aliases kept for backward compat
  static const double cardBorderRadius  = radiusMd;
  static const double badgeBorderRadius = radiusXs;
  static const double chipBorderRadius  = radiusCirc;
}
