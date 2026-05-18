// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

// Track registered view factories to avoid duplicate registration errors
final Set<String> _registeredViewIds = {};

Widget createInteractiveMap({
  required double latitude,
  required double longitude,
  required int zoom,
  required String selectedLayer,
  bool showRiskZone = false,
  bool showAltRoute = false,
}) {
  // Build dynamic Google Maps Embed URL based on category selection
  String url;

  if (selectedLayer == 'Flood Risk') {
    // Satellite View for flood risk assessment
    url = 'https://maps.google.com/maps?q=$latitude,$longitude&z=$zoom&t=k&output=embed';
  } else if (selectedLayer == 'Traffic') {
    // Traffic layer view
    url = 'https://maps.google.com/maps?q=$latitude,$longitude&z=$zoom&layer=traffic&output=embed';
  } else if (selectedLayer == 'Shelters') {
    // Search for nearest shelters / medical centers
    url = 'https://maps.google.com/maps?q=hospital+shelter+near+$latitude,$longitude&z=$zoom&output=embed';
  } else if (selectedLayer == 'Units') {
    // Search for emergency response stations
    url = 'https://maps.google.com/maps?q=fire+station+police+near+$latitude,$longitude&z=$zoom&output=embed';
  } else {
    // Default standard roadmap view
    url = 'https://maps.google.com/maps?q=$latitude,$longitude&z=$zoom&output=embed';
  }

  // Build a unique ID from current parameters to allow dynamic updates
  final layerId = selectedLayer.replaceAll(' ', '_');
  final riskStr = showRiskZone ? 'r' : '';
  final routeStr = showAltRoute ? 'a' : '';
  final viewId = 'gmap-${latitude.toStringAsFixed(3)}-${longitude.toStringAsFixed(3)}-$zoom-$layerId$riskStr$routeStr';

  // Only register if not already registered (avoid duplicate factory error)
  if (!_registeredViewIds.contains(viewId)) {
    _registeredViewIds.add(viewId);
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
      return html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.pointerEvents = 'auto'
        ..allowFullscreen = true;
    });
  }

  return HtmlElementView(
    key: ValueKey(viewId),
    viewType: viewId,
  );
}
