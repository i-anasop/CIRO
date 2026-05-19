// CIRO - Simple public-facing explanation screen.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/crisis.dart';
import '../models/orchestration_models.dart';
import '../models/signal.dart';
import '../services/scenario_engine.dart';
import '../theme/colors.dart';

class AgentLogsScreen extends StatelessWidget {
  const AgentLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ScenarioEngine.instance,
      builder: (context, _) {
        final result = ScenarioEngine.instance.currentResult;
        final crisis = result.crisis;
        final color = _severityColor(crisis.severity);

        return Scaffold(
          backgroundColor: CiroColors.bg1,
          appBar: AppBar(
            backgroundColor: CiroColors.bg1,
            surfaceTintColor: CiroColors.bg1,
            elevation: 0,
            title: const Text(
              'Why CIRO Flagged This',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.go('/home/crisis-detail', extra: crisis),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 104),
            children: [
              _AlertSummary(crisis: crisis, color: color),
              const SizedBox(height: 14),
              _ReasonSnapshot(result: result),
              const SizedBox(height: 14),
              _SourceGrid(result: result),
              const SizedBox(height: 14),
              _ConfidenceCard(result: result),
              const SizedBox(height: 14),
              _NextActionCard(result: result),
            ],
          ),
        );
      },
    );
  }
}

class _AlertSummary extends StatelessWidget {
  final Crisis crisis;
  final Color color;

