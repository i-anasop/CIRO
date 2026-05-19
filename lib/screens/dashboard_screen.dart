// CIRO - Home command center
// Reference-style operational dashboard with fully wired actions.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/interactive_map_helper.dart';
import '../models/crisis.dart';
import '../models/demo_scenario.dart';
import '../models/signal.dart';
import '../services/app_mode_service.dart';
import '../services/notification_service.dart';
import '../services/scenario_engine.dart';
import '../services/user_profile_service.dart';
import '../theme/typography.dart';
import '../data/mock_crises.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _loadingStep;
  bool _demoNotificationScheduled = false;

  @override
  void initState() {
    super.initState();
    _scheduleDemoNotification();
  }

  void _scheduleDemoNotification() {
    if (_demoNotificationScheduled || !AppModeService.instance.isDemoMode) {
      return;
    }
    _demoNotificationScheduled = true;
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted || !AppModeService.instance.isDemoMode) return;
      final engine = ScenarioEngine.instance;
      final crisis = engine.activeCrisis;
      NotificationService.instance.addNotificationWithId(
        id: 'demo-followup-${engine.activeScenarioId}',
        title: 'Demo Update: ${crisis.typeLabel} Escalation Window',
        details:
            'CIRO is still tracking ${crisis.location}. The response plan is active with ${engine.responsePlan.length} recommended actions ready.',
      );
    });
  }

  Future<void> _refreshRealMode() async {
    setState(() => _loadingStep = 'Collecting live location signals');
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    setState(() => _loadingStep = 'Checking risk and response options');
    await ScenarioEngine.instance.runRealSignalAnalysis();
    if (!mounted) return;

    setState(() => _loadingStep = null);
  }

  void _showEmergencyContacts() {
    _showActionSheet(
      title: 'Emergency Contacts',
      subtitle: 'Direct lines for local response coordination.',
      icon: Icons.phone_in_talk_rounded,
      color: const Color(0xFF3B5BFF),
      children: const [
        _SheetRow(
          title: 'Rescue 1122',
          subtitle: 'Ambulance and disaster response',
          trailing: '1122',
        ),
        _SheetRow(
          title: 'CDA Helpline',
          subtitle: 'Drainage, debris, and civic response',
          trailing: '1334',
        ),
        _SheetRow(
          title: 'NDMA Control Room',
          subtitle: 'National disaster coordination',
          trailing: '051-111-157-157',
        ),
      ],
    );
  }

  void _showSafetyTips(Crisis crisis) {
    _showActionSheet(
      title: 'Safety Tips',
      subtitle:
          'Guidance for ${crisis.typeLabel.toLowerCase()} near ${crisis.location}.',
      icon: Icons.health_and_safety_rounded,
      color: const Color(0xFF10B981),
      children: _tips(crisis.type)
          .asMap()
          .entries
          .map(
            (e) => _SheetRow(
              title: '${e.key + 1}. ${e.value.$1}',
              subtitle: e.value.$2,
            ),
          )
          .toList(),
    );
  }

  void _showShelters() {
    _showActionSheet(
      title: 'Nearby Shelters',
      subtitle: 'Demo relief sites around G-10 Islamabad.',
      icon: Icons.home_work_rounded,
      color: const Color(0xFF7C3AED),
      children: const [
        _SheetRow(
          title: 'G-10 Community Center',
          subtitle: 'Dry zone, meals, basic medical support',
          trailing: '1.2 km',
        ),
        _SheetRow(
          title: 'F-9 Sports Complex',
          subtitle: 'Relief capacity and family holding area',
          trailing: '3.1 km',
        ),
        _SheetRow(
          title: 'PIMS Emergency Wing',
          subtitle: 'Hospital intake and triage support',
          trailing: '4.4 km',
        ),
      ],
    );
  }

  void _showLocationPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Demo Location',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'G-10, Islamabad boundary preview. Change location from Settings.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 280,
                    child: createInteractiveMap(
                      latitude: 33.6946,
                      longitude: 73.0179,
                      zoom: 15,
                      selectedLayer: 'Flood Risk',
                      showRiskZone: true,
                      showAltRoute: true,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/settings');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EFFE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFF5A5CE5),
                          child: Icon(
                            Icons.settings_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Change Location',
                                style: TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Manage demo or live location from Settings',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF5A5CE5),
                        ),
                      ],
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

  void _showActionSheet({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ...children,
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ScenarioEngine.instance,
      builder: (context, _) {
        _scheduleDemoNotification();
        final engine = ScenarioEngine.instance;
        final crisis = engine.activeCrisis;
        final scenario = engine.activeScenario;
        final isDemo = AppModeService.instance.isDemoMode;
        final severity = _severityColor(crisis.severity);
        final signals = scenario.activeSignals;

        return Stack(
          children: [
            Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              body: SafeArea(
                bottom: false,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 104),
                  children: [
                    _TopBar(
                      location: isDemo ? 'G-10, Islamabad' : crisis.location,
                      onLocationTap: _showLocationPreview,
                      onNotificationsTap: () => context.push('/notifications'),
                      onProfileTap: () => context.push('/profile'),
                      onRefresh: isDemo ? null : _refreshRealMode,
                    ),
                    const SizedBox(height: 20),
                    _BrandHeader(isDemo: isDemo),
                    const SizedBox(height: 16),
                    _ActiveRiskCard(
                      crisis: crisis,
                      scenario: scenario,
                      severityColor: severity,
                      onTap: () =>
                          context.go('/home/crisis-detail', extra: crisis),
                    ),
                    const SizedBox(height: 14),
                    _SignalCards(
                      signals: signals,
                      onViewReports: () => context.go('/reports'),
                    ),
                    const SizedBox(height: 14),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF0F172A,
                            ).withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Header
                          const Row(
                            children: [
                              Icon(
                                Icons.hub_rounded,
                                color: Color(0xFF4F46E5),
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Active Crises',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF111827),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Multi-Agent Orchestration',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...mockCrises
                              .where((c) {
                                final sameLocation =
                                    c.location
                                        .split(',')
                                        .first
                                        .trim()
                                        .toLowerCase() ==
                                    crisis.location
                                        .split(',')
                                        .first
                                        .trim()
                                        .toLowerCase();
                                final sameType = c.type == crisis.type;
                                return !(sameLocation && sameType) &&
                                    c.status != CrisisStatus.resolved;
                              })
                              .take(3)
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                                final index = entry.key;
                                final otherCrisis = entry.value;
                                return Padding(
                                  padding: EdgeInsets.only(
                                    top: index == 0 ? 0 : 12,
                                  ),
                                  child: _PrimaryCrisisCard(
                                    crisis: otherCrisis,
                                    scenario: scenario,
                                    onTap: () async {
                                      String targetScnId = 'SCN-001';
                                      if (otherCrisis.id == 'CRS-2024-002') {
                                        targetScnId = 'SCN-005';
                                      } else if (otherCrisis.id ==
                                          'CRS-2024-003') {
                                        targetScnId = 'SCN-003';
                                      } else if (otherCrisis.id ==
                                          'CRS-2024-006') {
                                        targetScnId = 'SCN-005';
                                      } else if (otherCrisis.id ==
                                          'CRS-2024-004') {
                                        targetScnId = 'SCN-004';
                                      } else if (otherCrisis.id ==
                                          'CRS-2024-005') {
                                        targetScnId = 'SCN-002';
                                      }

                                      await ScenarioEngine.instance
                                          .selectScenario(targetScnId);
                                      if (context.mounted) {
                                        context.go(
                                          '/home/crisis-detail',
                                          extra: otherCrisis,
                                        );
                                      }
                                    },
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _QuickActions(
                      onContacts: _showEmergencyContacts,
                      onSafety: () => _showSafetyTips(crisis),
                      onShelters: _showShelters,
                      onMap: () => context.go('/map'),
                    ),
                    const SizedBox(height: 14),
                    _CommunityReports(
                      crisis: crisis,
                      scenario: scenario,
                      onViewAll: () => context.go('/reports'),
                    ),
                  ],
                ),
              ),
            ),
            if (_loadingStep != null)
              Container(
                color: Colors.black.withValues(alpha: 0.50),
                child: Center(
                  child: Container(
                    width: 270,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF5A5CE5),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          _loadingStep!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  final String location;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;
  final VoidCallback? onRefresh;

  const _TopBar({
    required this.location,
    required this.onLocationTap,
    required this.onNotificationsTap,
    required this.onProfileTap,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onLocationTap,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: _softBox(radius: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF4F46E5),
                  size: 15,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        if (onRefresh != null)
          _CircleButton(icon: Icons.refresh_rounded, onTap: onRefresh),
        if (onRefresh != null) const SizedBox(width: 10),
        ListenableBuilder(
          listenable: NotificationService.instance,
          builder: (context, _) {
            final count = NotificationService.instance.unreadCount;
            return _CircleButton(
              icon: Icons.notifications_none_rounded,
              onTap: onNotificationsTap,
              badge: count,
            );
          },
        ),
        const SizedBox(width: 10),
        ListenableBuilder(
          listenable: UserProfileService.instance,
          builder: (context, _) {
            final profile = UserProfileService.instance;
            return GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF111827), Color(0xFF312E81)],
                  ),
                ),
                child: profile.customAvatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          profile.customAvatarUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        UserProfileService.avatarIcons[profile.avatarIndex],
                        color: Colors.white,
                        size: 19,
                      ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _BrandHeader extends StatelessWidget {
  final bool isDemo;
  const _BrandHeader({required this.isDemo});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'CIR',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 35,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(left: 1, bottom: 2),
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Color(0xFF3B82F6),
                        Color(0xFF7C3AED),
                        Color(0xFF5A5CE5),
                        Color(0xFF3B82F6),
                      ],
                    ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF8FAFC),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            const Text(
              'Command Center',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            isDemo ? 'DEMO' : 'LIVE',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveRiskCard extends StatelessWidget {
  final Crisis crisis;
  final DemoScenario scenario;
  final Color severityColor;
  final VoidCallback onTap;

  const _ActiveRiskCard({
    required this.crisis,
    required this.scenario,
    required this.severityColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBFB),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: severityColor.withValues(alpha: 0.32),
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: severityColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: severityColor.withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    _crisisIcon(crisis.type),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crisis.status == CrisisStatus.monitoring
                            ? 'MONITORING'
                            : 'ACTIVE RISK',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: severityColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        crisis.typeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                _OutlinePill(
                  label: crisis.severityLabel.toUpperCase(),
                  color: severityColor,
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF111827),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: const Color(0xFFF1D7D7)),
            const SizedBox(height: 14),
            Row(
              children: [
                SizedBox(
                  width: 92,
                  child: Column(
                    children: [
                      const Text(
                        'Confidence',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${crisis.confidence}%',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 56, color: const Color(0xFFE2E8F0)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    scenario.likelyEvolution,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF334155),
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalCards extends StatelessWidget {
  final List<SignalInput> signals;
  final VoidCallback onViewReports;
  const _SignalCards({required this.signals, required this.onViewReports});

  @override
  Widget build(BuildContext context) {
    final weather = _first(SignalSource.weatherAlert);
    final traffic = _first(SignalSource.trafficData);
    final public = _first(SignalSource.socialPost);
    return Row(
      children: [
        Expanded(
          child: _SignalMiniCard(
            signal: weather,
            fallbackTitle: 'Weather',
            fallbackValue: 'Normal',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SignalMiniCard(
            signal: traffic,
            fallbackTitle: 'Traffic',
            fallbackValue: 'Clear',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SignalMiniCard(
            signal: public,
            fallbackTitle: 'News / Reports',
            fallbackValue: '0 New',
            action: 'View all',
            onAction: onViewReports,
          ),
        ),
      ],
    );
  }

  SignalInput? _first(SignalSource source) {
    for (final signal in signals) {
      if (signal.source == source) return signal;
    }
    return null;
  }
}

class _SignalMiniCard extends StatelessWidget {
  final SignalInput? signal;
  final String fallbackTitle;
  final String fallbackValue;
  final String? action;
  final VoidCallback? onAction;

  const _SignalMiniCard({
    required this.signal,
    required this.fallbackTitle,
    required this.fallbackValue,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final source = signal?.source;
    final title = source == null ? fallbackTitle : _sourceLabel(source);
    final value = signal == null ? fallbackValue : _signalValue(signal!);
    final subtitle = signal == null
        ? 'No active signal'
        : _signalSubtitle(signal!);
    final high = (signal?.confidence ?? 0) >= 0.80;
    final color = high ? const Color(0xFFEF4444) : const Color(0xFFF97316);

    return Container(
      height: 138,
      padding: const EdgeInsets.all(12),
      decoration: _softBox(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _sourceIcon(source),
                size: 17,
                color: const Color(0xFF4F46E5),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF64748B),
              height: 1.25,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  action!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF4F46E5),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                Icon(Icons.arrow_upward_rounded, size: 12, color: color),
                const SizedBox(width: 3),
                Text(
                  high ? 'High' : 'Moderate',
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PrimaryCrisisCard extends StatelessWidget {
  final Crisis crisis;
  final DemoScenario? scenario;
  final VoidCallback onTap;

  const _PrimaryCrisisCard({
    required this.crisis,
    this.scenario,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(crisis.severity);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(
                  _crisisIcon(crisis.type),
                  color: Colors.white,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRIMARY CRISIS',
                      style: TextStyle(
                        fontSize: 9,
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${crisis.typeLabel} - ${crisis.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              _OutlinePill(
                label: crisis.severityLabel.toUpperCase(),
                color: color,
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF111827)),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _clean(
                (scenario != null && scenario!.activeSignals.isNotEmpty)
                    ? scenario!.activeSignals.first.content
                    : (crisis.signalSummaries.isNotEmpty
                          ? crisis.signalSummaries.first
                          : crisis.detectionReasoning),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF475569),
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Meta(icon: Icons.near_me_outlined, text: _distanceText(crisis)),
              _Meta(icon: Icons.schedule_outlined, text: 'Updated 10m ago'),
              _Meta(
                icon: Icons.article_outlined,
                text:
                    'Reports ${scenario != null ? (scenario!.activeSignals.length + 14) : (crisis.signalSummaries.length + 12)}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.track_changes_rounded,
                    size: 16,
                    color: Color(0xFF111827),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'View Details',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.chevron_right_rounded, color: Color(0xFF111827)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityReports extends StatelessWidget {
  final Crisis crisis;
  final DemoScenario scenario;
  final VoidCallback onViewAll;

  const _CommunityReports({
    required this.crisis,
    required this.scenario,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final reports = _homeReports(crisis, scenario);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _softBox(radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Community Crisis Feed',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(onPressed: onViewAll, child: const Text('View all')),
            ],
          ),
          const Text(
            'Verified local reports from residents, field teams, and response units.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          _ReportComposer(onTap: onViewAll),
          const SizedBox(height: 8),
          ...reports
              .take(4)
              .map(
                (report) => _ReportTile(
                  icon: report.icon,
                  author: report.author,
                  handle: report.handle,
                  time: report.time,
                  title: report.title,
                  subtitle: report.subtitle,
                  tag: report.tag,
                  location: report.location,
                  color: report.color,
                ),
              ),
        ],
      ),
    );
  }
}

class _ReportComposer extends StatelessWidget {
  final VoidCallback onTap;
  const _ReportComposer({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF5A5CE5), Color(0xFF3B82F6)],
                ),
              ),
              child: const Icon(
                Icons.add_alert_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Text(
                'Share a local crisis update',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF5A5CE5),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Post',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportTile extends StatefulWidget {
  final IconData icon;
  final String author;
  final String handle;
  final String time;
  final String title;
  final String subtitle;
  final String tag;
  final String location;
  final Color color;

  const _ReportTile({
    required this.icon,
    required this.author,
    required this.handle,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.location,
    required this.color,
  });

  @override
  State<_ReportTile> createState() => _ReportTileState();
}

class _ReportTileState extends State<_ReportTile> {
  late int _likes;
  late int _comments;
  late int _shares;
  bool _liked = false;
  final List<String> _commentItems = [];

  IconData get icon => widget.icon;
  String get author => widget.author;
  String get handle => widget.handle;
  String get time => widget.time;
  String get title => widget.title;
  String get subtitle => widget.subtitle;
  String get tag => widget.tag;
  String get location => widget.location;
  Color get color => widget.color;

  @override
  void initState() {
    super.initState();
    final seed = title.codeUnits.fold<int>(0, (sum, c) => sum + c);
    _likes = 18 + seed % 34;
    _comments = 4 + seed % 9;
    _shares = 6 + seed % 13;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
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
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF111827),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.verified_rounded, color: color, size: 14),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$handle · $time',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _OutlinePill(label: tag, color: color),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF64748B),
              height: 1.32,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 108,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.14)),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 16,
                  top: 16,
                  child: Icon(
                    icon,
                    color: color.withValues(alpha: 0.36),
                    size: 42,
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: _FeedPill(label: location, color: color),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Row(
                    children: [
                      _FeedPill(label: 'Local update', color: color),
                      const SizedBox(width: 8),
                      _FeedPill(label: tag, color: color),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const _FeedStat(icon: Icons.visibility_outlined, text: '1.8k'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _FeedAction(
                icon: _liked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                text: '$_likes',
                active: _liked,
                activeColor: const Color(0xFFEF4444),
                onTap: () {
                  setState(() {
                    _liked = !_liked;
                    _likes += _liked ? 1 : -1;
                  });
                },
              ),
              const SizedBox(width: 10),
              _FeedAction(
                icon: Icons.chat_bubble_outline_rounded,
                text: '$_comments',
                activeColor: const Color(0xFF5A5CE5),
                onTap: _showComments,
              ),
              const SizedBox(width: 10),
              _FeedAction(
                icon: Icons.repeat_rounded,
                text: '$_shares',
                activeColor: const Color(0xFF10B981),
                onTap: () => setState(() => _shares++),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showComments() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  18,
                  14,
                  18,
                  18 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Comments', style: CiroTypography.headingSmall),
                    const SizedBox(height: 10),
                    _CommentRow(
                      name: 'CIRO verifier',
                      text:
                          'This report is being matched with weather and traffic signals.',
                      color: color,
                    ),
                    _CommentRow(
                      name: 'Local resident',
                      text:
                          'Water level is still visible near the service road.',
                      color: color,
                    ),
                    ..._commentItems.map(
                      (text) => _CommentRow(
                        name: 'You',
                        text: text,
                        color: const Color(0xFF5A5CE5),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            minLines: 1,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Add a useful update',
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Material(
                          color: const Color(0xFF5A5CE5),
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              final text = controller.text.trim();
                              if (text.isEmpty) return;
                              setState(() {
                                _commentItems.add(text);
                                _comments++;
                              });
                              setSheet(() {});
                              controller.clear();
                            },
                            child: const SizedBox(
                              width: 48,
                              height: 48,
                              child: Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _FeedPill extends StatelessWidget {
  final String label;
  final Color color;

  const _FeedPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FeedAction extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _FeedAction({
    required this.icon,
    required this.text,
    required this.activeColor,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : const Color(0xFF64748B);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? activeColor.withValues(alpha: 0.10)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active
                ? activeColor.withValues(alpha: 0.20)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  final String name;
  final String text;
  final Color color;

  const _CommentRow({
    required this.name,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(Icons.person_rounded, size: 15, color: color),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11.5,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
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

class _FeedStat extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeedStat({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _HomeReport {
  final IconData icon;
  final String author;
  final String handle;
  final String time;
  final String title;
  final String subtitle;
  final String tag;
  final String location;
  final Color color;

  const _HomeReport({
    required this.icon,
    required this.author,
    required this.handle,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.location,
    required this.color,
  });
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onContacts;
  final VoidCallback onSafety;
  final VoidCallback onShelters;
  final VoidCallback onMap;

  const _QuickActions({
    required this.onContacts,
    required this.onSafety,
    required this.onShelters,
    required this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: _softBox(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickAction(
                icon: Icons.call_rounded,
                label: 'Emergency\nContacts',
                color: const Color(0xFF3B5BFF),
                bg: const Color(0xFFEFF2FF),
                onTap: onContacts,
              ),
              _QuickAction(
                icon: Icons.health_and_safety_rounded,
                label: 'Safety Tips',
                color: const Color(0xFF10B981),
                bg: const Color(0xFFEAFBF2),
                onTap: onSafety,
              ),
              _QuickAction(
                icon: Icons.home_work_rounded,
                label: 'Shelters',
                color: const Color(0xFF7C3AED),
                bg: const Color(0xFFF3EFFF),
                onTap: onShelters,
              ),
              _QuickAction(
                icon: Icons.map_rounded,
                label: 'Live Map',
                color: const Color(0xFF0EA5E9),
                bg: const Color(0xFFE0F2FE),
                onTap: onMap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 66,
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 7),
            SizedBox(
              height: 28,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final int badge;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: _softBox(radius: 999),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: const Color(0xFF111827), size: 20),
            if (badge > 0)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  width: 17,
                  height: 17,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge > 9 ? '9+' : '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OutlinePill extends StatelessWidget {
  final String label;
  final Color color;
  const _OutlinePill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 13, color: const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailing;

  const _SheetRow({required this.title, required this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            Text(
              trailing!,
              style: const TextStyle(
                color: Color(0xFF4F46E5),
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

BoxDecoration _softBox({required double radius}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: const Color(0xFFE2E8F0)),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.025),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ],
);

Color _severityColor(SeverityLevel severity) => switch (severity) {
  SeverityLevel.critical => const Color(0xFFEF4444),
  SeverityLevel.high => const Color(0xFFEF4444),
  SeverityLevel.moderate => const Color(0xFFF97316),
  SeverityLevel.low => const Color(0xFF10B981),
  SeverityLevel.unknown => const Color(0xFF64748B),
};

IconData _crisisIcon(CrisisType type) => switch (type) {
  CrisisType.urbanFlooding => Icons.flood_rounded,
  CrisisType.roadBlockage => Icons.add_road_rounded,
  CrisisType.accident => Icons.car_crash_rounded,
  CrisisType.heatwave => Icons.thermostat_rounded,
  CrisisType.powerOutage => Icons.power_off_rounded,
};

IconData _sourceIcon(SignalSource? source) => switch (source) {
  SignalSource.weatherAlert => Icons.thunderstorm_rounded,
  SignalSource.trafficData => Icons.directions_car_rounded,
  SignalSource.socialPost => Icons.article_outlined,
  SignalSource.citizenReport => Icons.person_pin_circle_rounded,
  SignalSource.emergencyCall => Icons.call_rounded,
  SignalSource.mockSensor => Icons.sensors_rounded,
  SignalSource.fieldReport => Icons.assignment_rounded,
  null => Icons.sensors_rounded,
};

String _sourceLabel(SignalSource source) => switch (source) {
  SignalSource.weatherAlert => 'Weather',
  SignalSource.trafficData => 'Traffic',
  SignalSource.socialPost => 'News / Reports',
  SignalSource.citizenReport => 'Citizen Report',
  SignalSource.emergencyCall => 'Emergency Calls',
  SignalSource.mockSensor => 'Sensors',
  SignalSource.fieldReport => 'Field Report',
};

String _signalValue(SignalInput signal) {
  final text = signal.content.toLowerCase();
  if (signal.source == SignalSource.weatherAlert) {
    if (text.contains('heavy') || text.contains('rain')) return 'Heavy Rain';
    if (text.contains('heat')) return 'Extreme Heat';
    if (text.contains('clear')) return 'Clear';
    return 'Weather Alert';
  }
  if (signal.source == SignalSource.trafficData) {
    if (text.contains('blocked') || text.contains('standstill')) {
      return 'Blocked';
    }
    if (text.contains('congestion') || text.contains('slow')) return 'Slow';
    return 'Normal';
  }
  if (signal.source == SignalSource.socialPost) {
    final match = RegExp(
      r'(\d+)\s+(new|relevant|reports?)',
      caseSensitive: false,
    ).firstMatch(signal.content);
    return match != null ? '${match.group(1)} New' : 'Active';
  }
  return '${(signal.confidence * 100).round()}%';
}

String _signalSubtitle(SignalInput signal) {
  final cleaned = _clean(signal.content);
  if (signal.source == SignalSource.weatherAlert) {
    final rain = RegExp(
      r'(\d+)\s?mm',
      caseSensitive: false,
    ).firstMatch(cleaned);
    if (rain != null) return '${rain.group(1)} mm';
  }
  if (signal.source == SignalSource.trafficData) {
    if (cleaned.contains('G-10')) return 'G-10 Markaz\n3 zones';
    if (cleaned.contains('Delay:')) return cleaned;
  }
  return cleaned;
}

String _distanceText(Crisis crisis) {
  if (crisis.location.toLowerCase().contains('g-10')) return '2.4 km away';
  return 'Nearby';
}

List<_HomeReport> _homeReports(Crisis crisis, DemoScenario scenario) {
  final location = crisis.location;
  if (crisis.type == CrisisType.urbanFlooding) {
    return [
      _HomeReport(
        icon: Icons.water_drop_rounded,
        author: 'Ayesha Khan',
        handle: '@g10_resident',
        time: '4m',
        title: 'Water rising near G-10 Markaz',
        subtitle: 'Resident report matches rainfall and traffic slowdown.',
        tag: 'Verified',
        location: 'G-10 Markaz',
        color: const Color(0xFF3B82F6),
      ),
      _HomeReport(
        icon: Icons.traffic_rounded,
        author: 'Traffic Warden Unit',
        handle: '@ict_traffic',
        time: '8m',
        title: 'Slow traffic on service road',
        subtitle: 'Three nearby segments are moving below normal speed.',
        tag: 'Traffic',
        location: 'Service Road West',
        color: const Color(0xFFF97316),
      ),
      _HomeReport(
        icon: Icons.home_work_rounded,
        author: 'Relief Desk',
        handle: '@ciro_relief',
        time: '12m',
        title: 'Shelter intake ready',
        subtitle: 'G-10 Community Center can receive families if needed.',
        tag: 'Ready',
        location: 'G-10 Community Center',
        color: const Color(0xFF10B981),
      ),
      _HomeReport(
        icon: Icons.local_hospital_rounded,
        author: 'PIMS Emergency Desk',
        handle: '@pims_intake',
        time: '15m',
        title: 'Triage capacity checked',
        subtitle:
            'Emergency wing is ready for minor injuries and exposure cases from nearby flooded lanes.',
        tag: 'Hospital',
        location: 'PIMS',
        color: const Color(0xFF0EA5E9),
      ),
      _HomeReport(
        icon: Icons.construction_rounded,
        author: 'Field Team 3',
        handle: '@field_ops',
        time: '18m',
        title: 'Drainage crew requested',
        subtitle:
            'Standing water reported near the market edge. Utility team asked to inspect drain blockage.',
        tag: 'Action',
        location: 'G-10/2',
        color: const Color(0xFF8B5CF6),
      ),
      _HomeReport(
        icon: Icons.route_rounded,
        author: 'Route Monitor',
        handle: '@ciro_routes',
        time: '22m',
        title: 'Safer approach route available',
        subtitle:
            'Response units should approach from the north side to avoid slow service-road traffic.',
        tag: 'Route',
        location: 'Nazim-ud-din Road',
        color: const Color(0xFF14B8A6),
      ),
    ];
  }

  final mainSignal = scenario.activeSignals.isNotEmpty
      ? _clean(scenario.activeSignals.first.content)
      : crisis.detectionReasoning;

  return [
    _HomeReport(
      icon: _crisisIcon(crisis.type),
      author: 'CIRO Watch',
      handle: '@ciro_live',
      time: 'now',
      title: '${crisis.typeLabel} update',
      subtitle: mainSignal,
      tag: crisis.severityLabel,
      location: location,
      color: _severityColor(crisis.severity),
    ),
    _HomeReport(
      icon: Icons.person_pin_circle_rounded,
      author: 'Citizen Reporter',
      handle: '@nearby_report',
      time: '6m',
      title: 'Citizen report near $location',
      subtitle: 'CIRO is checking nearby reports before widening alerts.',
      tag: 'Checking',
      location: location,
      color: const Color(0xFF5A5CE5),
    ),
    _HomeReport(
      icon: Icons.route_rounded,
      author: 'Route Monitor',
      handle: '@ciro_routes',
      time: '9m',
      title: 'Route guidance available',
      subtitle: 'Open the map to see safer movement options.',
      tag: 'Map',
      location: location,
      color: const Color(0xFF10B981),
    ),
  ];
}

String _clean(String text) => text
    .replaceAll('â€”', '-')
    .replaceAll('Â·', '|')
    .replaceAll('Â°C', 'C')
    .replaceAll('â€“', '-')
    .replaceAll('ðŸš¨', '')
    .replaceAll('âš ï¸', '')
    .replaceAll('âœ…', '')
    .replaceAll('ðŸ”´', '')
    .trim();

List<(String, String)> _tips(CrisisType type) => switch (type) {
  CrisisType.urbanFlooding => const [
    (
      'Avoid underpasses',
      'Do not drive through standing water or flooded lanes.',
    ),
    (
      'Move valuables higher',
      'Protect documents, electronics, and essentials from water exposure.',
    ),
    (
      'Use official routes',
      'Follow CIRO rerouting and emergency service instructions.',
    ),
  ],
  CrisisType.heatwave => const [
    (
      'Hydrate frequently',
      'Drink water before feeling thirsty and avoid direct sun.',
    ),
    (
      'Check vulnerable people',
      'Elderly people and outdoor workers need priority checks.',
    ),
    (
      'Use cooling sites',
      'Move to shaded or cooled public locations when possible.',
    ),
  ],
  CrisisType.accident => const [
    (
      'Avoid the scene',
      'Keep lanes clear for ambulances and traffic response.',
    ),
    ('Slow down nearby', 'Secondary collisions are common near blocked roads.'),
    (
      'Report casualties',
      'Share verified injury details with emergency operators.',
    ),
  ],
  CrisisType.powerOutage => const [
    (
      'Unplug appliances',
      'Protect devices from power surge when electricity returns.',
    ),
    (
      'Preserve phone battery',
      'Use low power mode for emergency communication.',
    ),
    ('Check backup power', 'Critical medical devices need alternate supply.'),
  ],
  CrisisType.roadBlockage => const [
    (
      'Use alternate route',
      'Avoid the affected corridor until clearance is confirmed.',
    ),
    (
      'Keep emergency lane clear',
      'Do not stop or park near response vehicles.',
    ),
    ('Follow traffic wardens', 'Manual control may override normal signals.'),
  ],
};
