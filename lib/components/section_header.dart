// CIRO — Section Header Component v3
// Clean dark text section header with optional action link.
// Light mode optimized — no border separator.

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Text(title, style: CiroTypography.headingMedium),
          const Spacer(),
          if (trailing case final Widget t) t,
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: CiroTypography.labelSmall.copyWith(
                  color: CiroColors.brand,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
