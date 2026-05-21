import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
  return _CiroFlutterMap(
    latitude: latitude,
    longitude: longitude,
    zoom: zoom,
    selectedLayer: selectedLayer,
    showRiskZone: showRiskZone,
    showAltRoute: showAltRoute,
    recenterSignal: recenterSignal,
    mapCenterLatitude: mapCenterLatitude,
    mapCenterLongitude: mapCenterLongitude,
  );
}

class _CiroFlutterMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final int zoom;
  final String selectedLayer;
  final bool showRiskZone;
  final bool showAltRoute;
  final int recenterSignal;
  final double? mapCenterLatitude;
  final double? mapCenterLongitude;

  const _CiroFlutterMap({
    required this.latitude,
    required this.longitude,
    required this.zoom,
    required this.selectedLayer,
    required this.showRiskZone,
    required this.showAltRoute,
    required this.recenterSignal,
    this.mapCenterLatitude,
    this.mapCenterLongitude,
  });

  @override
  State<_CiroFlutterMap> createState() => _CiroFlutterMapState();
}

class _CiroFlutterMapState extends State<_CiroFlutterMap> {
  final MapController _controller = MapController();

  LatLng get _center => LatLng(
    widget.mapCenterLatitude ?? widget.latitude,
    widget.mapCenterLongitude ?? widget.longitude,
  );
  LatLng get _markerPoint => LatLng(widget.latitude, widget.longitude);

  @override
  void didUpdateWidget(covariant _CiroFlutterMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final locationChanged =
        oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude ||
        oldWidget.mapCenterLatitude != widget.mapCenterLatitude ||
        oldWidget.mapCenterLongitude != widget.mapCenterLongitude;
    final recenterRequested = oldWidget.recenterSignal != widget.recenterSignal;
    if (locationChanged || oldWidget.zoom != widget.zoom || recenterRequested) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.move(_center, widget.zoom.toDouble());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final markerPoint = _markerPoint;
    final route = _routePoints(markerPoint);
    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: _center,
        initialZoom: widget.zoom.toDouble(),
        minZoom: 10,
        maxZoom: 19,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: _tileUrl(widget.selectedLayer),
          userAgentPackageName: 'com.ciro.ciro',
          maxZoom: widget.selectedLayer == 'Flood Risk' ? 18 : 19,
        ),
        if (_isG10(_center))
          PolygonLayer(
            polygons: [
              Polygon(
                points: _g10Boundary,
                color: const Color(0xFF5A5CE5).withValues(alpha: 0.07),
                borderColor: const Color(0xFF5A5CE5),
                borderStrokeWidth: 2,
              ),
            ],
          ),
        if (widget.selectedLayer == 'Traffic')
          PolylineLayer(
            polylines: [
              Polyline(
                points: _trafficCorridors(_center),
                color: const Color(0xFFF97316),
                strokeWidth: 6,
              ),
              Polyline(
                points: _trafficCorridors(_center, offset: 0.006),
                color: const Color(0xFFEF4444),
                strokeWidth: 5,
              ),
            ],
          ),
        if (widget.showRiskZone || widget.selectedLayer == 'Flood Risk')
          CircleLayer(
            circles: [
              CircleMarker(
                point: markerPoint,
                radius: 800,
                useRadiusInMeter: true,
                color: const Color(0xFFEF4444).withValues(alpha: 0.14),
                borderColor: const Color(0xFFEF4444),
                borderStrokeWidth: 2,
              ),
              CircleMarker(
                point: markerPoint,
                radius: 380,
                useRadiusInMeter: true,
                color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                borderColor: const Color(0xFF3B82F6).withValues(alpha: 0.75),
                borderStrokeWidth: 1.5,
              ),
            ],
          ),
        if (widget.showAltRoute)
          PolylineLayer(
            polylines: [
              Polyline(
                points: route,
                color: const Color(0xFF22C55E),
                strokeWidth: 5,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: markerPoint,
              width: 54,
              height: 54,
              child: _MapPin(
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFF5A5CE5),
                size: 42,
              ),
            ),
            if (widget.selectedLayer == 'Shelters' ||
                widget.selectedLayer == 'All Layers')
              ..._shelterMarkers(_center),
            if (widget.selectedLayer == 'Units' ||
                widget.selectedLayer == 'All Layers')
              ..._unitMarkers(_center),
            if (widget.showAltRoute)
              Marker(
                point: route[1],
                width: 34,
                height: 34,
                child: const _MapPin(
                  icon: Icons.alt_route_rounded,
                  color: Color(0xFF22C55E),
                  size: 30,
                ),
              ),
          ],
        ),
        Positioned(
          left: 12,
          top: 12,
          child: _MapLegend(
            layer: _isG10(_center)
                ? _legendText(widget.selectedLayer)
                : widget.selectedLayer,
          ),
        ),
      ],
    );
  }
}

