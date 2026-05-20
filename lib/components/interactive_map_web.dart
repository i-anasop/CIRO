// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

final Set<String> _registeredViews = {};

Widget createInteractiveMap({
  required double latitude,
  required double longitude,
  required int zoom,
  required String selectedLayer,
  bool showRiskZone = false,
  bool showAltRoute = false,
  int recenterSignal = 0,
}) {
  final url = _embedUrl(
    latitude: latitude,
    longitude: longitude,
    zoom: zoom,
    selectedLayer: selectedLayer,
  );
  final viewId = 'ciro-google-embed-${url.hashCode}';

  if (!_registeredViews.contains(viewId)) {
    _registeredViews.add(viewId);
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
      return html.IFrameElement()
        ..src = url
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = false
        ..referrerPolicy = 'no-referrer-when-downgrade';
    });
  }

  return Stack(
    children: [
      HtmlElementView(key: ValueKey(viewId), viewType: viewId),
      Positioned(
        top: 12,
        left: 12,
        child: _MapBadge(label: _label(latitude, longitude)),
      ),
    ],
  );
}

String _embedUrl({
  required double latitude,
  required double longitude,
  required int zoom,
  required String selectedLayer,
}) {
  final query = Uri.encodeComponent(_query(latitude, longitude, selectedLayer));
  return 'https://www.google.com/maps?q=$query&z=$zoom&output=embed';
}

String _query(double latitude, double longitude, String selectedLayer) {
  final isG10 =
      (latitude - 33.6946).abs() < 0.03 && (longitude - 73.0179).abs() < 0.03;
  if (isG10) {
    return switch (selectedLayer) {
      'Traffic' => 'traffic near G-10 Markaz Islamabad',
      'Shelters' => 'hospitals and shelters near G-10 Islamabad',
      'Units' => 'fire station police station near G-10 Islamabad',
      _ => 'G-10 Islamabad Pakistan',
    };
  }
  return '$latitude,$longitude';
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
