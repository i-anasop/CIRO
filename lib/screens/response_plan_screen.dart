// CIRO - Response plan and expected impact screen.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/crisis.dart';
import '../models/demo_scenario.dart';
import '../models/pipeline_result.dart';
import '../models/simulation_result.dart';
import '../services/scenario_engine.dart';
import '../theme/colors.dart';

class ResponsePlanScreen extends StatefulWidget {
  final Crisis crisis;
  final int initialTab;

  const ResponsePlanScreen({
    super.key,
    required this.crisis,
    this.initialTab = 0,
  });

  @override
  State<ResponsePlanScreen> createState() => _ResponsePlanScreenState();
}

class _ResponsePlanScreenState extends State<ResponsePlanScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ScenarioEngine.instance,
      builder: (context, _) {
        final engine = ScenarioEngine.instance;
        final plan = engine.responsePlan;
        final sim = engine.simulation;
        final scenario = engine.activeScenario;
        final result = engine.currentResult;
        final verification = engine.verification;
        final color = _severityColor(widget.crisis.severity);

        return Scaffold(
          backgroundColor: CiroColors.bg1,
          appBar: AppBar(
            backgroundColor: CiroColors.bg1,
            surfaceTintColor: CiroColors.bg1,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () =>
                  context.go('/home/crisis-detail', extra: widget.crisis),
            ),
            title: Text(
              widget.crisis.typeLabel,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(62),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CiroColors.borderLight),
                    boxShadow: CiroColors.cardShadow,
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: CiroColors.brandGradient,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: CiroColors.textSecondary,
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.route_rounded, size: 16),
                            SizedBox(width: 6),
                            Text('Tactical Steps'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.insights_rounded, size: 16),
                            SizedBox(width: 6),
                            Text('Expected Impact'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _TacticalTab(
                crisis: widget.crisis,
                plan: plan,
                engine: engine,
                result: result,
                color: color,
              ),
              _ImpactTab(
                crisis: widget.crisis,
                sim: sim,
                scenario: scenario,
                verification: verification,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TacticalTab extends StatelessWidget {
  final Crisis crisis;
  final List<PlanAction> plan;
  final ScenarioEngine engine;
  final PipelineResult result;
  final Color color;

  const _TacticalTab({
    required this.crisis,
    required this.plan,
    required this.engine,
    required this.result,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (plan.isEmpty) {
      return const Center(child: Text('No response steps active.'));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 104),
      children: [
        _PlanHero(crisis: crisis, engine: engine, color: color),
        const SizedBox(height: 14),
        if (result.coordination.isActive) ...[
          _CoordinationCard(result: result),
          const SizedBox(height: 14),
        ],
        _ResourceChips(engine: engine),
        const SizedBox(height: 18),
        const _TitleRow(
          title: 'Dispatch timeline',
          subtitle: 'What teams should do first',
        ),
        const SizedBox(height: 12),
        ...plan.asMap().entries.map((entry) {
          return _TacticalStepCard(
            action: entry.value,
            isLast: entry.key == plan.length - 1,
          );
        }),
        const SizedBox(height: 12),
        _StakeholderPreview(engine: engine),
      ],
    );
  }
}

class _ImpactTab extends StatelessWidget {
  final Crisis crisis;
  final SimulationResult sim;
  final DemoScenario scenario;
  final VerificationDecision verification;

  const _ImpactTab({
    required this.crisis,
    required this.sim,
    required this.scenario,
    required this.verification,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 104),
      children: [
        _ImpactHero(crisis: crisis, sim: sim, scenario: scenario),
        const SizedBox(height: 16),
        const _TitleRow(
          title: 'Projected improvements',
          subtitle: 'Before vs after response starts',
        ),
        const SizedBox(height: 12),
        ...sim.metrics.map((metric) => _ImpactMetricCard(metric: metric)),
        const SizedBox(height: 16),
        _VerificationCard(verification: verification),
        if (scenario.possibleSideEffects.isNotEmpty) ...[
          const SizedBox(height: 16),
          const _TitleRow(
            title: 'Possible side effects',
            subtitle: 'Risks CIRO will keep watching',
          ),
          const SizedBox(height: 12),
          ...scenario.possibleSideEffects
              .take(3)
              .map((effect) => _SideEffectTile(effect: effect)),
        ],
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/logs'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: CiroColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
            ),
            icon: const Icon(
              Icons.help_outline_rounded,
              color: CiroColors.brand,
            ),
            label: const Text(
              'Why CIRO Says This',
              style: TextStyle(
                color: CiroColors.brand,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanHero extends StatelessWidget {
  final Crisis crisis;
  final ScenarioEngine engine;
  final Color color;

  const _PlanHero({
    required this.crisis,
    required this.engine,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final completed = engine.responsePlan
        .where((action) => action.status.toLowerCase() == 'completed')
        .length;
    final total = engine.responsePlan.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _card(radius: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: CiroColors.brandGradient,
                  shape: BoxShape.circle,
                  boxShadow: CiroColors.glowCyan,
                ),
                child: const Icon(
                  Icons.assignment_turned_in_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Response Plan',
                      style: TextStyle(
                        color: CiroColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${engine.resources.unitCount} units assigned near ${crisis.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CiroColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(label: crisis.severityLabel, color: color),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 9,
              color: CiroColors.brand,
              backgroundColor: CiroColors.brand.withValues(alpha: 0.12),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _HeroStat(
                label: 'Steps',
                value: '$total',
                icon: Icons.route_rounded,
                color: CiroColors.brand,
              ),
              const SizedBox(width: 9),
              _HeroStat(
                label: 'Done',
                value: '$completed',
                icon: Icons.check_circle_outline_rounded,
                color: CiroColors.success,
              ),
              const SizedBox(width: 9),
              _HeroStat(
                label: 'Units',
                value: '${engine.resources.unitCount}',
                icon: Icons.local_police_outlined,
                color: CiroColors.info,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoordinationCard extends StatelessWidget {
  final PipelineResult result;

  const _CoordinationCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.hub_rounded,
      color: CiroColors.brand,
      title: 'Multi-crisis coordination',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _plain(result.coordination.summary),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: _body(),
          ),
          if (result.coordination.tradeOffs.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...result.coordination.tradeOffs
                .take(2)
                .map(
                  (tradeOff) => _TinyBullet(
                    text: _plain(tradeOff),
                    color: CiroColors.warning,
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _ResourceChips extends StatelessWidget {
  final ScenarioEngine engine;

  const _ResourceChips({required this.engine});

  @override
  Widget build(BuildContext context) {
    final units = engine.resources.units.take(6).toList();
    return _InfoCard(
      icon: Icons.inventory_2_outlined,
      color: CiroColors.info,
      title: 'Resources assigned',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: units.map((unit) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: CiroColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: CiroColors.info.withValues(alpha: 0.16),
              ),
            ),
            child: Text(
              unit,
              style: const TextStyle(
                color: CiroColors.info,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TacticalStepCard extends StatelessWidget {
  final PlanAction action;
  final bool isLast;

  const _TacticalStepCard({required this.action, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(action.status);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    '${action.step}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      color: CiroColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
              padding: const EdgeInsets.all(14),
              decoration: _card(radius: 21),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _plain(action.title),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: CiroColors.textPrimary,
                            fontSize: 14.5,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusPill(
                        label: action.priority,
                        color: CiroColors.brand,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _MetaPill(
                        icon: Icons.apartment_rounded,
                        label: action.department,
                      ),
                      const SizedBox(width: 8),
                      _MetaPill(
                        icon: Icons.schedule_rounded,
                        label: action.eta,
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Text(
                    _plain(action.description),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: _body(),
                  ),
                  if (action.resultSummary != null) ...[
                    const SizedBox(height: 12),
                    _ResultStrip(text: _plain(action.resultSummary!)),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.circle, size: 9, color: color),
                      const SizedBox(width: 6),
                      Text(
                        action.status,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StakeholderPreview extends StatelessWidget {
  final ScenarioEngine engine;

  const _StakeholderPreview({required this.engine});

  @override
  Widget build(BuildContext context) {
    final notifications = engine.stakeholderNotifications.take(4).toList();
    if (notifications.isEmpty) return const SizedBox.shrink();

    return _InfoCard(
      icon: Icons.campaign_rounded,
      color: CiroColors.brand,
      title: 'Who gets notified',
      child: SizedBox(
        height: 94,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: notifications.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final item = notifications[index];
            return Container(
              width: 176,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CiroColors.brand.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: CiroColors.brand.withValues(alpha: 0.14),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.stakeholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: CiroColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _plain(item.message),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _smallBody(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ImpactHero extends StatelessWidget {
  final Crisis crisis;
  final SimulationResult sim;
  final DemoScenario scenario;

  const _ImpactHero({
    required this.crisis,
    required this.sim,
    required this.scenario,
  });

  @override
  Widget build(BuildContext context) {
    final improvements = sim.metrics.where((m) => m.isImprovement).length;
    final progress = sim.metrics.isEmpty
        ? 0.0
        : improvements / sim.metrics.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _card(radius: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 82,
                height: 82,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 82,
                      height: 82,
                      child: CircularProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        strokeWidth: 9,
                        color: CiroColors.success,
                        backgroundColor: CiroColors.success.withValues(
                          alpha: 0.12,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(progress * 100).round()}%',
                          style: const TextStyle(
                            color: CiroColors.success,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'better',
                          style: TextStyle(
                            color: CiroColors.textSecondary,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expected Impact',
                      style: TextStyle(
                        color: CiroColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${sim.actions.length} actions simulated for ${scenario.location}.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CiroColors.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _HeroStat(
                label: 'Metrics',
                value: '${sim.metrics.length}',
                icon: Icons.analytics_outlined,
                color: CiroColors.info,
              ),
              const SizedBox(width: 9),
              _HeroStat(
                label: 'Improving',
                value: '$improvements',
                icon: Icons.trending_up_rounded,
                color: CiroColors.success,
              ),
              const SizedBox(width: 9),
              _HeroStat(
                label: 'Risk',
                value: crisis.severityLabel,
                icon: Icons.warning_amber_rounded,
                color: _severityColor(crisis.severity),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImpactMetricCard extends StatelessWidget {
  final MetricSnapshot metric;

  const _ImpactMetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    final color = metric.isImprovement
        ? CiroColors.success
        : CiroColors.warning;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: _card(radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  metric.isImprovement
                      ? Icons.trending_down_rounded
                      : Icons.trending_flat_rounded,
                  color: color,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  metric.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CiroColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _StatusPill(label: metric.delta, color: color),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _BeforeAfterBlock(
                  label: 'Before',
                  value: metric.before,
                  color: CiroColors.error,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.arrow_forward_rounded, color: color),
              ),
              Expanded(
                child: _BeforeAfterBlock(
                  label: 'After',
                  value: metric.after,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  final VerificationDecision verification;

  const _VerificationCard({required this.verification});

  @override
  Widget build(BuildContext context) {
    final color = _verificationColor(verification.type);
    return _InfoCard(
      icon: Icons.verified_user_outlined,
      color: color,
      title: 'Safety check',
      child: Text(
        _plain(verification.note),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: _body(),
      ),
    );
  }
}

class _SideEffectTile extends StatelessWidget {
  final String effect;

  const _SideEffectTile({required this.effect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: CiroColors.warning.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CiroColors.warning.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: CiroColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _plain(effect),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF92400E),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Widget child;

  const _InfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _card(radius: 23),
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: CiroColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _HeroStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 76,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(17),
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
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: CiroColors.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BeforeAfterBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BeforeAfterBlock({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: CiroColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: CiroColors.bg2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: CiroColors.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: CiroColors.textSecondary),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CiroColors.textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultStrip extends StatelessWidget {
  final String text;

  const _ResultStrip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: CiroColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CiroColors.success.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: CiroColors.success,
            size: 17,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: CiroColors.success,
                fontSize: 11.5,
                height: 1.3,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyBullet extends StatelessWidget {
  final String text;
  final Color color;

  const _TinyBullet({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, color: color, size: 8),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _smallBody(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TitleRow({required this.title, required this.subtitle});

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
                style: const TextStyle(
                  color: CiroColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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

TextStyle _body() => const TextStyle(
  color: CiroColors.textSecondary,
  fontSize: 12,
  height: 1.38,
  fontWeight: FontWeight.w700,
);

TextStyle _smallBody() => const TextStyle(
  color: CiroColors.textSecondary,
  fontSize: 11,
  height: 1.3,
  fontWeight: FontWeight.w700,
);

Color _statusColor(String status) {
  final lower = status.toLowerCase();
  if (lower.contains('complete')) return CiroColors.success;
  if (lower.contains('progress')) return CiroColors.warning;
  return CiroColors.brand;
}

Color _severityColor(SeverityLevel severity) => switch (severity) {
  SeverityLevel.critical => CiroColors.critical,
  SeverityLevel.high => CiroColors.high,
  SeverityLevel.moderate => CiroColors.moderate,
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

String _plain(String text) => text
    .replaceAll('Ã¢â‚¬â€', '-')
    .replaceAll('Ã‚Â·', '•')
    .replaceAll('Ã‚Â°C', 'C')
    .replaceAll('Ã¢â‚¬â€œ', '-')
    .replaceAll('Agent', 'CIRO')
    .replaceAll('agent', 'CIRO')
    .replaceAll('pipeline', 'check')
    .replaceAll('Pipeline', 'Check')
    .replaceAll('corroborate', 'match')
    .replaceAll('corroborates', 'matches')
    .trim();
