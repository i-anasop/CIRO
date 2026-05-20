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
  int _zoom = 15;
  bool _showRisk = false;
  bool _showRoute = false;
  int _recenterSignal = 0;

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
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: _glassDecoration(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isDemo
                                        ? 'Google Map - G-10, Islamabad'
                                        : 'Google Live Situation Map',
                                    style: CiroTypography.labelLarge,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    crisis.location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: CiroTypography.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _RoundButton(
                            icon: Icons.tune_rounded,
                            onTap: _showLayerSheet,
                            tooltip: 'Map controls',
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
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _TogglePill(
                              label: 'Boundary',
                              icon: Icons.crop_free_rounded,
                              active: true,
                              activeColor: CiroColors.brand,
                              onTap: () {},
                            ),
                            const SizedBox(width: 8),
                            _TogglePill(
                              label: 'Risk Zone',
                              icon: Icons.radar_rounded,
                              active: _showRisk,
                              activeColor: CiroColors.critical,
                              onTap: () =>
                                  setState(() => _showRisk = !_showRisk),
                            ),
                            const SizedBox(width: 8),
                            _TogglePill(
                              label: 'Route',
                              icon: Icons.alt_route_rounded,
                              active: _showRoute,
                              activeColor: CiroColors.success,
                              onTap: () =>
                                  setState(() => _showRoute = !_showRoute),
                            ),
                            const SizedBox(width: 12),
                            _MiniMapButton(
                              icon: Icons.remove_rounded,
                              onTap: () => setState(
                                () => _zoom = (_zoom - 1).clamp(10, 20),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                              ),
                              child: Text(
                                'z$_zoom',
                                style: CiroTypography.labelSmall,
                              ),
                            ),
                            _MiniMapButton(
                              icon: Icons.add_rounded,
                              onTap: () => setState(
                                () => _zoom = (_zoom + 1).clamp(10, 20),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _MiniMapButton(
                              icon: Icons.my_location_rounded,
                              color: CiroColors.brand,
                              onTap: () => setState(() {
                                _zoom = 15;
                                _layer = 'All Layers';
                                _recenterSignal++;
                              }),
                            ),
                          ],
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

  void _showLayerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: CiroColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Map Controls', style: CiroTypography.headingSmall),
                const SizedBox(height: 4),
                Text(
                  AppModeService.instance.isDemoMode
                      ? 'Google Maps shows the searched G-10 boundary. Filters change the map search context.'
                      : 'Live situation map with real-time overlays. Filters change the map search context.',
                  style: CiroTypography.bodySmall,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(
                    Icons.radar_rounded,
                    color: CiroColors.critical,
                  ),
                  title: const Text('Risk Perimeter'),
                  subtitle: const Text(
                    'Show CIRO flood risk overlay on supported map views.',
                  ),
                  value: _showRisk,
                  activeThumbColor: CiroColors.critical,
                  onChanged: (v) {
                    setState(() => _showRisk = v);
                    setSheet(() {});
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(
                    Icons.alt_route_rounded,
                    color: CiroColors.success,
                  ),
                  title: const Text('Alternate Route'),
                  subtitle: const Text(
                    'Show CIRO recommended response route on supported map views.',
                  ),
                  value: _showRoute,
                  activeThumbColor: CiroColors.success,
                  onChanged: (v) {
                    setState(() => _showRoute = v);
                    setSheet(() {});
                  },
                ),
                const SizedBox(height: 10),
                Text('Active Layer', style: CiroTypography.labelLarge),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _layers.map((l) {
                    final selected = _layer == l;
                    return ChoiceChip(
                      avatar: Icon(
                        _layerIcons[l],
                        size: 16,
                        color: selected
                            ? Colors.white
                            : CiroColors.textSecondary,
                      ),
                      label: Text(l),
                      selected: selected,
                      selectedColor: CiroColors.brand,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : CiroColors.textPrimary,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      onSelected: (_) {
                        setState(() => _layer = l);
                        setSheet(() {});
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MapSummaryPanel extends StatelessWidget {
  final Crisis crisis;
  const _MapSummaryPanel({required this.crisis});

  @override
  Widget build(BuildContext context) {
    final actions = ScenarioEngine.instance.responsePlan.take(2).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: CiroColors.bySeverityBg(crisis.severityLabel),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _crisisIcon(crisis.type),
                  color: CiroColors.bySeverity(crisis.severityLabel),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crisis.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CiroTypography.labelLarge,
                    ),
                    Text(
                      '${crisis.typeLabel} - ${crisis.confidence}% confidence',
                      style: CiroTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: CiroColors.bySeverityBg(crisis.severityLabel),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  crisis.severityLabel.toUpperCase(),
                  style: CiroTypography.labelSmall.copyWith(
                    color: CiroColors.bySeverity(crisis.severityLabel),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            ...actions.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: CiroColors.brandGlow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${a.step}',
                        style: CiroTypography.labelSmall.copyWith(
                          color: CiroColors.brandAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        a.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CiroTypography.bodySmall,
                      ),
                    ),
                    Text(
                      a.eta,
                      style: CiroTypography.labelSmall.copyWith(
                        color: CiroColors.textMuted,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? CiroColors.brand : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? CiroColors.brand : CiroColors.border,
            ),
            boxShadow: CiroColors.cardShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? Colors.white : CiroColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: CiroTypography.labelSmall.copyWith(
                  color: selected ? Colors.white : CiroColors.textPrimary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
    final child = Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon),
        color: CiroColors.textPrimary,
        iconSize: 22,
      ),
    );
    if (tooltip != null) return Tooltip(message: tooltip!, child: child);
    return child;
  }
}

class _MiniMapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _MiniMapButton({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 18, color: color ?? CiroColors.textPrimary),
        ),
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _TogglePill({
    required this.label,
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: active ? activeColor.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? activeColor : CiroColors.border),
          boxShadow: CiroColors.cardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? activeColor : CiroColors.textMuted,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: CiroTypography.labelSmall.copyWith(
                color: active ? activeColor : CiroColors.textSecondary,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _glassDecoration() => BoxDecoration(
  color: Colors.white.withValues(alpha: 0.94),
  borderRadius: BorderRadius.circular(18),
  border: Border.all(color: CiroColors.border),
  boxShadow: CiroColors.cardShadow,
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
