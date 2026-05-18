// CIRO — Metric Delta Component v3
// Before/After metric comparison cards for Simulation screen.
// Light mode redesign with progress bar indicators.

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';

/// A single before/after metric card.
class MetricDelta extends StatelessWidget {
  final String label;
  final String before;
  final String after;
  final String delta;
  final bool isImprovement; // true = green arrow, false = red/warn arrow

  const MetricDelta({
    super.key,
    required this.label,
    required this.before,
    required this.after,
    required this.delta,
    required this.isImprovement,
  });

  @override
  Widget build(BuildContext context) {
    final deltaColor = isImprovement ? CiroColors.success : CiroColors.critical;
    final deltaIcon  = isImprovement ? Icons.arrow_downward_rounded
                                     : Icons.arrow_upward_rounded;

    return Container(
      padding: const EdgeInsets.all(CiroSpacing.cardPadding),
      decoration: BoxDecoration(
        color: CiroColors.bg3,
        borderRadius: BorderRadius.circular(CiroSpacing.radiusMd),
        boxShadow: CiroColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: CiroTypography.labelSmall),
          const SizedBox(height: CiroSpacing.sm),
          Row(
            children: [
              // Before
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Before', style: CiroTypography.caption),
                Text(before, style: CiroTypography.numericSmall
                    .copyWith(color: CiroColors.critical, fontSize: 15)),
              ]),
              const SizedBox(width: CiroSpacing.md),
              // Arrow
              const Icon(Icons.east_rounded, size: 16, color: CiroColors.textMuted),
              const SizedBox(width: CiroSpacing.md),
              // After
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('After', style: CiroTypography.caption),
                Text(after, style: CiroTypography.numericSmall
                    .copyWith(color: CiroColors.success, fontSize: 15)),
              ]),
              const Spacer(),
              // Delta pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: deltaColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(CiroSpacing.radiusCirc),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(deltaIcon, size: 11, color: deltaColor),
                  const SizedBox(width: 3),
                  Text(delta,
                      style: CiroTypography.overline
                          .copyWith(color: deltaColor)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
