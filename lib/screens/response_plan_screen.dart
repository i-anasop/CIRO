// CIRO — Response Plan Screen v3
// Reads plan from ScenarioEngine.instance.responsePlan.
// Falls back to engine data if no crisis passed via extra.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/crisis.dart';
import '../models/demo_scenario.dart';
import '../services/scenario_engine.dart';
import '../components/severity_badge.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';

class ResponsePlanScreen extends StatelessWidget {
  final Crisis crisis;
  const ResponsePlanScreen({super.key, required this.crisis});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ScenarioEngine.instance,
      builder: (context, _) {
        final plan = ScenarioEngine.instance.responsePlan;

        return Scaffold(
          backgroundColor: CiroColors.bg1,
          appBar: AppBar(
            title: const Text('Response Plan'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.go('/home/crisis-detail', extra: crisis),
            ),
          ),
          body: Column(children: [
            // ── Context strip ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: CiroSpacing.screenPadding,
                  vertical: CiroSpacing.md),
              decoration: const BoxDecoration(
                color: CiroColors.bg2,
                border: Border(bottom: BorderSide(color: CiroColors.border)),
              ),
              child: Row(children: [
                const Icon(Icons.assignment_turned_in_outlined,
                    color: CiroColors.brandAccent, size: 18),
                const SizedBox(width: CiroSpacing.sm),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(crisis.title,
                        style: CiroTypography.labelLarge,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('${plan.length} coordinated actions · AI-generated',
                        style: CiroTypography.bodySmall),
                  ],
                )),
                SeverityBadge(label: crisis.severityLabel),
              ]),
            ),

            // ── Resource summary ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: CiroSpacing.screenPadding,
                  vertical: CiroSpacing.md),
              decoration: const BoxDecoration(
                color: CiroColors.bg2,
                border: Border(bottom: BorderSide(color: CiroColors.border)),
              ),
              child: Row(children: [
                const Icon(Icons.emergency_share_outlined,
                    color: CiroColors.warning, size: 14),
                const SizedBox(width: CiroSpacing.sm),
                Expanded(child: Text(
                  ScenarioEngine.instance.resources.summary,
                  style: CiroTypography.bodySmall,
                )),
              ]),
            ),

            // ── Action list ─────────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(CiroSpacing.screenPadding),
                itemCount: plan.length,
                itemBuilder: (context, i) => _ActionTile(action: plan[i]),
              ),
            ),

            // ── CTA ────────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(CiroSpacing.screenPadding),
              decoration: const BoxDecoration(
                color: CiroColors.bg2,
                border: Border(top: BorderSide(color: CiroColors.border)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      context.go('/home/simulation', extra: crisis),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Run Simulation & View Outcomes'),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  final PlanAction action;
  const _ActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final prioColor = action.priority == 'P1' ? CiroColors.critical
        : action.priority == 'P2' ? CiroColors.warning : CiroColors.textMuted;
    final statusColor = _sColor(action.status);

    return Container(
      margin: const EdgeInsets.only(bottom: CiroSpacing.md),
      decoration: BoxDecoration(
        color: CiroColors.bg3,
        borderRadius: BorderRadius.circular(CiroSpacing.radiusMd),
        border: Border.all(color: CiroColors.border),
        boxShadow: CiroColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(CiroSpacing.cardPadding),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Step circle
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: CiroColors.brand.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: CiroColors.brand.withValues(alpha: 0.3)),
            ),
            child: Center(child: Text('${action.step}',
                style: CiroTypography.labelLarge.copyWith(
                    color: CiroColors.brand))),
          ),
          const SizedBox(width: CiroSpacing.md),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(action.title,
                    style: CiroTypography.labelLarge)),
                const SizedBox(width: CiroSpacing.sm),
                _chip(action.priority, prioColor),
                const SizedBox(width: CiroSpacing.xs),
                _chip(action.status, statusColor),
              ]),
              const SizedBox(height: CiroSpacing.xs),
              Row(children: [
                const Icon(Icons.business_outlined,
                    size: 11, color: CiroColors.textMuted),
                const SizedBox(width: 3),
                Expanded(child: Text(action.department,
                    style: CiroTypography.bodySmall,
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                const Icon(Icons.schedule_outlined,
                    size: 11, color: CiroColors.textMuted),
                const SizedBox(width: 3),
                Text('ETA ${action.eta}', style: CiroTypography.bodySmall),
              ]),
              const SizedBox(height: CiroSpacing.sm),
              Text(action.description, style: CiroTypography.bodyMedium),
              if (action.resultSummary != null) ...[
                const SizedBox(height: CiroSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(CiroSpacing.sm),
                  decoration: BoxDecoration(
                    color: CiroColors.success.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(CiroSpacing.radiusSm),
                    border: Border.all(
                        color: CiroColors.success.withValues(alpha: 0.2)),
                  ),
                  child: Text(action.resultSummary!,
                      style: CiroTypography.bodySmall.copyWith(
                          color: CiroColors.success)),
                ),
              ],
            ],
          )),
        ]),
      ),
    );
  }

  Color _sColor(String s) {
    switch (s) {
      case 'Completed':   return CiroColors.success;
      case 'In Progress': return CiroColors.warning;
      default:            return CiroColors.textMuted;
    }
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(CiroSpacing.radiusXs),
      ),
      child: Text(label,
          style: CiroTypography.overline.copyWith(color: color)),
    );
  }
}