class _MapPin extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _MapPin({required this.icon, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.52),
    );
  }
}

class _MapLegend extends StatelessWidget {
  final String layer;
  const _MapLegend({required this.layer});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.layers_rounded,
              size: 14,
              color: Color(0xFF5A5CE5),
            ),
            const SizedBox(width: 5),
            Text(
              layer,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _tileUrl(String selectedLayer) {
  return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
}

bool _isG10(LatLng center) =>
    (center.latitude - 33.6946).abs() < 0.03 &&
    (center.longitude - 73.0179).abs() < 0.03;

String _legendText(String selectedLayer) => switch (selectedLayer) {
  'Flood Risk' => 'G-10 boundary + flood risk',
  'Traffic' => 'G-10 traffic pressure',
  'Shelters' => 'Shelters near G-10',
  'Units' => 'Response units near G-10',
  _ => 'G-10, Islamabad',
};

final List<LatLng> _g10Boundary = [
  const LatLng(33.7047, 73.0108),
  const LatLng(33.7027, 73.0250),
  const LatLng(33.6886, 73.0267),
  const LatLng(33.6862, 73.0127),
  const LatLng(33.6945, 73.0068),
];

List<LatLng> _routePoints(LatLng center) => [
  LatLng(center.latitude - 0.013, center.longitude - 0.014),
  LatLng(center.latitude - 0.006, center.longitude - 0.006),
  LatLng(center.latitude - 0.001, center.longitude + 0.002),
  center,
];

List<LatLng> _trafficCorridors(LatLng center, {double offset = 0}) => [
  LatLng(center.latitude - 0.016 + offset, center.longitude - 0.018),
  LatLng(center.latitude - 0.008 + offset, center.longitude - 0.006),
  LatLng(center.latitude + 0.004 + offset, center.longitude + 0.010),
];

List<Marker> _shelterMarkers(LatLng center) {
  final points = [
    LatLng(center.latitude + 0.006, center.longitude + 0.008),
    LatLng(center.latitude - 0.007, center.longitude + 0.004),
    LatLng(center.latitude + 0.003, center.longitude - 0.010),
  ];
  return points
      .map(
        (point) => Marker(
          point: point,
          width: 34,
          height: 34,
          child: const _MapPin(
            icon: Icons.local_hospital_rounded,
            color: Color(0xFF3B82F6),
            size: 30,
          ),
        ),
      )
      .toList();
}

List<Marker> _unitMarkers(LatLng center) {
  final points = [
    LatLng(center.latitude + 0.010, center.longitude - 0.008),
    LatLng(center.latitude - 0.011, center.longitude + 0.003),
    LatLng(center.latitude + 0.005, center.longitude + 0.014),
  ];
  return points
      .map(
        (point) => Marker(
          point: point,
          width: 34,
          height: 34,
          child: const _MapPin(
            icon: Icons.local_fire_department_rounded,
            color: Color(0xFFEF4444),
            size: 30,
          ),
        ),
      )
      .toList();
}
