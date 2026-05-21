// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../services/scenario_engine.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

final Set<String> _registeredViews = {};
final Map<String, ValueNotifier<bool>> _mapLoadingStates = {};

Widget createInteractiveMap({
  required double latitude,
  required double longitude,
  required int zoom,
  required String selectedLayer,
  bool showRiskZone = false,
  bool showAltRoute = false,
  int recenterSignal = 0,
  double? mapCenterLatitude,
  double? mapCenterLongitude,
}) {
  final url = _embedUrl(
    latitude: latitude,
    longitude: longitude,
    mapCenterLatitude: mapCenterLatitude,
    mapCenterLongitude: mapCenterLongitude,
    zoom: zoom,
    selectedLayer: selectedLayer,
  );
  final viewId = 'ciro-google-embed-${url.hashCode}';

  final notifier = _mapLoadingStates.putIfAbsent(viewId, () => ValueNotifier<bool>(true));

  if (!_registeredViews.contains(viewId)) {
    _registeredViews.add(viewId);
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
      notifier.value = true;
      final iframe = html.IFrameElement()
        ..src = url
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = false
        ..referrerPolicy = 'no-referrer-when-downgrade';

      iframe.onLoad.listen((_) {
        notifier.value = false;
      });

      // Safety timeout: if onLoad doesn't fire within 5 seconds, clear the loader
      Future.delayed(const Duration(seconds: 5), () {
        if (notifier.value) {
          notifier.value = false;
        }
      });

      return iframe;
    });
  }

  return Stack(
    children: [
      HtmlElementView(key: ValueKey(viewId), viewType: viewId),
      ValueListenableBuilder<bool>(
        valueListenable: notifier,
        builder: (context, isLoading, child) {
          if (!isLoading) return const SizedBox.shrink();
          return const _MapLoadingPlaceholder();
        },
      ),
      Positioned(
        top: 12,
        left: 12,
        child: _MapBadge(
          label: '${_label(latitude, longitude)} • $selectedLayer',
        ),
      ),
    ],
  );
}

String _embedUrl({
  required double latitude,
  required double longitude,
  double? mapCenterLatitude,
  double? mapCenterLongitude,
  required int zoom,
  required String selectedLayer,
}) {
  final query = Uri.encodeComponent(
    _query(
      latitude,
      longitude,
      selectedLayer,
      mapCenterLatitude: mapCenterLatitude,
      mapCenterLongitude: mapCenterLongitude,
    ),
  );
  return 'https://www.google.com/maps?q=$query&z=$zoom&output=embed';
}

String _query(
  double latitude,
  double longitude,
  String selectedLayer, {
  double? mapCenterLatitude,
  double? mapCenterLongitude,
}) {
  final isG10 =
      (latitude - 33.6946).abs() < 0.03 && (longitude - 73.0179).abs() < 0.03;
  if (isG10) {
    return switch (selectedLayer) {
      'Traffic' => 'traffic near G-10 Markaz Islamabad',
      'Flood Risk' => 'drainage nullah streams canals near G-10 Islamabad',
      'Shelters' => 'hospitals medical shelters near G-10 Islamabad',
      'Units' => 'rescue services fire police near G-10 Islamabad',
      _ => 'G-10 Islamabad Pakistan',
    };
  }
  final crisis = ScenarioEngine.instance.activeCrisis;
  final loc = crisis.location.isNotEmpty
      ? crisis.location
      : '$latitude,$longitude';
  if (mapCenterLatitude != null && mapCenterLongitude != null) {
    final inIslamabad =
        (mapCenterLatitude - 33.6844).abs() < 0.05 &&
        (mapCenterLongitude - 73.0479).abs() < 0.05;
    if (inIslamabad) {
      return switch (selectedLayer) {
        'Traffic' => 'traffic in Islamabad Pakistan near $loc',
        'Flood Risk' =>
          'drainage nullah streams canals Islamabad Pakistan near $loc',
        'Shelters' =>
          'hospitals shelters rescue centers Islamabad Pakistan near $loc',
        'Units' => 'rescue fire police stations Islamabad Pakistan near $loc',
        _ => 'Islamabad Pakistan near $latitude,$longitude',
      };
    }
  }
  return switch (selectedLayer) {
    'Traffic' => 'traffic near $loc',
    'Flood Risk' => 'drainage nullah streams canals near $loc',
    'Shelters' => 'hospitals medical shelters near $loc',
    'Units' => 'rescue services fire police near $loc',
    _ => loc,
  };
}

String _label(double latitude, double longitude) {
  final isG10 =
      (latitude - 33.6946).abs() < 0.03 && (longitude - 73.0179).abs() < 0.03;
  return isG10 ? 'G-10' : 'Live Sector';
}

class _MapBadge extends StatelessWidget {
  final String label;
  const _MapBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: CiroColors.cardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.layers_rounded, size: 14, color: CiroColors.brand),
            const SizedBox(width: 6),
            Text(
              label,
              style: CiroTypography.labelSmall.copyWith(
                color: CiroColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapLoadingPlaceholder extends StatelessWidget {
  const _MapLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9), // slate-100 fallback
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(CiroColors.brand),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Loading interactive map...',
              style: CiroTypography.caption.copyWith(
                color: CiroColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
