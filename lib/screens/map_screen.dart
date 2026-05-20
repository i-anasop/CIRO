// CIRO - Situation Map Screen
// Google-style map view with controls outside the embedded map so every button remains clickable.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/interactive_map_helper.dart';
import '../models/crisis.dart';
import '../services/app_mode_service.dart';
import '../services/scenario_engine.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _layer = 'All Layers';
  final int _zoom = 15;
  final bool _showRisk = false;
  final bool _showRoute = false;
  final int _recenterSignal = 0;

  static const _layers = [
    'All Layers',
    'Flood Risk',
    'Traffic',
    'Shelters',
    'Units',
  ];

  static const _layerIcons = {
    'All Layers': Icons.layers_rounded,
    'Flood Risk': Icons.water_drop_rounded,
    'Traffic': Icons.traffic_rounded,
    'Shelters': Icons.local_hospital_rounded,
    'Units': Icons.local_fire_department_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ScenarioEngine.instance,
      builder: (context, _) {
        final engine = ScenarioEngine.instance;
        final crisis = engine.activeCrisis;
        final isDemo = AppModeService.instance.isDemoMode;
        final coords = isDemo ? const (33.6946, 73.0179) : _coords(crisis);

        return Scaffold(
          backgroundColor: CiroColors.bg1,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _RoundButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => context.go('/home'),
                            tooltip: 'Back',
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: _premiumSearchBarDecoration(),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isDemo
                                              ? 'Google Map - G-10, Islamabad'
                                              : 'Google Live Situation Map',
                                          style: CiroTypography.labelLarge.copyWith(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          crisis.location,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: CiroTypography.bodySmall.copyWith(
                                            fontSize: 11,
                                            color: const Color(0xFF94A3B8),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _layers
                              .map(
                                (l) => _LayerChip(
                                  label: l,
                                  icon: _layerIcons[l]!,
                                  selected: _layer == l,
                                  onTap: () => setState(() => _layer = l),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: createInteractiveMap(
                        latitude: coords.$1,
                        longitude: coords.$2,
                        zoom: _zoom,
                        selectedLayer: _layer,
                        showRiskZone: _showRisk,
                        showAltRoute: _showRoute,
                        recenterSignal: _recenterSignal,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                  child: _MapSummaryPanel(crisis: crisis),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}

class _MapSummaryPanel extends StatelessWidget {
  final Crisis crisis;
  const _MapSummaryPanel({required this.crisis});

  @override
  Widget build(BuildContext context) {
    final actions = ScenarioEngine.instance.responsePlan.take(2).toList();
    final isDemo = AppModeService.instance.isDemoMode;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2), // Soft pink/red
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isDemo ? Icons.water_drop_outlined : _crisisIcon(crisis.type),
                  color: const Color(0xFFEF4444),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDemo ? 'Urban Flooding — G-10, Islamabad' : crisis.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CiroTypography.labelLarge.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isDemo
                          ? 'Urban Flooding - 91% confidence'
                          : '${crisis.typeLabel} - ${crisis.confidence}% confidence',
                      style: CiroTypography.bodySmall.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2), // very soft pink
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'CRITICAL',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          if (actions.isNotEmpty) ...[
            const Divider(
              color: Color(0xFFF1F5F9),
              thickness: 1.0,
              height: 28,
            ),
            ...actions.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF), // Very soft lavender/blue
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${a.step}',
                        style: const TextStyle(
                          color: Color(0xFF6366F1), // Darker lavender/blue
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        a.title,
                        style: const TextStyle(
                          color: Color(0xFF64748B), // Muted gray/slate
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      a.eta,
                      style: const TextStyle(
                        color: Color(0xFF64748B), // Muted gray/slate
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LayerChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _LayerChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF4E54E1) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: selected ? Colors.transparent : const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? const Color(0xFF4E54E1).withValues(alpha: 0.25)
                    : const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: CiroTypography.labelSmall.copyWith(
                  color: selected ? Colors.white : const Color(0xFF1E293B),
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const _RoundButton({required this.icon, required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFF1E293B),
          size: 20,
        ),
      ),
    );
    if (tooltip != null) return Tooltip(message: tooltip!, child: child);
    return child;
  }
}

BoxDecoration _premiumSearchBarDecoration() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(32),
  border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
  boxShadow: [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ],
);

(double, double) _coords(Crisis crisis) {
  final matches = RegExp(r'-?\d+\.?\d*')
      .allMatches(crisis.coordinates)
      .map((m) => double.tryParse(m.group(0)!))
      .whereType<double>()
      .toList();
  if (matches.length >= 2) return (matches[0], matches[1]);
  return (33.6946, 73.0179);
}

IconData _crisisIcon(CrisisType type) => switch (type) {
  CrisisType.urbanFlooding => Icons.water_drop_outlined,
  CrisisType.roadBlockage => Icons.traffic_outlined,
  CrisisType.accident => Icons.car_crash_outlined,
  CrisisType.heatwave => Icons.thermostat_outlined,
  CrisisType.powerOutage => Icons.power_off_outlined,
};
