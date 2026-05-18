// CIRO — Agent Log Entry Component v3
// Chat/log-style timeline entry. Light mode redesign inspired by Image 2.

import 'package:flutter/material.dart';
import '../models/agent_log.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';

class AgentLogEntry extends StatelessWidget {
  final AgentLog log;
  final bool isLast;

  const AgentLogEntry({
    super.key,
    required this.log,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final levelColor = _levelColor();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 32,
            child: Column(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(_levelIcon(), size: 15, color: levelColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: CiroColors.border,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ]),
          ),

          const SizedBox(width: CiroSpacing.md),

          // Entry card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  bottom: isLast ? 0 : CiroSpacing.itemSpacing),
              padding: const EdgeInsets.all(CiroSpacing.cardPadding),
              decoration: BoxDecoration(
                color: CiroColors.bg3,
                borderRadius: BorderRadius.circular(CiroSpacing.radiusMd),
                boxShadow: CiroColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(children: [
                    Text(
                      log.agentLabel,
                      style: CiroTypography.labelLarge
                          .copyWith(color: levelColor),
                    ),
                    const Spacer(),
                    Text(_formatTime(log.timestamp),
                        style: CiroTypography.caption),
                  ]),
                  const SizedBox(height: CiroSpacing.xs),

                  // Summary
                  Text(log.summary,
                      style: CiroTypography.bodyMedium
                          .copyWith(color: CiroColors.textPrimary,
                              fontWeight: FontWeight.w500)),
                  if (log.detail.isNotEmpty) ...[
                    const SizedBox(height: CiroSpacing.xs),
                    Text(log.detail,
                        style: CiroTypography.bodySmall
                            .copyWith(color: CiroColors.textSecondary)),
                  ],

                  // Level pill
                  const SizedBox(height: CiroSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.08),
                      borderRadius:
                          BorderRadius.circular(CiroSpacing.radiusCirc),
                    ),
                    child: Text(
                      log.level.name.toUpperCase(),
                      style: CiroTypography.overline
                          .copyWith(color: levelColor, letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _levelColor() {
    switch (log.level) {
      case LogLevel.success: return CiroColors.success;
      case LogLevel.warning: return CiroColors.warning;
      case LogLevel.error:   return CiroColors.error;
      case LogLevel.info:    return CiroColors.brand;
    }
  }

  IconData _levelIcon() {
    switch (log.level) {
      case LogLevel.success: return Icons.check_circle_outline_rounded;
      case LogLevel.warning: return Icons.warning_amber_rounded;
      case LogLevel.error:   return Icons.cancel_outlined;
      case LogLevel.info:    return Icons.smart_toy_rounded;
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
