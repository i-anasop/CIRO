// CIRO — Crisis Card Component v3
// White card with severity accent bar, clean hierarchy.
// Light mode optimized.

import 'package:flutter/material.dart';
import '../models/crisis.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import 'severity_badge.dart';

class CrisisCard extends StatelessWidget {
  final Crisis crisis;
  final VoidCallback? onTap;

  const CrisisCard({super.key, required this.crisis, this.onTap});

  @override
  Widget build(BuildContext context) {
    final severityColor = CiroColors.bySeverity(crisis.severityLabel);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: CiroColors.bg3,
          borderRadius: BorderRadius.circular(CiroSpacing.radiusLg),
          boxShadow: CiroColors.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Severity accent bar
            Container(
              width: 5,
              color: severityColor,
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(CiroSpacing.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: icon + title + badge
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: severityColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(CiroSpacing.radiusSm),
                        ),
                        child: Icon(_crisisIcon(crisis.type),
                            color: severityColor, size: 18),
                      ),
                      const SizedBox(width: CiroSpacing.md),
                      Expanded(
                        child: Text(crisis.title,
                            style: CiroTypography.headingSmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: CiroSpacing.sm),
                      SeverityBadge(severity: crisis.severityLabel),
                    ]),

                    const SizedBox(height: CiroSpacing.sm),

                    // Row 2: location + time
                    Row(children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: CiroColors.textMuted),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(crisis.location,
                            style: CiroTypography.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const Icon(Icons.schedule_outlined,
                          size: 12, color: CiroColors.textMuted),
                      const SizedBox(width: 3),
                      Text(crisis.detectedAtLabel,
                          style: CiroTypography.caption),
                    ]),

                    const SizedBox(height: CiroSpacing.sm),

                    // Row 3: confidence + status + arrow
                    Row(children: [
                      _metricPill(
                          '${crisis.confidence}%', Icons.analytics_outlined,
                          CiroColors.brand),
                      const SizedBox(width: CiroSpacing.sm),
                      _statusPill(crisis.statusLabel),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: CiroColors.textMuted),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricPill(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(CiroSpacing.radiusCirc),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: CiroTypography.overline
                .copyWith(color: color, letterSpacing: 0.3)),
      ]),
    );
  }

  Widget _statusPill(String label) {
    Color c;
    switch (label.toLowerCase()) {
      case 'active':      c = CiroColors.critical; break;
      case 'monitoring':  c = CiroColors.warning;  break;
      case 'resolved':    c = CiroColors.success;  break;
      default:            c = CiroColors.textMuted; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(CiroSpacing.radiusCirc),
      ),
      child: Text(label,
          style: CiroTypography.overline
              .copyWith(color: c, letterSpacing: 0.3)),
    );
  }

  IconData _crisisIcon(CrisisType type) {
    switch (type) {
      case CrisisType.urbanFlooding:       return Icons.water_rounded;
      case CrisisType.roadBlockage:        return Icons.traffic_rounded;
      case CrisisType.accident:            return Icons.car_crash_rounded;
      case CrisisType.heatwave:            return Icons.thermostat_rounded;
      case CrisisType.powerOutage:         return Icons.bolt_rounded;
    }
  }
}
