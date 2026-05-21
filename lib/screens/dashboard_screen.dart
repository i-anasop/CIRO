// CIRO - Home command center
// Reference-style operational dashboard with fully wired actions.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/interactive_map_helper.dart';
import '../components/settings_sheets.dart';
import '../models/crisis.dart';
import '../models/demo_scenario.dart';
import '../models/signal.dart';
import '../services/app_mode_service.dart';
import '../services/notification_service.dart';
import '../services/scenario_engine.dart';
import '../services/user_profile_service.dart';
import '../services/post_database_service.dart';
import 'dart:convert';
import '../services/places_service.dart';
import '../services/app_config.dart';
import '../theme/typography.dart';
import '../data/mock_crises.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static double _savedHomeScrollOffset = 0;

  late final ScrollController _homeScrollController;
  bool _demoNotificationScheduled = false;

  @override
  void initState() {
    super.initState();
    _homeScrollController = ScrollController(
      initialScrollOffset: _savedHomeScrollOffset,
    );
    _homeScrollController.addListener(_rememberHomeScroll);
    _scheduleDemoNotification();
  }

  @override
  void dispose() {
    _homeScrollController.removeListener(_rememberHomeScroll);
    _homeScrollController.dispose();
    super.dispose();
  }

  void _rememberHomeScroll() {
    if (!_homeScrollController.hasClients) return;
    _savedHomeScrollOffset = _homeScrollController.offset;
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
    await Future.delayed(const Duration(milliseconds: 650));
    await ScenarioEngine.instance.runRealSignalAnalysis();
  }

  Future<void> _handleRefresh() async {
    if (AppModeService.instance.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) setState(() {});
    } else {
      await _refreshRealMode();
    }
  }

  String _crisisLabel(CrisisType type) {
    switch (type) {
      case CrisisType.urbanFlooding:
        return 'Urban Flooding';
      case CrisisType.heatwave:
        return 'Heatwave';
      case CrisisType.accident:
        return 'Accident';
      case CrisisType.powerOutage:
        return 'Power Outage';
      case CrisisType.roadBlockage:
        return 'Road Blockage';
    }
  }

  void _showEmergencyContacts() {
    showSettingsSheet(context, const EmergencyContactsSheet());
  }

  void _showSafetyTips() {
    showSettingsSheet(context, const SafetyTipsSheet());
  }

  void _showShelters() {
    final isDemo = AppModeService.instance.isDemoMode;

    if (isDemo) {
      // Demo mode: hardcoded G-10 shelters
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
      return;
    }

    // Real mode: fetch from Google Places API
    final crisis = ScenarioEngine.instance.activeCrisis;
    final coords = RegExp(r'-?\d+\.?\d*')
        .allMatches(crisis.coordinates)
        .map((m) => double.tryParse(m.group(0)!))
        .whereType<double>()
        .toList();
    final lat = coords.length >= 2 ? coords[0] : null;
    final lng = coords.length >= 2 ? coords[1] : null;

    if (lat == null || lng == null) {
      _showActionSheet(
        title: 'Nearby Facilities',
        subtitle: 'Location unavailable. Please refresh.',
        icon: Icons.home_work_rounded,
        color: const Color(0xFF7C3AED),
        children: const [
          _SheetRow(
            title: 'No location data',
            subtitle: 'Tap refresh to update GPS location.',
          ),
        ],
      );
      return;
    }

    // Show loading then fetch
    _showActionSheet(
      title: 'Nearby Facilities',
      subtitle: 'Searching hospitals, shelters, police, fire stations...',
      icon: Icons.home_work_rounded,
      color: const Color(0xFF7C3AED),
      children: const [
        _SheetRow(
          title: 'Loading...',
          subtitle: 'Fetching from Google Places API',
        ),
      ],
    );

    PlacesService.instance.fetchNearbyPlaces(lat, lng).then((places) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading sheet
      if (places.isEmpty) {
        _showActionSheet(
          title: 'Nearby Facilities',
          subtitle: 'No facilities found nearby. Check Places API key.',
          icon: Icons.home_work_rounded,
          color: const Color(0xFF7C3AED),
          children: const [
            _SheetRow(
              title: 'No results',
              subtitle: 'Google Places API returned no nearby facilities.',
            ),
          ],
        );
        return;
      }
      _showActionSheet(
        title: 'Nearby Facilities',
        subtitle:
            '${places.length} real facilities within 5 km of ${crisis.location}.',
        icon: Icons.home_work_rounded,
        color: const Color(0xFF7C3AED),
        children: places
            .take(10)
            .map(
              (p) => _SheetRow(
                title: '${p.typeLabel}: ${p.name}',
                subtitle:
                    '${p.address}${p.isOpen == true
                        ? ' • Open'
                        : p.isOpen == false
                        ? ' • Closed'
                        : ''}${p.rating != null ? ' • ★${p.rating!.toStringAsFixed(1)}' : ''}',
                trailing: p.distanceLabel,
              ),
            )
            .toList(),
      );
    });
  }

  void _showLocationPreview() {
    final engine = ScenarioEngine.instance;
    final crisis = engine.activeCrisis;
    final isDemo = AppModeService.instance.isDemoMode;

    // Parse coordinates dynamically
    final matches = RegExp(r'-?\d+\.?\d*')
        .allMatches(crisis.coordinates)
        .map((m) => double.tryParse(m.group(0)!))
        .whereType<double>()
        .toList();
    final double lat = matches.length >= 2 ? matches[0] : 33.6946;
    final double lng = matches.length >= 2 ? matches[1] : 73.0179;
    final cityWide = !isDemo && _isIslamabadLocation(crisis, lat, lng);

    final locationTitle = isDemo ? 'Demo Location' : 'Live GPS Location';
    final locationSubtitle = isDemo
        ? 'G-10, Islamabad boundary preview. Change location from Settings.'
        : 'Active location: ${crisis.location}. Managed dynamically via device GPS.';

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
                Text(
                  locationTitle,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  locationSubtitle,
                  style: const TextStyle(
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
                      latitude: lat,
                      longitude: lng,
                      mapCenterLatitude: cityWide ? 33.6844 : null,
                      mapCenterLongitude: cityWide ? 73.0479 : null,
                      zoom: cityWide ? 11 : 15,
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

  bool _isIslamabadLocation(Crisis crisis, double lat, double lng) {
    return crisis.location.toLowerCase().contains('islamabad') ||
        (lat >= 33.55 && lat <= 33.85 && lng >= 72.80 && lng <= 73.25);
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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.82,
              ),
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      children: children,
                    ),
                  ),
                ],
              ),
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

        final matchingCrises = !isDemo
            ? const <Crisis>[]
            : mockCrises.where((c) {
                if (c.status == CrisisStatus.resolved) return false;
                final sameLocation =
                    c.location.split(',').first.trim().toLowerCase() ==
                    crisis.location.split(',').first.trim().toLowerCase();
                final sameType = c.type == crisis.type;
                return !(sameLocation && sameType);
              }).toList();

        return Stack(
          children: [
            Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              body: SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  color: const Color(0xFF2563EB),
                  backgroundColor: Colors.white,
                  onRefresh: _handleRefresh,
                  child: ListView(
                    controller: _homeScrollController,
                    key: const PageStorageKey<String>('home-command-scroll'),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 104),
                    children: [
                      _TopBar(
                        location: isDemo ? 'G-10, Islamabad' : crisis.location,
                        onLocationTap: _showLocationPreview,
                        onNotificationsTap: () =>
                            context.go('/notifications'),
                        onProfileTap: () => context.push('/profile'),
                      ),
                      const SizedBox(height: 20),
                      _BrandHeader(isDemo: isDemo),
                      if (!isDemo && engine.injectedRealCrisisType != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFBFDBFE),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF1E40AF,
                                ).withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.science_rounded,
                                color: Color(0xFF2563EB),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Simulating ${_crisisLabel(engine.injectedRealCrisisType!)} threat at actual GPS location.',
                                  style: const TextStyle(
                                    color: Color(0xFF1E40AF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (!isDemo &&
                          crisis.status == CrisisStatus.monitoring) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFBBF7D0),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF15803D,
                                ).withValues(alpha: 0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF22C55E),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.shield_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'SYSTEM ACTIVE & SAFE',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF15803D),
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'No Threats in ${crisis.location}',
                                          style: const TextStyle(
                                            color: Color(0xFF166534),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'CIRO is actively monitoring real-time weather alerts, public feeds, traffic conditions, and IoT signals. All data remains within normal limits. No local crises detected.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF1E293B),
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 16),
                        _ActiveRiskCard(
                          crisis: crisis,
                          scenario: scenario,
                          onTap: () =>
                              context.go('/home/crisis-detail', extra: crisis),
                          severityColor: severity,
                        ),
                      ],
                      const SizedBox(height: 14),
                      _SignalCards(
                        signals: signals,
                        onViewReports: () => context.go('/reports'),
                      ),
                      const SizedBox(height: 14),
                      _GoogleWeatherCard(
                        weatherSignal: signals.firstWhere(
                          (s) => s.source == SignalSource.weatherAlert,
                          orElse: () => const SignalInput(
                            source: SignalSource.weatherAlert,
                            content:
                                'Live OpenWeather: Clear (clear sky), temp 24.0°C, feels 25.0°C, rain None, alert No Alert.',
                            confidence: 1.0,
                            isActive: false,
                          ),
                        ),
                        locationLabel: isDemo
                            ? 'G-10, Islamabad'
                            : crisis.location,
                      ),
                      if (matchingCrises.isNotEmpty) ...[
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
                              ...matchingCrises
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
                                          if (otherCrisis.id ==
                                              'CRS-2024-002') {
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
                      ],
                      const SizedBox(height: 14),
                      _QuickActions(
                        onContacts: _showEmergencyContacts,
                        onSafety: _showSafetyTips,
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

  const _TopBar({
    required this.location,
    required this.onLocationTap,
    required this.onNotificationsTap,
    required this.onProfileTap,
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
                          errorBuilder: (_, __, ___) => Icon(
                            UserProfileService.avatarIcons[
                                profile.avatarIndex],
                            color: Colors.white,
                            size: 19,
                          ),
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
    final engine = ScenarioEngine.instance;
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
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!isDemo) ...[
              if (engine.isAiActive)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${AppConfig.instance.aiEngineLabel} Active',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF047857),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              if (engine.isUsingFallback)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Local Analysis Active',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF1D4ED8),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
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

    // Weather logic
    String weatherTitle = 'Sun';
    String weatherValue = 'Clear';
    String weatherSubtitle = 'Clear skies';
    IconData weatherIcon = Icons.wb_sunny_rounded;

    if (weather != null) {
      final text = weather.content.toLowerCase();

      // Determine if there is active rain
      final hasRain =
          text.contains('rain') ||
          text.contains('drizzle') ||
          text.contains('thunderstorm') ||
          text.contains('shower');

      // Parse rainfall last hour or condition
      double rainfall = 0.0;
      final rainMatch = RegExp(r'(\d+(?:\.\d+)?)\s*mm').firstMatch(text);
      if (rainMatch != null) {
        rainfall = double.tryParse(rainMatch.group(1) ?? '0') ?? 0.0;
      }

      // Check temperature for subtitle
      String tempPart = '';
      final tempMatch = RegExp(
        r'(\d+(?:\.\d+)?)\s*°?c',
        caseSensitive: false,
      ).firstMatch(text);
      if (tempMatch != null) {
        tempPart = '${tempMatch.group(1)}°C';
      }

      if (hasRain || rainfall > 0.0) {
        weatherTitle = 'Rain';
        weatherIcon = Icons.water_drop_rounded;
        if (rainfall > 5.0 ||
            text.contains('heavy') ||
            text.contains('flood') ||
            text.contains('storm')) {
          weatherValue = 'Heavy';
        } else {
          weatherValue = 'Slow';
        }
        if (rainfall > 0) {
          weatherSubtitle =
              '${rainfall.toStringAsFixed(0)} mm${tempPart.isNotEmpty ? ' · $tempPart' : ''}';
        } else {
          weatherSubtitle =
              'Light Rain${tempPart.isNotEmpty ? ' · $tempPart' : ''}';
        }
      } else {
        weatherTitle = 'Sun';
        weatherValue = 'Clear';
        weatherIcon = Icons.wb_sunny_rounded;
        if (tempPart.isNotEmpty) {
          weatherSubtitle = '$tempPart · Clear';
        } else {
          weatherSubtitle = 'Clear skies';
        }
      }
    }

    // Traffic logic
    String trafficTitle = 'Traffic';
    String trafficValue = 'Normal';
    String trafficSubtitle = 'Live: Low congestion';
    IconData trafficIcon = Icons.directions_car_rounded;

    if (traffic != null) {
      final text = traffic.content.toLowerCase();
      final cleaned = _clean(traffic.content);

      if (text.contains('blocked') || text.contains('standstill')) {
        trafficValue = 'Blocked';
        trafficIcon = Icons.report_problem_rounded;
      } else if (text.contains('congestion') || text.contains('slow')) {
        trafficValue = 'Slow';
        trafficIcon = Icons.traffic_rounded;
      } else {
        trafficValue = 'Normal';
        trafficIcon = Icons.directions_car_rounded;
      }

      if (cleaned.contains('delay')) {
        final delayMatch = RegExp(
          r'delay\s*(\d+\s*m|none)',
          caseSensitive: false,
        ).firstMatch(cleaned);
        if (delayMatch != null) {
          trafficSubtitle = 'Delay: ${delayMatch.group(1)}';
        } else {
          trafficSubtitle = cleaned;
        }
      } else {
        final congMatch = RegExp(
          r'(\w+)\s+congestion',
          caseSensitive: false,
        ).firstMatch(cleaned);
        if (congMatch != null) {
          trafficSubtitle = 'Live: ${congMatch.group(1)} congestion';
        } else {
          trafficSubtitle = cleaned;
        }
      }

      if (trafficSubtitle.length > 35) {
        trafficSubtitle = '${trafficSubtitle.substring(0, 32)}...';
      }
    }

    return Row(
      children: [
        Expanded(
          child: _SignalMiniCard(
            signal: weather,
            fallbackTitle: 'Weather',
            fallbackValue: 'Normal',
            customTitle: weatherTitle,
            customValue: weatherValue,
            customSubtitle: weatherSubtitle,
            customIcon: weatherIcon,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SignalMiniCard(
            signal: traffic,
            fallbackTitle: 'Traffic',
            fallbackValue: 'Clear',
            customTitle: trafficTitle,
            customValue: trafficValue,
            customSubtitle: trafficSubtitle,
            customIcon: trafficIcon,
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
  final String? customTitle;
  final String? customValue;
  final String? customSubtitle;
  final IconData? customIcon;

  const _SignalMiniCard({
    required this.signal,
    required this.fallbackTitle,
    required this.fallbackValue,
    this.customTitle,
    this.customValue,
    this.customSubtitle,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    final source = signal?.source;
    final title =
        customTitle ?? (source == null ? fallbackTitle : _sourceLabel(source));
    final value =
        customValue ?? (signal == null ? fallbackValue : _signalValue(signal!));
    final subtitle =
        customSubtitle ??
        (signal == null ? 'No active signal' : _signalSubtitle(signal!));
    final icon = customIcon ?? _sourceIcon(source);
    final footer = _signalFooter(value, subtitle);

    return Container(
      height: 138,
      padding: const EdgeInsets.all(12),
      decoration: _softBox(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: const Color(0xFF4F46E5)),
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
          Row(
            children: [
              Icon(footer.icon, size: 12, color: footer.color),
              const SizedBox(width: 3),
              Text(
                footer.label,
                style: TextStyle(
                  fontSize: 10,
                  color: footer.color,
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

class _SignalFooter {
  final String label;
  final IconData icon;
  final Color color;

  const _SignalFooter(this.label, this.icon, this.color);
}

_SignalFooter _signalFooter(String value, String subtitle) {
  final text = '$value $subtitle'.toLowerCase();
  if (text.contains('blocked') || text.contains('heavy')) {
    return const _SignalFooter(
      'Action needed',
      Icons.arrow_upward_rounded,
      Color(0xFFEF4444),
    );
  }
  if (text.contains('slow') ||
      text.contains('delay') ||
      text.contains('light rain')) {
    return const _SignalFooter(
      'Monitor',
      Icons.trending_flat_rounded,
      Color(0xFFF97316),
    );
  }
  if (text.contains('clear') ||
      text.contains('normal') ||
      text.contains('low congestion')) {
    return const _SignalFooter(
      'Normal',
      Icons.check_circle_rounded,
      Color(0xFF059669),
    );
  }
  return const _SignalFooter('Live', Icons.sensors_rounded, Color(0xFF4F46E5));
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

class _CommunityReports extends StatefulWidget {
  final Crisis crisis;
  final DemoScenario scenario;
  final VoidCallback onViewAll;

  const _CommunityReports({
    required this.crisis,
    required this.scenario,
    required this.onViewAll,
  });

  @override
  State<_CommunityReports> createState() => _CommunityReportsState();
}

class _CommunityReportsState extends State<_CommunityReports> {
  List<_HomeReport> _customReports = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final list = await PostDatabaseService.instance.loadPosts();
      final List<_HomeReport> loaded = [];
      for (final map in list) {
        final author = map['author'] ?? 'Anonymous';
        final colorHex = map['colorHex'] ?? '#4F46E5';
        final color = Color(int.parse(colorHex.replaceAll('#', ''), radix: 16));
        final tag = map['tag'] ?? 'New';
        final iconName = map['iconName'] ?? '';
        IconData icon;
        switch (iconName) {
          case 'water_drop':
            icon = Icons.water_drop_rounded;
            break;
          case 'car_crash':
            icon = Icons.car_crash_rounded;
            break;
          case 'power_off':
            icon = Icons.power_off_rounded;
            break;
          case 'thermostat':
            icon = Icons.thermostat_rounded;
            break;
          default:
            icon = Icons.warning_rounded;
        }

        loaded.add(
          _HomeReport(
            icon: icon,
            author: author,
            handle: map['handle'] ?? '@local_reporter',
            time: 'now',
            title: map['title'] ?? '',
            subtitle: map['body'] ?? '',
            tag: tag,
            location: map['location'] ?? '',
            color: color,
            likes: map['likes'] ?? 0,
            views: 12,
            isOfficial: false,
            avatarImageData: map['customAvatarUrl'],
          ),
        );
      }
      if (mounted) {
        setState(() {
          _customReports = loaded;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseReports = _homeReports(widget.crisis, widget.scenario);
    final allReports = <_HomeReport>[];
    allReports.addAll(_customReports);
    if (!AppModeService.instance.isDemoMode) {
      allReports.addAll(_realSocialReports());
    }
    allReports.addAll(baseReports);

    // Filter & Sort: verified/official first, then by popularity (likes + views)
    allReports.sort((a, b) {
      final aPriority = (a.isOfficial || a.tag == 'Verified') ? 1 : 0;
      final bPriority = (b.isOfficial || b.tag == 'Verified') ? 1 : 0;
      if (aPriority != bPriority) {
        return bPriority.compareTo(aPriority);
      }
      final aScore = (a.likes * 5) + a.views;
      final bScore = (b.likes * 5) + b.views;
      return bScore.compareTo(aScore);
    });

    final displayReports = allReports.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community Crisis Feed',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Most critical and active reports in this region',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: widget.onViewAll,
                child: const Text(
                  'View all',
                  style: TextStyle(
                    color: Color(0xFF4F46E5),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ReportComposer(onTap: widget.onViewAll),
          const SizedBox(height: 8),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            ...displayReports.map(
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
                likes: report.likes,
                views: report.views,
                isOfficial: report.isOfficial,
                avatarImageData: report.avatarImageData,
              ),
            ),
        ],
      ),
    );
  }

  List<_HomeReport> _realSocialReports() {
    return ScenarioEngine.instance.latestSocialPosts.map((post) {
      final color = _socialColor(post.matchedKeyword);
      return _HomeReport(
        icon: _socialIcon(post.matchedKeyword),
        author: post.author,
        handle: post.handle,
        time: post.ageLabel,
        title: 'Relevant public update',
        subtitle: post.text,
        tag: post.verifiedSource ? 'Official watch' : 'Public signal',
        location: post.location,
        color: color,
        likes: (post.confidence * 18).round().clamp(4, 22),
        views: (post.confidence * 90).round().clamp(18, 120),
        isOfficial: post.verifiedSource,
      );
    }).toList();
  }
}

class _ReportComposer extends StatelessWidget {
  final VoidCallback onTap;
  const _ReportComposer({required this.onTap});

  ImageProvider? _getAvatarImage(String? image) {
    if (image == null || image.isEmpty) return null;
    if (image.startsWith('data:image')) {
      try {
        final base64String = image.split(',').last;
        return MemoryImage(base64Decode(base64String));
      } catch (_) {
        return NetworkImage(image);
      }
    }
    return NetworkImage(image);
  }

  @override
  Widget build(BuildContext context) {
    final profile = UserProfileService.instance;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(1.5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFC084FC), Color(0xFF6366F1)],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(1.5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFF3E8FF),
                  backgroundImage: _getAvatarImage(profile.customAvatarUrl),
                  onBackgroundImageError: profile.customAvatarUrl != null
                      ? (_, __) {}
                      : null,
                  child: profile.customAvatarUrl != null
                      ? null
                      : Icon(
                          UserProfileService.avatarIcons[profile.avatarIndex
                              .clamp(
                                0,
                                UserProfileService.avatarIcons.length - 1,
                              )],
                          color:
                              UserProfileService.avatarColors[profile
                                  .avatarIndex
                                  .clamp(
                                    0,
                                    UserProfileService.avatarColors.length - 1,
                                  )],
                          size: 14,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Report a crisis...',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
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
  final int likes;
  final int views;
  final bool isOfficial;
  final String? avatarImageData;

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
    required this.likes,
    required this.views,
    required this.isOfficial,
    this.avatarImageData,
  });

  @override
  State<_ReportTile> createState() => _ReportTileState();
}

class _ReportTileState extends State<_ReportTile> {
  late int _likes;
  late int _comments;
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
    _likes = widget.likes;
    _comments = 2 + (widget.title.length % 4);
  }

  ImageProvider? _getAvatarImage(String? image) {
    if (image == null || image.isEmpty) return null;
    if (image.startsWith('data:image')) {
      try {
        final base64String = image.split(',').last;
        return MemoryImage(base64Decode(base64String));
      } catch (_) {
        return NetworkImage(image);
      }
    }
    return NetworkImage(image);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: widget.isOfficial
                        ? [const Color(0xFF5A5CE5), const Color(0xFF3B82F6)]
                        : [const Color(0xFFC084FC), const Color(0xFF6366F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: widget.color.withValues(alpha: 0.12),
                    backgroundImage: _getAvatarImage(widget.avatarImageData),
                    onBackgroundImageError: widget.avatarImageData != null
                        ? (_, __) {}
                        : null,
                    child: widget.avatarImageData != null
                        ? null
                        : Icon(widget.icon, color: widget.color, size: 16),
                  ),
                ),
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
                            widget.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF111827),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (widget.isOfficial) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified_rounded,
                            color: widget.color,
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.handle} • ${widget.time}',
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
              _OutlinePill(label: widget.tag, color: widget.color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  widget.color.withValues(alpha: 0.08),
                  const Color(0xFFF8FAFC),
                  widget.color.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: widget.color.withValues(alpha: 0.08),
                width: 1.0,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -16,
                  top: -16,
                  child: Opacity(
                    opacity: 0.08,
                    child: Icon(widget.icon, size: 110, color: widget.color),
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 14,
                  child: _FeedPill(label: widget.location, color: widget.color),
                ),
                Positioned(
                  left: 14,
                  bottom: 14,
                  right: 14,
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(widget.icon, color: widget.color, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF1F2937),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Verified Threat Signal Map Node',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
              const Spacer(),
              _FeedStat(
                icon: Icons.visibility_outlined,
                text: '${widget.views}',
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
  final int likes;
  final int views;
  final bool isOfficial;
  final String? avatarImageData;

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
    required this.likes,
    required this.views,
    required this.isOfficial,
    this.avatarImageData,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11.5,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 54),
              child: Text(
                trailing!,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF4F46E5),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
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

IconData _socialIcon(String keyword) {
  final text = keyword.toLowerCase();
  if (text.contains('flood') || text.contains('rain')) {
    return Icons.flood_rounded;
  }
  if (text.contains('accident') ||
      text.contains('traffic') ||
      text.contains('blocked')) {
    return Icons.traffic_rounded;
  }
  if (text.contains('heat')) return Icons.thermostat_rounded;
  if (text.contains('outage') || text.contains('blackout')) {
    return Icons.power_off_rounded;
  }
  if (text.contains('fire')) return Icons.local_fire_department_rounded;
  return Icons.campaign_rounded;
}

Color _socialColor(String keyword) {
  final text = keyword.toLowerCase();
  if (text.contains('flood') || text.contains('rain')) {
    return const Color(0xFF2563EB);
  }
  if (text.contains('accident') ||
      text.contains('traffic') ||
      text.contains('blocked')) {
    return const Color(0xFFF97316);
  }
  if (text.contains('heat')) return const Color(0xFF14B8A6);
  if (text.contains('outage') || text.contains('blackout')) {
    return const Color(0xFFF59E0B);
  }
  if (text.contains('fire')) return const Color(0xFFEF4444);
  return const Color(0xFF4F46E5);
}

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
    if (cleaned.contains('Delay:') || cleaned.contains('delay')) return cleaned;
    // Extract congestion label from live data
    if (cleaned.toLowerCase().contains('congestion')) return cleaned;
  }
  return cleaned;
}

String _distanceText(Crisis crisis) {
  return 'Nearby';
}

List<_HomeReport> _homeReports(Crisis crisis, DemoScenario scenario) {
  final location = crisis.location;
  final isDemo = AppModeService.instance.isDemoMode;

  // Demo mode only: show hardcoded G-10 flood scenario reports
  if (isDemo && crisis.type == CrisisType.urbanFlooding) {
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
        likes: 42,
        views: 1800,
        isOfficial: false,
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
        likes: 31,
        views: 1420,
        isOfficial: true,
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
        likes: 28,
        views: 980,
        isOfficial: true,
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
        likes: 24,
        views: 860,
        isOfficial: true,
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
        likes: 19,
        views: 730,
        isOfficial: true,
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
        likes: 15,
        views: 520,
        isOfficial: true,
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
      likes: 75,
      views: 3100,
      isOfficial: true,
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
      likes: 12,
      views: 450,
      isOfficial: false,
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
      likes: 22,
      views: 810,
      isOfficial: true,
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

// ==========================================
// GOOGLE WEATHER CARD SYSTEM (CIRO PREMIUM)
// ==========================================

class ParsedWeather {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final String condition;
  final String description;
  final double windSpeed;
  final double rainfallLastHour;
  final String alertLevel;

  ParsedWeather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.condition,
    required this.description,
    required this.windSpeed,
    required this.rainfallLastHour,
    required this.alertLevel,
  });

  factory ParsedWeather.parse(String text) {
    double temp = 24.0;
    double feels = 25.0;
    int humid = 65;
    String cond = 'Clear';
    String desc = 'clear sky';
    double wind = 3.2;
    double rainVal = 0.0;
    String alert = 'No Alert';

    try {
      if (text.contains('Live OpenWeather:')) {
        final condReg = RegExp(
          r'Live OpenWeather:\s*([A-Za-z]+)\s*\(([^)]+)\)',
        );
        final condMatch = condReg.firstMatch(text);
        if (condMatch != null) {
          cond = condMatch.group(1) ?? 'Clear';
          desc = condMatch.group(2) ?? 'clear sky';
        }

        final tempReg = RegExp(r'temp\s*([0-9.-]+)');
        final tempMatch = tempReg.firstMatch(text);
        if (tempMatch != null) {
          temp = double.tryParse(tempMatch.group(1) ?? '') ?? 24.0;
        }

        final feelsReg = RegExp(r'feels\s*([0-9.-]+)');
        final feelsMatch = feelsReg.firstMatch(text);
        if (feelsMatch != null) {
          feels = double.tryParse(feelsMatch.group(1) ?? '') ?? 25.0;
        }

        final rainReg = RegExp(r'rain\s*([0-9.]+)?');
        final rainMatch = rainReg.firstMatch(text);
        if (rainMatch != null && rainMatch.group(1) != null) {
          rainVal = double.tryParse(rainMatch.group(1) ?? '') ?? 0.0;
        }

        final alertReg = RegExp(r'alert\s*([^.]+)');
        final alertMatch = alertReg.firstMatch(text);
        if (alertMatch != null) {
          alert = alertMatch.group(1)?.trim() ?? 'No Alert';
        }
      } else if (text.contains('Weather:')) {
        final condReg = RegExp(r'Weather:\s*([A-Za-z]+)\s*\(([^)]+)\)');
        final condMatch = condReg.firstMatch(text);
        if (condMatch != null) {
          cond = condMatch.group(1) ?? 'Clear';
          desc = condMatch.group(2) ?? 'clear sky';
        }

        final tempReg = RegExp(r',\s*([0-9.-]+)\s*°C');
        final tempMatch = tempReg.firstMatch(text);
        if (tempMatch != null) {
          temp = double.tryParse(tempMatch.group(1) ?? '') ?? 24.0;
          feels = temp + 1.2;
        }

        final rainReg = RegExp(r'rain:\s*([0-9.]+)\s*mm/h');
        final rainMatch = rainReg.firstMatch(text);
        if (rainMatch != null) {
          rainVal = double.tryParse(rainMatch.group(1) ?? '') ?? 0.0;
        }
      }
    } catch (_) {}

    final lowerCond = cond.toLowerCase();
    if (lowerCond.contains('rain') || lowerCond.contains('drizzle')) {
      humid = 88;
      wind = 5.4;
    } else if (lowerCond.contains('thunderstorm') ||
        lowerCond.contains('storm')) {
      humid = 92;
      wind = 8.6;
    } else if (lowerCond.contains('cloud') || lowerCond.contains('overcast')) {
      humid = 75;
      wind = 4.1;
    } else if (temp >= 38.0) {
      humid = 22;
      wind = 6.2;
    }

    return ParsedWeather(
      temperature: temp,
      feelsLike: feels,
      humidity: humid,
      condition: cond,
      description: desc,
      windSpeed: wind,
      rainfallLastHour: rainVal,
      alertLevel: alert,
    );
  }

  List<HourlyForecast> getHourlyForecast() {
    final List<HourlyForecast> list = [];
    final now = DateTime.now();
    final lowerCond = condition.toLowerCase();

    for (int i = 0; i < 6; i++) {
      final hourTime = now.add(Duration(hours: i));
      final hourLabel = i == 0
          ? 'Now'
          : '${hourTime.hour > 12 ? hourTime.hour - 12 : (hourTime.hour == 0 ? 12 : hourTime.hour)} ${hourTime.hour >= 12 ? 'PM' : 'AM'}';

      double tempOffset = -i * 0.8;
      double rainProb = 0.0;
      double windSpeedVal = windSpeed + (i * 0.2);

      if (lowerCond.contains('rain') ||
          lowerCond.contains('drizzle') ||
          rainfallLastHour > 0) {
        rainProb = 70.0 + (i * 5.0).clamp(0.0, 25.0);
        tempOffset = -i * 0.4;
      } else if (lowerCond.contains('thunderstorm') ||
          lowerCond.contains('storm')) {
        rainProb = 85.0 + (i * 2.0).clamp(0.0, 10.0);
        tempOffset = -i * 0.6;
        windSpeedVal += (i * 0.5);
      } else if (lowerCond.contains('cloud') ||
          lowerCond.contains('overcast')) {
        rainProb = 20.0 + (i * 8.0);
      } else {
        rainProb = (i * 2.0);
      }

      list.add(
        HourlyForecast(
          time: hourLabel,
          temp: temperature + tempOffset,
          precipitationChance: rainProb.clamp(0.0, 100.0),
          windSpeed: windSpeedVal,
          condition: condition,
        ),
      );
    }
    return list;
  }

  List<WeeklyForecast> getWeeklyForecast() {
    final List<WeeklyForecast> list = [];
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 1; i <= 5; i++) {
      final day = now.add(Duration(days: i));
      final dayLabel = weekdays[day.weekday - 1];

      double highTemp = temperature + 2.0 - (i * 0.3);
      double lowTemp = temperature - 6.0 - (i * 0.5);
      double rainProb = 10.0;
      String dayCond = 'Clear';

      final lowerCond = condition.toLowerCase();
      if (lowerCond.contains('rain') ||
          lowerCond.contains('drizzle') ||
          rainfallLastHour > 0) {
        rainProb = 60.0 - (i * 5.0);
        dayCond = rainProb > 40 ? 'Rain' : 'Cloudy';
      } else if (lowerCond.contains('thunderstorm') ||
          lowerCond.contains('storm')) {
        rainProb = 80.0 - (i * 10.0);
        dayCond = rainProb > 30 ? 'Storm' : 'Rain';
      } else if (lowerCond.contains('cloud') ||
          lowerCond.contains('overcast')) {
        rainProb = 30.0;
        dayCond = 'Cloudy';
      } else {
        if (i % 2 == 0) {
          dayCond = 'Cloudy';
          rainProb = 15.0;
        } else {
          dayCond = 'Clear';
          rainProb = 5.0;
        }
      }

      list.add(
        WeeklyForecast(
          day: dayLabel,
          highTemp: highTemp,
          lowTemp: lowTemp,
          precipitationChance: rainProb.clamp(0.0, 100.0),
          condition: dayCond,
        ),
      );
    }
    return list;
  }
}

class HourlyForecast {
  final String time;
  final double temp;
  final double precipitationChance;
  final double windSpeed;
  final String condition;

  HourlyForecast({
    required this.time,
    required this.temp,
    required this.precipitationChance,
    required this.windSpeed,
    required this.condition,
  });
}

class WeeklyForecast {
  final String day;
  final double highTemp;
  final double lowTemp;
  final double precipitationChance;
  final String condition;

  WeeklyForecast({
    required this.day,
    required this.highTemp,
    required this.lowTemp,
    required this.precipitationChance,
    required this.condition,
  });
}

class _GoogleWeatherCard extends StatefulWidget {
  final SignalInput weatherSignal;
  final String locationLabel;

  const _GoogleWeatherCard({
    required this.weatherSignal,
    required this.locationLabel,
  });

  @override
  State<_GoogleWeatherCard> createState() => _GoogleWeatherCardState();
}

class _GoogleWeatherCardState extends State<_GoogleWeatherCard> {
  int _selectedTab = 0; // 0 = Temperature, 1 = Precipitation, 2 = Wind

  IconData _getWeatherIcon(String cond) {
    final lower = cond.toLowerCase();
    if (lower.contains('rain') || lower.contains('drizzle')) {
      return Icons.grain_rounded;
    } else if (lower.contains('storm') || lower.contains('thunderstorm')) {
      return Icons.thunderstorm_rounded;
    } else if (lower.contains('cloud') || lower.contains('overcast')) {
      return Icons.cloud_rounded;
    } else {
      return Icons.wb_sunny_rounded;
    }
  }

  Color _getWeatherIconColor(String cond) {
    final lower = cond.toLowerCase();
    if (lower.contains('rain') || lower.contains('drizzle')) {
      return const Color(0xFF3B82F6); // Blue
    } else if (lower.contains('storm') || lower.contains('thunderstorm')) {
      return const Color(0xFF4F46E5); // Indigo
    } else if (lower.contains('cloud') || lower.contains('overcast')) {
      return const Color(0xFF64748B); // Slate
    } else {
      return const Color(0xFFF59E0B); // Amber
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsed = ParsedWeather.parse(widget.weatherSignal.content);
    final hourly = parsed.getHourlyForecast();
    final weekly = parsed.getWeeklyForecast();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Google ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Weather',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF2563EB),
                          shadows: [
                            Shadow(
                              color: const Color(
                                0xFF2563EB,
                              ).withValues(alpha: 0.15),
                              offset: const Offset(0, 1.5),
                              blurRadius: 2.0,
                            ),
                          ],
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 13,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.locationLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Live Fused Signal',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Main Forecast Details Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Large Temperature and Condition
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _getWeatherIcon(parsed.condition),
                    size: 54,
                    color: _getWeatherIconColor(parsed.condition),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            parsed.temperature.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              height: 0.9,
                              letterSpacing: -2,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '°C',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        parsed.description.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'H: ${(parsed.temperature + 2).toStringAsFixed(0)}°  L: ${(parsed.temperature - 5).toStringAsFixed(0)}°',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Details Grid (2x2)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF1F5F9),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WeatherGridItem(
                      icon: Icons.thermostat_rounded,
                      label: 'Feels like',
                      value: '${parsed.feelsLike.toStringAsFixed(1)}°C',
                    ),
                    const SizedBox(height: 8),
                    _WeatherGridItem(
                      icon: Icons.water_drop_rounded,
                      label: 'Humidity',
                      value: '${parsed.humidity}%',
                    ),
                    const SizedBox(height: 8),
                    _WeatherGridItem(
                      icon: Icons.air_rounded,
                      label: 'Wind Speed',
                      value: '${parsed.windSpeed.toStringAsFixed(1)} m/s',
                    ),
                    const SizedBox(height: 8),
                    _WeatherGridItem(
                      icon: Icons.umbrella_rounded,
                      label: 'Rainfall',
                      value: parsed.rainfallLastHour > 0
                          ? '${parsed.rainfallLastHour.toStringAsFixed(1)} mm/h'
                          : 'None',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Interactive Tab Controls
          Row(
            children: [
              _buildTabButton(0, 'Temperature', Icons.thermostat_rounded),
              const SizedBox(width: 8),
              _buildTabButton(1, 'Precipitation', Icons.water_drop_rounded),
              const SizedBox(width: 8),
              _buildTabButton(2, 'Wind', Icons.air_rounded),
            ],
          ),
          const SizedBox(height: 16),

          // Scrollable Hourly Forecast Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: hourly.map((item) {
                String labelVal = '';
                if (_selectedTab == 0) {
                  labelVal = '${item.temp.toStringAsFixed(0)}°';
                } else if (_selectedTab == 1) {
                  labelVal = '${item.precipitationChance.toStringAsFixed(0)}%';
                } else {
                  labelVal = '${item.windSpeed.toStringAsFixed(1)}m/s';
                }

                return Container(
                  width: 68,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFF1F5F9),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        item.time,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        _getWeatherIcon(
                          _selectedTab == 1 && item.precipitationChance > 30
                              ? 'Rain'
                              : item.condition,
                        ),
                        size: 20,
                        color: _getWeatherIconColor(
                          _selectedTab == 1 && item.precipitationChance > 30
                              ? 'Rain'
                              : item.condition,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        labelVal,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Divider
          Container(height: 1, color: const Color(0xFFE2E8F0)),
          const SizedBox(height: 16),

          // 5-Day Weekly Forecast Section
          const Text(
            '5-Day Weekly Outlook',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),

          Column(
            children: weekly.map((dayItem) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    // Day label
                    SizedBox(
                      width: 45,
                      child: Text(
                        dayItem.day,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    // Icon
                    Icon(
                      _getWeatherIcon(dayItem.condition),
                      size: 20,
                      color: _getWeatherIconColor(dayItem.condition),
                    ),
                    const SizedBox(width: 14),
                    // Precipitation indicator bar
                    Expanded(
                      child: Row(
                        children: [
                          if (dayItem.precipitationChance > 20) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.water_drop_rounded,
                                    size: 9,
                                    color: Color(0xFF2563EB),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${dayItem.precipitationChance.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            const SizedBox(width: 32),
                          ],
                          const SizedBox(width: 8),
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: ((dayItem.highTemp - 10) / 40)
                                      .clamp(0.1, 1.0),
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF3B82F6),
                                          Color(0xFFF59E0B),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Temperatures
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${dayItem.highTemp.toStringAsFixed(0)}°',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${dayItem.lowTemp.toStringAsFixed(0)}°',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String text, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherGridItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherGridItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Color(0xFF94A3B8),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
