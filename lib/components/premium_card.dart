// CIRO — Premium Card Component v3
// White card with soft shadow, large radius, optional accent bar.
// Light mode optimized.

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? borderRadius;
  final Color? accentColor;   // Optional left accent bar
  final bool hasShadow;
  final VoidCallback? onTap;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.accentColor,
    this.hasShadow = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? CiroSpacing.radiusLg;
    final content = Container(
      padding: padding ?? const EdgeInsets.all(CiroSpacing.cardPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? CiroColors.bg3,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: hasShadow ? CiroColors.cardShadow : null,
      ),
      child: accentColor != null
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: double.infinity,
                  constraints: const BoxConstraints(minHeight: 40),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  margin: const EdgeInsets.only(right: 14),
                ),
                Expanded(child: child),
              ],
            )
          : child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}
