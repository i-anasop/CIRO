// CIRO — Demo Scenarios Screen v3
// Hackathon presentation screen. Tap scenario → engine activates it
// → navigate to Dashboard which auto-updates.
// Shows all 5 scenarios with full metadata, verification state, and sources.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/scenario_engine.dart';
import '../models/demo_scenario.dart';
import '../models/crisis.dart';
import '../models/signal.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import '../components/severity_badge.dart';

class DemoScenariosScreen extends StatefulWidget {
  const DemoScenariosScreen({super.key});

  @override
  State<DemoScenariosScreen> createState() => _DemoScenariosScreenState();
}

class _DemoScenariosScreenState extends State<DemoScenariosScreen> {
  bool _loading = false;
  String? _activatingId;

  Future<void> _activate(BuildContext ctx, DemoScenario s) async {
    setState(() {
      _loading = true;
      _activatingId = s.id;
    });

    await ScenarioEngine.instance.selectScenario(s.id);

    if (!ctx.mounted) return;
    setState(() {
      _loading = false;
      _activatingId = null;
    });

    ctx.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ScenarioEngine.instance,
      builder: (context, _) {
        final engine = ScenarioEngine.instance;
        final scenarios = engine.allScenarios;

        return Scaffold(
          backgroundColor: CiroColors.bg1,
          appBar: AppBar(
            title: const Text('Demo Stories'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.go('/home'),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(CiroSpacing.screenPadding),
            children: [
              // ── Header ────────────────────────────────────────────────────
              Text('Choose a Demo Story', style: CiroTypography.headingMedium),
              const SizedBox(height: 4),
              Text(
                'Tap "Start" to load a situation. '
                'The entire app updates with that crisis context.',
                style: CiroTypography.bodyMedium,
              ),
              const SizedBox(height: CiroSpacing.sectionSpacing),

              // ── Scenario cards ────────────────────────────────────────────
              ...scenarios.map((s) {
                final sColor = CiroColors.bySeverity(
                  _severityLabel(s.severity),
                );
                final isActive = engine.activeScenarioId == s.id;
                final isLoading = _loading && _activatingId == s.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: CiroSpacing.md),
                  decoration: BoxDecoration(
                    color: CiroColors.bg3,
                    borderRadius: BorderRadius.circular(CiroSpacing.radiusLg),
                    border: Border.all(
                      color: isActive
                          ? CiroColors.brandAccent
                          : CiroColors.border,
                      width: isActive ? 1.5 : 1,
                    ),
                    boxShadow: isActive
                        ? CiroColors.glowCyan
                        : CiroColors.cardShadow,
                  ),
                  child: Column(
                    children: [
                      // Severity top strip
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: sColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(CiroSpacing.radiusLg),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(
                          CiroSpacing.cardPaddingLg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tag + active badge
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CiroColors.brand.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      CiroSpacing.radiusXs,
                                    ),
                                  ),
                                  child: Text(
                                    s.id,
                                    style: CiroTypography.overline.copyWith(
                                      color: CiroColors.brandAccent,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: CiroSpacing.sm),
                                if (isActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: CiroColors.success.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        CiroSpacing.radiusXs,
                                      ),
                                    ),
                                    child: Text(
                                      'ACTIVE',
                                      style: CiroTypography.overline.copyWith(
                                        color: CiroColors.success,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: CiroSpacing.md),

                            // Title + location
                            Text(s.title, style: CiroTypography.headingSmall),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 12,
                                  color: CiroColors.textMuted,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  s.location,
                                  style: CiroTypography.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: CiroSpacing.md),

                            // Severity + confidence + verification
                            Wrap(
                              spacing: CiroSpacing.sm,
                              runSpacing: CiroSpacing.sm,
                              children: [
                                SeverityBadge(
                                  label: _severityLabel(s.severity),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CiroColors.brandAccent.withValues(
                                      alpha: 0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      CiroSpacing.radiusXs,
                                    ),
                                  ),
                                  child: Text(
                                    '${s.confidence.toInt()}% conf.',
                                    style: CiroTypography.overline.copyWith(
                                      color: CiroColors.brandAccent,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _verificationColor(
                                      s.verificationType,
                                    ).withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(
                                      CiroSpacing.radiusXs,
                                    ),
                                  ),
                                  child: Text(
                                    s.verificationLabel,
                                    style: CiroTypography.overline.copyWith(
                                      color: _verificationColor(
                                        s.verificationType,
                                      ),
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: CiroSpacing.sm),

                            // Sources + affected
                            Row(
                              children: [
                                const Icon(
                                  Icons.sensors_outlined,
                                  size: 12,
                                  color: CiroColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${s.activeSignals.length} sources · '
                                  '${s.activeSignals.map((e) => _srcShort(e.source)).join(", ")}',
                                  style: CiroTypography.bodySmall,
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.people_outline,
                                  size: 12,
                                  color: CiroColors.textMuted,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${_fmt(s.affectedPopulation)} affected',
                                  style: CiroTypography.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: CiroSpacing.md),

                            // Launch button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () => _activate(context, s),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isActive
                                      ? CiroColors.success
                                      : CiroColors.brand,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Icon(
                                        isActive
                                            ? Icons.check_rounded
                                            : Icons.play_arrow_rounded,
                                        size: 17,
                                      ),
                                label: Text(
                                  isLoading
                                      ? 'Preparing story...'
                                      : isActive
                                      ? 'Currently Active'
                                      : 'Start Demo',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // ── False signal demo note ─────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(CiroSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: CiroColors.warning.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(CiroSpacing.radiusMd),
                  border: Border.all(
                    color: CiroColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: CiroColors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: CiroSpacing.sm),
                        Text(
                          'False Signal Handling',
                          style: CiroTypography.labelLarge.copyWith(
                            color: CiroColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: CiroSpacing.sm),
                    Text(
                      '• Power Outage (SCN-004) activates ⚠️ Needs Verification — '
                      'single social source, sensor is primary evidence.\n'
                      '• In Agent Logs, look for ⚡ Conflicting Signals and '
                      '🔴 False Positive cases across completed runs.',
                      style: CiroTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: CiroSpacing.xxxl),
            ],
          ),
        );
      },
    );
  }

  String _severityLabel(SeverityLevel s) {
    switch (s) {
      case SeverityLevel.critical:
        return 'Critical';
      case SeverityLevel.high:
        return 'High';
      case SeverityLevel.moderate:
        return 'Moderate';
      case SeverityLevel.low:
        return 'Low';
      case SeverityLevel.unknown:
        return 'Unknown';
    }
  }

  Color _verificationColor(VerificationType v) {
    switch (v) {
      case VerificationType.confirmed:
        return CiroColors.success;
      case VerificationType.needsVerification:
        return CiroColors.warning;
      case VerificationType.conflictingSignals:
        return CiroColors.high;
      case VerificationType.falsePositiveRisk:
        return CiroColors.critical;
      case VerificationType.escalationRequired:
        return CiroColors.brandAccent;
    }
  }

  String _srcShort(SignalSource s) {
    switch (s) {
      case SignalSource.socialPost:
        return 'Social';
      case SignalSource.weatherAlert:
        return 'Weather';
      case SignalSource.trafficData:
        return 'Traffic';
      case SignalSource.mockSensor:
        return 'Sensor';
      default:
        return 'Other';
    }
  }

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}
