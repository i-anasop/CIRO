// CIRO — Agent Message Card Component
// Chat/log-style card inspired by Image 2 (AI assistant UI).
// Shows agent icon bubble, agent name, decision text, confidence, timestamp.

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';

class AgentMessageCard extends StatelessWidget {
  final IconData agentIcon;
  final String agentName;
  final String decisionSummary;
  final double? confidence;
  final String timestamp;
  final Color? accentColor;
  final bool isFirst;
  final bool isLast;

  const AgentMessageCard({
    super.key,
    required this.agentIcon,
    required this.agentName,
    required this.decisionSummary,
    this.confidence,
    required this.timestamp,
    this.accentColor,
    this.isFirst = false,
    this.isLast  = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? CiroColors.brand;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Timeline connector ───────────────────────────────────────────────
        Column(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(agentIcon, color: color, size: 18),
            ),
            if (!isLast)
              Container(
                width: 1.5, height: 28,
                color: CiroColors.border,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: CiroSpacing.md),

        // ── Message bubble ───────────────────────────────────────────────────
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: CiroSpacing.md),
            padding: const EdgeInsets.all(CiroSpacing.cardPadding),
            decoration: BoxDecoration(
              color: CiroColors.bg3,
              borderRadius: BorderRadius.circular(CiroSpacing.radiusMd),
              boxShadow: CiroColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Agent name + timestamp row
                Row(children: [
                  Text(agentName,
                      style: CiroTypography.labelLarge
                          .copyWith(color: color)),
                  const Spacer(),
                  Text(timestamp, style: CiroTypography.caption),
                ]),
                const SizedBox(height: CiroSpacing.xs),

                // Decision
                Text(decisionSummary,
                    style: CiroTypography.bodyMedium
                        .copyWith(color: CiroColors.textSecondary)),

                // Confidence pill
                if (confidence != null) ...[
                  const SizedBox(height: CiroSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(CiroSpacing.radiusCirc),
                    ),
                    child: Text(
                      'Confidence: ${(confidence! * 100).toInt()}%',
                      style: CiroTypography.overline.copyWith(color: color),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
