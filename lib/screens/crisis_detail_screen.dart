// CIRO — Crisis Detail Screen v3
// Shows the active scenario's full signal evidence, severity analysis,
// detection reasoning, and verification state — all from engine.
// crisis passed via extra (from engine.activeCrisis in all call sites).

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/crisis.dart';
import '../models/demo_scenario.dart';
import '../models/pipeline_result.dart';
import '../services/scenario_engine.dart';
import '../components/severity_badge.dart';
import '../components/premium_card.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';

class CrisisDetailScreen extends StatelessWidget {
  final Crisis crisis;
  const CrisisDetailScreen({super.key, required this.crisis});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ScenarioEngine.instance,
      builder: (context, _) {
        final engine   = ScenarioEngine.instance;
        final scenario = engine.activeScenario;
        final fusion   = engine.fusionPoints;
        final verif    = engine.verification;
        final sColor   = CiroColors.bySeverity(crisis.severityLabel);

        return Scaffold(
          backgroundColor: CiroColors.bg1,
          appBar: AppBar(
            title: Text(crisis.typeLabel),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.go('/home'),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: CiroSpacing.lg),
                child: SeverityBadge(label: crisis.severityLabel, withGlow: true),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(CiroSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero card ─────────────────────────────────────────────
                _buildHero(sColor),
                const SizedBox(height: CiroSpacing.md),

                // ── Severity analysis ─────────────────────────────────────
                PremiumCard(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sTitle(Icons.analytics_outlined, 'Severity Analysis'),
                    const SizedBox(height: CiroSpacing.md),
                    const Divider(height: 1, color: CiroColors.border),
                    const SizedBox(height: CiroSpacing.md),
                    _row('Severity',        crisis.severityLabel),
                    _row('Confidence',      '${crisis.confidencePercent.toInt()}%'),
                    _row('Affected People', '${crisis.affectedPeople} est.'),
                    if (crisis.estimatedDuration != null)
                      _row('Duration Est.', crisis.estimatedDuration!),
                    _row('Status',          crisis.statusLabel),
                    _row('Verification',    verif.label),
                  ],
                )),
                const SizedBox(height: CiroSpacing.md),

                // ── Signal evidence ───────────────────────────────────────
                PremiumCard(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sTitle(Icons.sensors_outlined,
                        'Signal Evidence (${scenario.activeSignals.length} sources)'),
                    const SizedBox(height: CiroSpacing.md),
                    const Divider(height: 1, color: CiroColors.border),
                    const SizedBox(height: CiroSpacing.md),
                    ...scenario.activeSignals.map((sig) => Padding(
                      padding: const EdgeInsets.only(bottom: CiroSpacing.sm),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: CiroColors.brandAccent,
                          ),
                        ),
                        const SizedBox(width: CiroSpacing.sm),
                        Expanded(child: Text(sig.content,
                            style: CiroTypography.bodyMedium)),
                      ]),
                    )),
                  ],
                )),
                const SizedBox(height: CiroSpacing.md),

                // ── Fusion summary ────────────────────────────────────────
                PremiumCard(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sTitle(Icons.merge_type_outlined, 'Fusion Agent Summary'),
                    const SizedBox(height: CiroSpacing.md),
                    const Divider(height: 1, color: CiroColors.border),
                    const SizedBox(height: CiroSpacing.md),
                    ...fusion.map((point) => Padding(
                      padding: const EdgeInsets.only(bottom: CiroSpacing.sm),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const Icon(Icons.chevron_right_rounded,
                            size: 14, color: CiroColors.brandAccent),
                        const SizedBox(width: 4),
                        Expanded(child: Text(point,
                            style: CiroTypography.bodyMedium)),
                      ]),
                    )),
                  ],
                )),
                const SizedBox(height: CiroSpacing.md),

                // ── Detection reasoning ───────────────────────────────────
                PremiumCard(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sTitle(Icons.psychology_outlined, 'Detection Reasoning'),
                    const SizedBox(height: CiroSpacing.md),
                    const Divider(height: 1, color: CiroColors.border),
                    const SizedBox(height: CiroSpacing.md),
                    Text(crisis.detectionReasoning,
                        style: CiroTypography.bodyMedium),
                  ],
                )),
                const SizedBox(height: CiroSpacing.md),

                // ── Verification state ────────────────────────────────────
                _buildVerifCard(verif),
                const SizedBox(height: CiroSpacing.md),

                // ── Likely evolution ──────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(CiroSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: CiroColors.warning.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(CiroSpacing.radiusMd),
                    border: Border.all(
                        color: CiroColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      const Icon(Icons.trending_up_rounded,
                          color: CiroColors.warning, size: 16),
                      const SizedBox(width: CiroSpacing.sm),
                      Text('Likely Evolution',
                          style: CiroTypography.labelLarge.copyWith(
                              color: CiroColors.warning)),
                    ]),
                    const SizedBox(height: CiroSpacing.sm),
                    Text(scenario.likelyEvolution,
                        style: CiroTypography.bodyMedium),
                  ]),
                ),

                const SizedBox(height: CiroSpacing.sectionSpacing),
                Row(children: [
                  Expanded(child: ElevatedButton.icon(
                    onPressed: () =>
                        context.go('/home/response-plan', extra: crisis),
                    icon: const Icon(Icons.assignment_outlined, size: 17),
                    label: const Text('Response Plan'),
                  )),
                  const SizedBox(width: CiroSpacing.sm),
                  Expanded(child: OutlinedButton.icon(
                    onPressed: () =>
                        context.go('/home/simulation', extra: crisis),
                    icon: const Icon(Icons.play_arrow_rounded, size: 17),
                    label: const Text('Simulation'),
                  )),
                ]),
                const SizedBox(height: CiroSpacing.xxxl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHero(Color sColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CiroSpacing.cardPaddingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [sColor.withValues(alpha: 0.12), CiroColors.bg3],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(CiroSpacing.radiusLg),
        border: Border.all(color: sColor.withValues(alpha: 0.3)),
        boxShadow: CiroColors.cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: sColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(CiroSpacing.radiusSm),
            ),
            child: Icon(_crisisIcon(), size: 22, color: sColor),
          ),
          const SizedBox(width: CiroSpacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(crisis.title,
                style: CiroTypography.headingLarge,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 12,
                  color: CiroColors.textMuted),
              const SizedBox(width: 2),
              Text(crisis.location, style: CiroTypography.bodySmall),
            ]),
          ])),
        ]),
        const SizedBox(height: CiroSpacing.md),
        Row(children: [
          SeverityBadge(label: crisis.severityLabel, withGlow: true),
          const SizedBox(width: CiroSpacing.sm),
          ConfidencePill(percent: crisis.confidencePercent),
          const SizedBox(width: CiroSpacing.sm),
          StatusPill(status: crisis.statusLabel),
        ]),
        const SizedBox(height: CiroSpacing.md),
        Row(children: [
          const Icon(Icons.people_outline, size: 13, color: CiroColors.textMuted),
          const SizedBox(width: 4),
          Text('${crisis.affectedPeople.toStringAsFixed(0)} people est.',
              style: CiroTypography.bodySmall),
          const SizedBox(width: CiroSpacing.lg),
          const Icon(Icons.schedule_outlined, size: 13, color: CiroColors.textMuted),
          const SizedBox(width: 4),
          Text(crisis.detectedAtLabel,
            style: CiroTypography.bodySmall),
        ]),
      ]),
    );
  }

  Widget _buildVerifCard(VerificationDecision verif) {
    final verifColor = _verifColor(verif.type);
    return Container(
      padding: const EdgeInsets.all(CiroSpacing.cardPadding),
      decoration: BoxDecoration(
        color: verifColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(CiroSpacing.radiusMd),
        border: Border.all(color: verifColor.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.verified_outlined, color: verifColor, size: 16),
          const SizedBox(width: CiroSpacing.sm),
          Text(verif.label,
              style: CiroTypography.labelLarge.copyWith(color: verifColor)),
        ]),
        const SizedBox(height: CiroSpacing.sm),
        Text(verif.note, style: CiroTypography.bodyMedium),
      ]),
    );
  }

  Widget _sTitle(IconData icon, String title) => Row(children: [
    Icon(icon, size: 16, color: CiroColors.brandAccent),
    const SizedBox(width: CiroSpacing.sm),
    Text(title, style: CiroTypography.headingSmall),
  ]);

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: CiroSpacing.sm),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: CiroTypography.bodyMedium),
      Text(value, style: CiroTypography.labelLarge),
    ]),
  );

  IconData _crisisIcon() {
    switch (crisis.type) {
      case CrisisType.urbanFlooding: return Icons.water_drop_outlined;
      case CrisisType.roadBlockage:  return Icons.traffic_outlined;
      case CrisisType.accident:      return Icons.car_crash_outlined;
      case CrisisType.heatwave:      return Icons.thermostat_outlined;
      case CrisisType.powerOutage:   return Icons.power_off_outlined;
    }
  }

  Color _verifColor(VerificationType verType) {
    switch (verType) {
      case VerificationType.confirmed:          return CiroColors.success;
      case VerificationType.needsVerification:  return CiroColors.warning;
      case VerificationType.conflictingSignals: return CiroColors.high;
      case VerificationType.falsePositiveRisk:  return CiroColors.critical;
      case VerificationType.escalationRequired: return CiroColors.brandAccent;
    }
  }
}
