// CIRO — Severity Badge Component v3
// Light mode optimized severity pills.
// Accepts both 'severity' and 'label' for backward compatibility.
// 'withGlow' is ignored in light mode (no glow effect).
// Severity colors unchanged per AGENTS.md §8.

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';

class SeverityBadge extends StatelessWidget {
  // 'severity' is the primary param (new API); 'label' is the old API alias.
  final String? severity;
  final String? label;
  final bool compact;
  // 'withGlow' accepted for backward-compat but ignored in light mode.
  final bool withGlow;

  const SeverityBadge({
    super.key,
    this.severity,
    this.label,
    this.compact = false,
    this.withGlow = false,
  }) : assert(severity != null || label != null,
            'Provide either severity or label');

  String get _severity => (severity ?? label ?? 'unknown').toLowerCase();

  @override
  Widget build(BuildContext context) {
    final color = CiroColors.bySeverity(_severity);
    final text  = _severity.toUpperCase();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical:   compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(CiroSpacing.radiusCirc),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width:  compact ? 5 : 6,
            height: compact ? 5 : 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: compact ? 4 : 5),
          Text(
            text,
            style: CiroTypography.badge.copyWith(
              color: color,
              fontSize: compact ? 9 : 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// Confidence percentage pill (companion to SeverityBadge).
class ConfidencePill extends StatelessWidget {
  final double percent;
  const ConfidencePill({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    final value = percent > 1 ? percent.toInt() : (percent * 100).toInt();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CiroColors.brand.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(CiroSpacing.radiusCirc),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.analytics_outlined,
            size: 11, color: CiroColors.brand),
        const SizedBox(width: 4),
        Text('$value%',
            style: CiroTypography.overline
                .copyWith(color: CiroColors.brand)),
      ]),
    );
  }
}

/// Status pill (Active / Monitoring / Resolved / Needs Verification).
class StatusPill extends StatelessWidget {
  final String status;
  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color c;
    switch (status.toLowerCase()) {
      case 'active':      c = CiroColors.critical;     break;
      case 'monitoring':  c = CiroColors.warning;      break;
      case 'resolved':    c = CiroColors.success;      break;
      case 'needs verification': c = CiroColors.brandAccent; break;
      default:            c = CiroColors.textMuted;    break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(CiroSpacing.radiusCirc),
      ),
      child: Text(status,
          style: CiroTypography.overline.copyWith(color: c, letterSpacing: 0.3)),
    );
  }
}

/// Simple severity dot indicator (no text).
class SeverityDot extends StatelessWidget {
  final String severity;
  final double size;
  const SeverityDot({super.key, required this.severity, this.size = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: CiroColors.bySeverity(severity),
        shape: BoxShape.circle,
      ),
    );
  }
}