  const _AlertSummary({required this.crisis, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _softCard(radius: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.95),
                      color.withValues(alpha: 0.68),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.22),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  _crisisIcon(crisis.type),
                  color: Colors.white,
                  size: 30,
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
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
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
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _SeverityPill(label: crisis.severityLabel, color: color),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Confidence',
                  value: '${crisis.confidence}%',
                  color: color,
                  icon: Icons.verified_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: 'People',
                  value: _people(crisis.affectedPeople),
                  color: CiroColors.brand,
                  icon: Icons.groups_2_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: 'Status',
                  value: crisis.statusLabel,
                  color: CiroColors.info,
                  icon: Icons.radar_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReasonSnapshot extends StatelessWidget {
  final dynamic result;

  const _ReasonSnapshot({required this.result});

  @override
  Widget build(BuildContext context) {
    final crisis = result.crisis as Crisis;
    final signals = result.signalAssessments as List<SignalAssessment>;
    final color = _severityColor(crisis.severity);

    return _SectionCard(
      title: 'Main reason',
      icon: Icons.auto_awesome_rounded,
      color: color,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.16)),
            ),
            child: Row(
              children: [
                _StackedSignalDots(assessments: signals),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    '${signals.length} independent signals matched the same place and crisis type.',
                    style: const TextStyle(
                      color: CiroColors.textPrimary,
                      fontSize: 15,
                      height: 1.28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ReasonStep(
                  icon: Icons.place_outlined,
                  label: 'Same area',
                  value: _percent(
                    _average(signals.map((s) => s.geolocationConfidence)),
                  ),
                  color: CiroColors.brand,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ReasonStep(
                  icon: Icons.priority_high_rounded,
                  label: 'Urgent words',
                  value: _percent(_average(signals.map((s) => s.urgencyScore))),
                  color: CiroColors.high,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ReasonStep(
                  icon: Icons.warning_amber_rounded,
                  label: 'Conflict',
                  value: _percent(
                    _average(signals.map((s) => s.contradictionLevel)),
                  ),
                  color: CiroColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceGrid extends StatelessWidget {
  final dynamic result;

  const _SourceGrid({required this.result});

  @override
  Widget build(BuildContext context) {
    final assessments = (result.signalAssessments as List<SignalAssessment>)
        .take(4);
    return _SectionCard(
      title: 'Sources checked',
      icon: Icons.hub_outlined,
      color: CiroColors.brand,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: assessments.map((assessment) {
          return _SourceCard(assessment: assessment);
        }).toList(),
      ),
    );
  }
}

class _ConfidenceCard extends StatelessWidget {
  final dynamic result;

  const _ConfidenceCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final crisis = result.crisis as Crisis;
    final assessments = result.signalAssessments as List<SignalAssessment>;
    final credibility = _average(assessments.map((s) => s.credibility));
    final location = _average(assessments.map((s) => s.geolocationConfidence));
    final urgency = _average(assessments.map((s) => s.urgencyScore));

    return _SectionCard(
      title: 'How strong is it?',
      icon: Icons.speed_rounded,
      color: CiroColors.info,
      child: Column(
        children: [
          _ConfidenceRing(
            value: crisis.confidencePercent / 100,
            label: 'Overall',
            color: _severityColor(crisis.severity),
          ),
          const SizedBox(height: 14),
          _Bar(
            label: 'Trusted sources',
            value: credibility,
            color: CiroColors.success,
          ),
          const SizedBox(height: 10),
          _Bar(
            label: 'Location match',
            value: location,
            color: CiroColors.brand,
          ),
          const SizedBox(height: 10),
          _Bar(label: 'Urgency level', value: urgency, color: CiroColors.high),
        ],
      ),
    );
  }
}

class _NextActionCard extends StatelessWidget {
  final dynamic result;

  const _NextActionCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final actions = result.responsePlan.take(2).toList();
    return _SectionCard(
      title: 'Next actions',
      icon: Icons.task_alt_rounded,
      color: CiroColors.success,
      child: Column(
        children: [
          _VerificationStrip(verification: result.verification),
          const SizedBox(height: 10),
          ...actions.map(
            (action) => _ActionRow(
              title: action.title,
              subtitle: '${action.department} • ${action.eta}',
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  final SignalAssessment assessment;

  const _SourceCard({required this.assessment});

  @override
  Widget build(BuildContext context) {
    final color = _sourceColor(assessment.source);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = ((constraints.maxWidth - 10) / 2).clamp(130.0, 190.0);
        return SizedBox(
          width: width,
          child: Container(
            height: 134,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _sourceIcon(assessment.source),
                        color: color,
                        size: 18,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _percent(assessment.credibility),
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  assessment.sourceLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CiroColors.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: Text(
                    _plain(assessment.finding),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: CiroColors.textSecondary,
                      fontSize: 11,
                      height: 1.24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: CiroColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StackedSignalDots extends StatelessWidget {
  final List<SignalAssessment> assessments;

  const _StackedSignalDots({required this.assessments});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 48,
      child: Stack(
        children: assessments.take(4).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final assessment = entry.value;
          final color = _sourceColor(assessment.source);
          return Positioned(
            left: index * 14,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.16),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                _sourceIcon(assessment.source),
                color: Colors.white,
                size: 18,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ReasonStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ReasonStep({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: CiroColors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CiroColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: CiroColors.textSecondary,
              fontSize: 10.3,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceRing extends StatelessWidget {
  final double value;
  final String label;
  final Color color;

  const _ConfidenceRing({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CiroColors.bg2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CiroColors.borderLight),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: safeValue,
                    strokeWidth: 8,
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.12),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  _percent(safeValue),
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: CiroColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'CIRO recommends action because the signal strength is high enough for response teams to verify and prepare.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CiroColors.textSecondary,
                    fontSize: 11.5,
                    height: 1.35,
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

class _Bar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _Bar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 112,
          child: Text(
            label,
            style: const TextStyle(
              color: CiroColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: safeValue,
              minHeight: 9,
              color: color,
              backgroundColor: color.withValues(alpha: 0.12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _percent(safeValue),
          style: TextStyle(
            color: color,
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _VerificationStrip extends StatelessWidget {
  final dynamic verification;

  const _VerificationStrip({required this.verification});

  @override
  Widget build(BuildContext context) {
    final color = _verificationColor(verification.type);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_outlined, color: color, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verification.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _plain(verification.note),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CiroColors.textSecondary,
                    fontSize: 11,
                    height: 1.3,
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

class _ActionRow extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ActionRow({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CiroColors.bg2,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: CiroColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: CiroColors.brand.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: CiroColors.brand,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _plain(title),
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
                  _plain(subtitle),
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
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _softCard(radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: CiroColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }
}

class _SeverityPill extends StatelessWidget {
  final String label;
  final Color color;

  const _SeverityPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

BoxDecoration _softCard({required double radius}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: CiroColors.borderLight),
  boxShadow: CiroColors.cardShadow,
);

double _average(Iterable<double> values) {
  if (values.isEmpty) return 0;
  return values.reduce((a, b) => a + b) / values.length;
}

Color _severityColor(SeverityLevel severity) => switch (severity) {
  SeverityLevel.critical => CiroColors.critical,
  SeverityLevel.high => CiroColors.high,
  SeverityLevel.moderate => CiroColors.moderate,
  SeverityLevel.low => CiroColors.low,
  SeverityLevel.unknown => CiroColors.unknown,
};

Color _verificationColor(dynamic type) {
  final name = type.toString();
  if (name.contains('confirmed')) return CiroColors.success;
  if (name.contains('conflicting')) return CiroColors.warning;
  if (name.contains('falsePositive')) return CiroColors.error;
  if (name.contains('escalation')) return CiroColors.brand;
  return CiroColors.info;
}

Color _sourceColor(SignalSource source) => switch (source) {
  SignalSource.socialPost => CiroColors.brand,
  SignalSource.weatherAlert => CiroColors.info,
  SignalSource.trafficData => CiroColors.high,
  SignalSource.citizenReport => CiroColors.success,
  SignalSource.emergencyCall => CiroColors.error,
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
  SignalSource.trafficData => Icons.traffic_rounded,
  SignalSource.citizenReport => Icons.person_pin_circle_rounded,
  SignalSource.emergencyCall => Icons.call_rounded,
  SignalSource.mockSensor => Icons.sensors_rounded,
  SignalSource.fieldReport => Icons.assignment_rounded,
};

String _people(int value) {
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
  return '$value';
}

String _percent(double value) => '${(value.clamp(0.0, 1.0) * 100).round()}%';

String _plain(String text) => text
    .replaceAll('Agent', 'CIRO')
    .replaceAll('agent', 'CIRO')
    .replaceAll('pipeline', 'check')
    .replaceAll('Pipeline', 'Check')
    .replaceAll('Antigravity', 'CIRO')
    .replaceAll('trace', 'record')
    .replaceAll('Trace', 'Record')
    .replaceAll('fusion', 'comparison')
    .replaceAll('Fusion', 'Comparison')
    .replaceAll('ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â', '-')
    .replaceAll('ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â·', '•')
    .replaceAll('ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â°C', 'C')
    .replaceAll('ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ', '-')
    .trim();
