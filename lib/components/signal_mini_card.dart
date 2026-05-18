// CIRO — Signal Mini Card Component
// Compact horizontal card showing one signal source (Weather/Traffic/News).
// Shows icon, label, status, and a risk color dot.

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';

class SignalMiniCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final String detail;
  final Color iconColor;
  final Color bgColor;
  final Color? riskColor;

  const SignalMiniCard({
    super.key,
    required this.icon,
    required this.label,
    required this.status,
    required this.detail,
    required this.iconColor,
    required this.bgColor,
    this.riskColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(CiroSpacing.radiusLg),
        boxShadow: CiroColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(CiroSpacing.radiusSm),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              if (riskColor != null)
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: riskColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: CiroSpacing.sm),
          Text(label, style: CiroTypography.labelSmall),
          const SizedBox(height: 2),
          Text(status,
              style: CiroTypography.labelMedium.copyWith(
                  color: CiroColors.textPrimary, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(detail,
              style: CiroTypography.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
