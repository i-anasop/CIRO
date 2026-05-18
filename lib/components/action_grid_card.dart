// CIRO — Action Grid Card Component
// 2×2 quick action tile with pastel background, icon, label.
// Used on Home Dashboard for Map / Response Plan / Report / Agent Trace.

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';

class ActionGridCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const ActionGridCard({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(CiroSpacing.cardPadding),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(CiroSpacing.radiusLg),
          boxShadow: CiroColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(CiroSpacing.radiusSm),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: CiroSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: CiroTypography.labelLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: CiroTypography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
