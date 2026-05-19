// CIRO — Simulation Screen v3
// Reads SimulationResult from ScenarioEngine.instance.simulation.
// Includes possible side effects and verification state.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/crisis.dart';
import '../models/demo_scenario.dart';
import '../models/pipeline_result.dart';
import '../models/simulation_result.dart';
import '../services/scenario_engine.dart';
import '../components/metric_delta.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';

class SimulationScreen extends StatefulWidget {
  final Crisis crisis;
  const SimulationScreen({super.key, required this.crisis});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset>  _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ScenarioEngine.instance,
      builder: (context, _) {
        final engine   = ScenarioEngine.instance;
        final sim      = engine.simulation;
        final scenario = engine.activeScenario;
        final verif    = engine.verification;

        return Scaffold(
          backgroundColor: CiroColors.bg1,
          appBar: AppBar(
            title: const Text('Expected Impact'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () =>
                  context.go('/home/response-plan', extra: widget.crisis),
            ),
          ),
          body: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(CiroSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Success banner ─────────────────────────────────────
                    _buildBanner(sim, scenario),
                    const SizedBox(height: CiroSpacing.sectionSpacing),

                    // ── Before / After metrics ─────────────────────────────
                    Text('Before / After',
                        style: CiroTypography.headingMedium),
                    const SizedBox(height: 4),
                    Text('What should improve after the response starts.',
                        style: CiroTypography.bodyMedium),
                    const SizedBox(height: CiroSpacing.md),
                    ...sim.metrics.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: CiroSpacing.md),
                      child: MetricDelta(
                        label: m.label,
                        before: m.before,
                        after: m.after,
                        delta: m.delta,
                        isImprovement: m.isImprovement,
                      ),
                    )),

                    // ── Verification state ─────────────────────────────────
                    const SizedBox(height: CiroSpacing.sectionSpacing),
                    Text('Safety Check',
                        style: CiroTypography.headingMedium),
                    const SizedBox(height: CiroSpacing.md),
                    _buildVerification(verif),

                    // ── Side effects ───────────────────────────────────────
                    if (scenario.possibleSideEffects.isNotEmpty) ...[
                      const SizedBox(height: CiroSpacing.sectionSpacing),
                      Text('Possible Side Effects',
                          style: CiroTypography.headingMedium),
                      const SizedBox(height: CiroSpacing.md),
                      _buildSideEffects(scenario.possibleSideEffects),
                    ],

                    // ── Simulation timeline ────────────────────────────────
                    const SizedBox(height: CiroSpacing.sectionSpacing),
                    Text('Action Timeline',
                        style: CiroTypography.headingMedium),
                    const SizedBox(height: CiroSpacing.md),
                    ...sim.actions.asMap().entries.map((e) =>
                        _TimelineTile(
                          action: e.value.title,
                          result: e.value.resultSummary ??
                              'Action ${e.key + 1} simulated successfully.',
                          status: e.value.status,
                          isLast: e.key == sim.actions.length - 1,
                        )),

                    const SizedBox(height: CiroSpacing.sectionSpacing),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/logs'),
                        icon: const Icon(Icons.account_tree_outlined, size: 17),
                        label: const Text('Why CIRO Says This'),
                      ),
                    ),
                    const SizedBox(height: CiroSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBanner(SimulationResult sim, DemoScenario scenario) {
    final firstMetric = sim.metrics.isNotEmpty ? sim.metrics.first : null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CiroSpacing.cardPaddingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CiroColors.success.withValues(alpha: 0.12), CiroColors.bg3],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(CiroSpacing.radiusLg),
        border: Border.all(color: CiroColors.success.withValues(alpha: 0.3)),
        boxShadow: CiroColors.cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CiroColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(CiroSpacing.radiusSm),
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: CiroColors.success, size: 18),
          ),
          const SizedBox(width: CiroSpacing.sm),
          Text('Impact Estimate Ready',
              style: CiroTypography.headingSmall.copyWith(
                  color: CiroColors.success)),
        ]),
        const SizedBox(height: CiroSpacing.sm),
        Text(
          '${sim.actions.length} response actions checked. '
          '${sim.metrics.length} expected improvements prepared for ${scenario.location}.',
          style: CiroTypography.bodyMedium,
        ),
        if (firstMetric != null) ...[
          const SizedBox(height: CiroSpacing.md),
          Row(children: [
            _miniStat(firstMetric.label,
                '${firstMetric.before} → ${firstMetric.after}',
                CiroColors.success),
            const SizedBox(width: CiroSpacing.sm),
            _miniStat('Risk',
                '${widget.crisis.severityLabel} → Improving',
                CiroColors.warning),
            const SizedBox(width: CiroSpacing.sm),
            _miniStat('Review', 'Ready', CiroColors.brandAccent),
          ]),
        ],
      ]),
    );
  }

  Widget _buildVerification(VerificationDecision verif) {
    final color = _verifColor(verif.type);
    return Container(
      padding: const EdgeInsets.all(CiroSpacing.cardPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(CiroSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(verif.label,
            style: CiroTypography.labelLarge.copyWith(color: color)),
        const SizedBox(height: CiroSpacing.sm),
        Text(verif.note, style: CiroTypography.bodyMedium),
      ]),
    );
  }

  Widget _buildSideEffects(List<String> effects) {
    return Container(
      padding: const EdgeInsets.all(CiroSpacing.cardPadding),
      decoration: BoxDecoration(
        color: CiroColors.warning.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(CiroSpacing.radiusMd),
        border: Border.all(color: CiroColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(children: effects.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: CiroSpacing.xs),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.warning_amber_rounded,
              size: 14, color: CiroColors.warning),
          const SizedBox(width: CiroSpacing.sm),
          Expanded(child: Text(e, style: CiroTypography.bodyMedium)),
        ]),
      )).toList()),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(CiroSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(CiroSpacing.radiusSm),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(children: [
          Text(value,
              style: CiroTypography.labelLarge.copyWith(color: color),
              textAlign: TextAlign.center,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(label, style: CiroTypography.bodySmall, textAlign: TextAlign.center),
        ]),
      ),
    );
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

class _TimelineTile extends StatelessWidget {
  final String action, result, status;
  final bool isLast;
  const _TimelineTile({
    required this.action, required this.result,
    required this.status, this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = status == 'Completed' ? CiroColors.success
        : status == 'In Progress' ? CiroColors.warning : CiroColors.textMuted;
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 24, child: Column(children: [
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: color,
              boxShadow: [BoxShadow(
                color: color.withValues(alpha: 0.5), blurRadius: 6)],
            ),
            child: const Icon(Icons.check, size: 8, color: Colors.white),
          ),
          if (!isLast)
            Expanded(child: Container(
              width: 1.5, color: CiroColors.border,
              margin: const EdgeInsets.symmetric(vertical: 4),
            )),
        ])),
        const SizedBox(width: CiroSpacing.sm),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : CiroSpacing.sm),
            padding: const EdgeInsets.all(CiroSpacing.md),
            decoration: BoxDecoration(
              color: CiroColors.bg3,
              borderRadius: BorderRadius.circular(CiroSpacing.radiusSm),
              border: Border.all(color: CiroColors.border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(action, style: CiroTypography.labelLarge),
              const SizedBox(height: 4),
              Text(result, style: CiroTypography.bodySmall
                  .copyWith(color: color)),
            ]),
          ),
        ),
      ]),
    );
  }
}
