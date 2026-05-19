// CIRO - Public-facing crisis detail screen.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/interactive_map_helper.dart';
import '../models/crisis.dart';
import '../models/demo_scenario.dart';
import '../models/orchestration_models.dart';
import '../models/signal.dart';
import '../services/scenario_engine.dart';
import '../theme/colors.dart';

class CrisisDetailScreen extends StatelessWidget {
  final Crisis crisis;

  const CrisisDetailScreen({super.key, required this.crisis});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ScenarioEngine.instance,
      builder: (context, _) {
        final engine = ScenarioEngine.instance;
        final scenario = engine.activeScenario;
        final result = engine.currentResult;
        final color = _severityColor(crisis.severity);
        final actions = engine.responsePlan.take(3).toList();

        return Scaffold(
          backgroundColor: CiroColors.bg1,
          appBar: AppBar(
            backgroundColor: CiroColors.bg1,
            surfaceTintColor: CiroColors.bg1,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.go('/home'),
            ),
            title: const Text(
              'Crisis Details',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: TextButton.icon(
                  onPressed: () => context.go('/logs'),
                  style: TextButton.styleFrom(
                    foregroundColor: CiroColors.brand,
                    backgroundColor: CiroColors.brand.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  icon: const Icon(Icons.help_outline_rounded, size: 17),
                  label: const Text(
                    'Why?',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
            children: [
              _HeroPanel(
                crisis: crisis,
                scenario: scenario,
                color: color,
                peak: result.evolution.peakImpactTime,
              ),
              const SizedBox(height: 14),
              _AreaMapCard(crisis: crisis, color: color),
              const SizedBox(height: 14),
              _InsightStrip(
                affectedRadius: result.evolution.affectedRadius,
                affectedPeople: crisis.affectedPeople,
                duration:
                    crisis.estimatedDuration ??
                    result.evolution.expectedDuration,
                peak: result.evolution.peakImpactTime,
                color: color,
              ),
              const SizedBox(height: 16),
              _SectionTitle(
                title: 'Immediate steps',
                subtitle: 'Top response actions already prepared',
                actionLabel: 'Open plan',
                onAction: () =>
                    context.go('/home/response-plan', extra: crisis),
              ),
              const SizedBox(height: 10),
              _ActionPreview(actions: actions),
              const SizedBox(height: 16),
              _SectionTitle(
                title: 'Signals behind this alert',
                subtitle: 'Short source view, no technical evidence dump',
                actionLabel: 'Why?',
                onAction: () => context.go('/logs'),
              ),
              const SizedBox(height: 10),
              _SignalPreview(
                signals: scenario.activeSignals,
                assessments: result.signalAssessments,
              ),
              const SizedBox(height: 14),
              _VerificationCard(
                label: engine.verification.label,
                note: engine.verification.note,
                color: _verificationColor(scenario.verificationType),
              ),
              const SizedBox(height: 18),
              _DetailActionDock(
                onPlan: () => context.go('/home/response-plan', extra: crisis),
                onMap: () => context.go('/map'),
                onImpact: () => context.go('/home/simulation', extra: crisis),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final Crisis crisis;
  final DemoScenario scenario;
  final Color color;
  final String peak;

  const _HeroPanel({
    required this.crisis,
    required this.scenario,
    required this.color,
    required this.peak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _card(radius: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.98),
                      color.withValues(alpha: 0.68),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.24),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  _crisisIcon(crisis.type),
                  color: Colors.white,
                  size: 31,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crisis.typeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CiroColors.textPrimary,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: CiroColors.textSecondary,
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            crisis.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: CiroColors.textSecondary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _RiskPill(label: crisis.severityLabel, color: color),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.14)),
            ),
            child: Text(
              _plainSummary(scenario.likelyEvolution),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: CiroColors.textPrimary,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _ConfidenceBlock(
                  value: crisis.confidencePercent / 100,
                  color: color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMiniCard(
                  icon: Icons.schedule_rounded,
                  label: 'Peak impact',
                  value: peak.isEmpty ? 'Monitoring' : peak,
                  color: CiroColors.high,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AreaMapCard extends StatelessWidget {
  final Crisis crisis;
  final Color color;

  const _AreaMapCard({required this.crisis, required this.color});

  @override
  Widget build(BuildContext context) {
    final coords = _coords(crisis);
    return Container(
      height: 248,
      decoration: _card(radius: 26),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: createInteractiveMap(
              latitude: coords.$1,
              longitude: coords.$2,
              zoom: 15,
              selectedLayer: crisis.type == CrisisType.urbanFlooding
                  ? 'Flood Risk'
                  : 'All Layers',
              showRiskZone: true,
              showAltRoute: true,
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            top: 14,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: CiroColors.borderLight),
                  boxShadow: CiroColors.cardShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.near_me_rounded,
                        color: color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Affected area',
                            style: TextStyle(
                              color: CiroColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            crisis.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: CiroColors.textSecondary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _RiskPill(label: 'Live', color: CiroColors.brand),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 14,
            bottom: 14,
            child: GestureDetector(
              onTap: () => context.go('/map'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  gradient: CiroColors.brandGradient,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: CiroColors.glowCyan,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.map_rounded, color: Colors.white, size: 15),
                    SizedBox(width: 6),
                    Text(
                      'Open map',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightStrip extends StatelessWidget {
  final String affectedRadius;
  final String duration;
  final String peak;
  final int affectedPeople;
  final Color color;

  const _InsightStrip({
    required this.affectedRadius,
    required this.duration,
    required this.peak,
    required this.affectedPeople,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _InsightTile(
          icon: Icons.groups_2_outlined,
          label: 'People',
          value: _people(affectedPeople),
          color: CiroColors.brand,
        ),
        const SizedBox(width: 10),
        _InsightTile(
          icon: Icons.radar_rounded,
          label: 'Radius',
          value: affectedRadius,
          color: color,
        ),
        const SizedBox(width: 10),
        _InsightTile(
          icon: Icons.timer_outlined,
          label: 'Duration',
          value: duration.isEmpty ? peak : duration,
          color: CiroColors.info,
        ),
      ],
    );
  }
}

class _ActionPreview extends StatelessWidget {
  final List<PlanAction> actions;

  const _ActionPreview({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _card(radius: 24),
      child: Column(
        children: actions.map((action) {
          final color = _actionColor(action.status);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CiroColors.bg2,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: CiroColors.borderLight),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${action.step}',
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _plainSummary(action.title),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CiroColors.textPrimary,
                          fontSize: 13.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${action.department} - ETA ${action.eta}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CiroColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _RiskPill(label: action.status, color: color),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SignalPreview extends StatelessWidget {
  final List<SignalInput> signals;
  final List<SignalAssessment> assessments;

  const _SignalPreview({required this.signals, required this.assessments});

  @override
  Widget build(BuildContext context) {
    final visible = signals.take(4).toList();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _card(radius: 24),
      child: Column(
        children: [
          Row(
            children: [
              _StackedDots(signals: visible),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${visible.length} nearby sources match this alert',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CiroColors.textPrimary,
                    fontSize: 14,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...visible.map((signal) {
            final assessment = _assessmentFor(signal, assessments);
            return _SignalRow(signal: signal, assessment: assessment);
          }),
        ],
      ),
    );
  }
}

class _SignalRow extends StatelessWidget {
  final SignalInput signal;
  final SignalAssessment? assessment;

  const _SignalRow({required this.signal, required this.assessment});

  @override
  Widget build(BuildContext context) {
    final color = _sourceColor(signal.source);
    final confidence = assessment?.credibility ?? signal.confidence;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_sourceIcon(signal.source), color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _sourceLabel(signal.source),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CiroColors.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _plainSummary(assessment?.finding ?? signal.content),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CiroColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(confidence * 100).round().clamp(0, 100)}%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  final String label;
  final String note;
  final Color color;

  const _VerificationCard({
    required this.label,
    required this.note,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.verified_outlined, color: color, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _plainSummary(note),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CiroColors.textSecondary,
                    fontSize: 11.5,
                    height: 1.32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailActionDock extends StatelessWidget {
  final VoidCallback onPlan;
  final VoidCallback onMap;
  final VoidCallback onImpact;

  const _DetailActionDock({
    required this.onPlan,
    required this.onMap,
    required this.onImpact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _card(radius: 24),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _DockPrimaryAction(
              icon: Icons.assignment_turned_in_rounded,
              label: 'Response Plan',
              subtitle: 'Open dispatch flow',
              onTap: onPlan,
            ),
          ),
          const SizedBox(width: 8),
          _DockIconAction(icon: Icons.map_rounded, label: 'Map', onTap: onMap),
          const SizedBox(width: 8),
          _DockIconAction(
            icon: Icons.insights_rounded,
            label: 'Impact',
            onTap: onImpact,
          ),
        ],
      ),
    );
  }
}

class _ConfidenceBlock extends StatelessWidget {
  final double value;
  final Color color;

  const _ConfidenceBlock({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(0.0, 1.0);
    return Container(
      height: 74,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: safeValue,
                  strokeWidth: 5,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.14),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  '${(safeValue * 100).round()}',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Confidence',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CiroColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Needs attention',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CiroColors.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMiniCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _HeroMiniCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CiroColors.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InsightTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 92,
        padding: const EdgeInsets.all(12),
        decoration: _card(radius: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 19, color: color),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(
                color: CiroColors.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StackedDots extends StatelessWidget {
  final List<SignalInput> signals;

  const _StackedDots({required this.signals});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 44,
      child: Stack(
        children: signals.asMap().entries.map((entry) {
          final index = entry.key;
          final signal = entry.value;
          final color = _sourceColor(signal.source);
          return Positioned(
            left: index * 13,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.14),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                _sourceIcon(signal.source),
                color: Colors.white,
                size: 17,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: CiroColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CiroColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionLabel,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _DockPrimaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _DockPrimaryAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          gradient: CiroColors.brandGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: CiroColors.glowCyan,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _DockIconAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DockIconAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        height: 64,
        decoration: BoxDecoration(
          color: CiroColors.bg2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: CiroColors.borderLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: CiroColors.brand, size: 20),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                color: CiroColors.textPrimary,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskPill extends StatelessWidget {
  final String label;
  final Color color;

  const _RiskPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 104),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

BoxDecoration _card({required double radius}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: CiroColors.borderLight),
  boxShadow: CiroColors.cardShadow,
);

Color _severityColor(SeverityLevel severity) => switch (severity) {
  SeverityLevel.critical => CiroColors.critical,
  SeverityLevel.high => CiroColors.high,
  SeverityLevel.moderate => CiroColors.high,
  SeverityLevel.low => CiroColors.low,
  SeverityLevel.unknown => CiroColors.unknown,
};

Color _verificationColor(VerificationType type) => switch (type) {
  VerificationType.confirmed => CiroColors.success,
  VerificationType.needsVerification => CiroColors.warning,
  VerificationType.conflictingSignals => CiroColors.high,
  VerificationType.falsePositiveRisk => CiroColors.critical,
  VerificationType.escalationRequired => CiroColors.brand,
};

Color _actionColor(String status) {
  final lower = status.toLowerCase();
  if (lower.contains('complete')) return CiroColors.success;
  if (lower.contains('progress')) return CiroColors.warning;
  return CiroColors.brand;
}

(double, double) _coords(Crisis crisis) {
  final matches = RegExp(r'-?\d+\.?\d*')
      .allMatches(crisis.coordinates)
      .map((m) => double.tryParse(m.group(0)!))
      .whereType<double>()
      .toList();
  if (matches.length >= 2) return (matches[0], matches[1]);
  return (33.6946, 73.0179);
}

SignalAssessment? _assessmentFor(
  SignalInput signal,
  List<SignalAssessment> assessments,
) {
  for (final assessment in assessments) {
    if (assessment.source == signal.source) return assessment;
  }
  return null;
}

Color _sourceColor(SignalSource source) => switch (source) {
  SignalSource.socialPost => CiroColors.brand,
  SignalSource.weatherAlert => CiroColors.info,
  SignalSource.trafficData => CiroColors.high,
  SignalSource.citizenReport => CiroColors.success,
  SignalSource.emergencyCall => CiroColors.critical,
  SignalSource.mockSensor => const Color(0xFF06B6D4),
  SignalSource.fieldReport => const Color(0xFF7C3AED),
};

IconData _crisisIcon(CrisisType type) => switch (type) {
  CrisisType.urbanFlooding => Icons.flood_rounded,
  CrisisType.roadBlockage => Icons.traffic_rounded,
  CrisisType.accident => Icons.car_crash_rounded,
  CrisisType.heatwave => Icons.thermostat_rounded,
  CrisisType.powerOutage => Icons.power_off_rounded,
};

IconData _sourceIcon(SignalSource source) => switch (source) {
  SignalSource.socialPost => Icons.chat_bubble_outline_rounded,
  SignalSource.weatherAlert => Icons.thunderstorm_rounded,
  SignalSource.trafficData => Icons.directions_car_rounded,
  SignalSource.citizenReport => Icons.person_pin_circle_rounded,
  SignalSource.emergencyCall => Icons.call_rounded,
  SignalSource.mockSensor => Icons.sensors_rounded,
  SignalSource.fieldReport => Icons.assignment_rounded,
};

String _sourceLabel(SignalSource source) => switch (source) {
  SignalSource.socialPost => 'Public Reports',
  SignalSource.weatherAlert => 'Weather',
  SignalSource.trafficData => 'Traffic',
  SignalSource.citizenReport => 'Citizen Report',
  SignalSource.emergencyCall => 'Emergency Calls',
  SignalSource.mockSensor => 'Sensors',
  SignalSource.fieldReport => 'Field Team',
};

String _people(int value) {
  if (value <= 0) return 'None';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
  return '$value';
}

String _plainSummary(String text) => text
    .replaceAll('Ã¢â‚¬â€', '-')
    .replaceAll('Ã‚Â·', '|')
    .replaceAll('Ã‚Â°C', 'C')
    .replaceAll('Ã¢â‚¬â€œ', '-')
    .replaceAll('Agent', 'CIRO')
    .replaceAll('agent', 'CIRO')
    .replaceAll('pipeline', 'check')
    .replaceAll('Pipeline', 'Check')
    .replaceAll('corroborate', 'match')
    .replaceAll('corroborates', 'matches')
    .trim();
