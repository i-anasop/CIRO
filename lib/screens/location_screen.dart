// CIRO - Location Screen
// Optimized starting screen matching the high-fidelity mockup.
// Simplified, fitted, and structured to fit perfectly on a single screen without scrolling.

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/location_service.dart';
import '../services/geocoding_service.dart';
import '../services/scenario_engine.dart';
import '../services/app_mode_service.dart';
import '../services/notification_service.dart';
import '../models/location_result.dart';

enum SelectionMode { live, demo }

enum LocationState { initial, scanning, success, error }

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with SingleTickerProviderStateMixin {
  SelectionMode _selection = SelectionMode.live;
  LocationState _state = LocationState.initial;
  LocationResult? _detectedLocation;
  SelectionMode? _hoveredMode;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestLocationAccess() async {
    AppModeService.instance.setDemoMode(false);
    ScenarioEngine.instance.setInjectedRealCrisisType(null);
    unawaited(NotificationService.instance.requestPermissions());
    setState(() => _state = LocationState.scanning);

    final locResult = await LocationService.instance.getCurrentLocation();
    if (!locResult.isSuccess) {
      if (mounted) _useDemoLocation();
      return;
    }

    ScenarioEngine.instance.overrideLocation(
      'Live Location',
      lat: locResult.latitude,
      lng: locResult.longitude,
    );

    if (!mounted) return;
    setState(() {
      _detectedLocation = locResult;
      _state = LocationState.success;
    });

    unawaited(_finalizeLiveLocation(locResult));
  }

  Future<void> _finalizeLiveLocation(LocationResult locResult) async {
    final geocoded = await GeocodingService.instance.reverseGeocode(locResult);
    if (!mounted) return;

    ScenarioEngine.instance.overrideLocation(
      geocoded.displayLabel,
      lat: geocoded.latitude,
      lng: geocoded.longitude,
    );

    if (!AppModeService.instance.isDemoMode) {
      unawaited(() async {
        try {
          await ScenarioEngine.instance.runRealSignalAnalysis(
            latitude: geocoded.latitude,
            longitude: geocoded.longitude,
          );
        } catch (e) {
          debugPrint('Failed to run live real signal analysis: $e');
        }
      }());
    }

    if (!mounted) return;
    setState(() {
      _detectedLocation = geocoded;
    });
  }

  void _useDemoLocation() {
    AppModeService.instance.setDemoMode(true);
    ScenarioEngine.instance.reset();
    if (mounted) context.go('/home');
  }

  void _handleContinue() {
    if (_selection == SelectionMode.demo) {
      _useDemoLocation();
    } else {
      if (_state == LocationState.success) {
        context.go('/home');
      } else {
        _requestLocationAccess();
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final isSuccess = _state == LocationState.success;
    final isScanning = _state == LocationState.scanning;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background decorative blobs (matching LoginScreen style)
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4F46E5).withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.04),
              ),
            ),
          ),
          // Scrollable layout builder
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final content = Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Branding & Title Block
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),
                          // Breathing glow outer ring with Location Pin icon
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _pulseCtrl,
                                builder: (context, child) {
                                  final glowScaleVal =
                                      0.88 + (_pulseCtrl.value * 0.22);
                                  return Transform.scale(
                                    scale: glowScaleVal,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            const Color(
                                              0xFF4F46E5,
                                            ).withValues(alpha: 0.20),
                                            const Color(
                                              0xFF4F46E5,
                                            ).withValues(alpha: 0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Container(
                                width: 78,
                                height: 78,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF4F46E5,
                                      ).withValues(alpha: 0.12),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    color: Color(0xFF4F46E5),
                                    size: 34,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // GET STARTED badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: const Color(0xFFE0E7FF),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Color(0xFF4F46E5),
                                  size: 11,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'GET STARTED',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF4F46E5),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Choose Your Location',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF0F172A),
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Use your live GPS location or start with the G-10 Islamabad demo area.',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF475569),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Selection Cards Container
                      Column(
                        children: [
                          // Card 1: My Location
                          _buildOptionCard(
                            mode: SelectionMode.live,
                            title: 'My Current Location (Live)',
                            subtitle: isSuccess
                                ? 'Connected to GPS! Location resolved.'
                                : 'Use your GPS for real-time weather, traffic, and nearby crisis signals.',
                            icon: Icons.track_changes_rounded,
                            accentColor: isSuccess
                                ? const Color(0xFF10B981)
                                : const Color(0xFF0EA5E9),
                            badgeText: isScanning ? null : 'GPS READY',
                            isLoading: isScanning,
                          ),

                          if (isSuccess) ...[
                            const SizedBox(height: 12),
                            _buildSuccessVisual(),
                          ],

                          const SizedBox(height: 12),

                          // Card 2: Islamabad G-10
                          _buildOptionCard(
                            mode: SelectionMode.demo,
                            title: 'Islamabad G-10 (Demo)',
                            subtitle:
                                'Guided walkthrough with preloaded signals and sample data.',
                            icon: Icons.map_rounded,
                            accentColor: const Color(0xFF8B5CF6),
                            badgeText: 'FOR TESTING',
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Bottom Button & Footnote
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF4F46E5,
                                  ).withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: isScanning ? null : _handleContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: isScanning
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      isSuccess &&
                                              _selection == SelectionMode.live
                                          ? 'Enter Command Center'
                                          : 'Continue',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFF94A3B8),
                                size: 13,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'You can change this anytime in Settings.',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ],
                  ),
                );

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: content,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required SelectionMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    String? badgeText,
    bool isLoading = false,
  }) {
    final isSelected = _selection == mode;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredMode = mode),
      onExit: (_) => setState(() => _hoveredMode = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF5F7FF)
              : (_hoveredMode == mode ? const Color(0xFFF8FAFC) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4F46E5)
                : (_hoveredMode == mode
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFFE2E8F0)),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF4F46E5).withValues(alpha: 0.05)
                  : (_hoveredMode == mode
                        ? Colors.black.withValues(alpha: 0.02)
                        : Colors.black.withValues(alpha: 0.01)),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              setState(() {
                _selection = mode;
              });
              if (mode == SelectionMode.live &&
                  _state == LocationState.initial) {
                _requestLocationAccess();
              }
            },
            borderRadius: BorderRadius.circular(16),
            highlightColor: Colors.transparent,
            splashColor: accentColor.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(icon, color: accentColor, size: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF0F172A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (badgeText != null || isLoading) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: accentColor.withValues(alpha: 0.15),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isLoading) ...[
                                      SizedBox(
                                        width: 8,
                                        height: 8,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                accentColor,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      isLoading ? 'ACQUIRING...' : badgeText!,
                                      style: GoogleFonts.inter(
                                        color: accentColor,
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFFCBD5E1),
                        width: isSelected ? 7.0 : 2.0,
                      ),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessVisual() {
    final isMock = _detectedLocation?.isMock == true;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMock ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMock ? const Color(0xFFFDE68A) : const Color(0xFFA7F3D0),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isMock ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMock ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
              color: isMock ? const Color(0xFFD97706) : const Color(0xFF059669),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMock
                      ? 'FALLBACK ACTIVE (GPS BLOCKED/TIMEOUT)'
                      : 'ACQUIRED ADDRESS',
                  style: GoogleFonts.inter(
                    color: isMock
                        ? const Color(0xFFB45309)
                        : const Color(0xFF059669),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _detectedLocation?.displayLabel ?? 'H-13, Islamabad',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  isMock
                      ? 'GPS unavailable - click lock icon in browser address bar to allow location'
                      : (_detectedLocation?.address ??
                            'Sector H-13, Islamabad, Pakistan'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: isMock
                        ? const Color(0xFFB45309)
                        : const Color(0xFF047857),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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

class HeaderIsometricPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    final originX = size.width / 2;
    final originY = size.height * 0.8;

    const angle = 28 * math.pi / 180;
    final cosAngle = math.cos(angle);
    final sinAngle = math.sin(angle);

    final gridSpacing = 16.0;

    for (int i = -8; i <= 8; i++) {
      final startPt = _isoToScreen(
        i * gridSpacing,
        -8 * gridSpacing,
        originX,
        originY,
        cosAngle,
        sinAngle,
      );
      final endPt = _isoToScreen(
        i * gridSpacing,
        8 * gridSpacing,
        originX,
        originY,
        cosAngle,
        sinAngle,
      );
      canvas.drawLine(startPt, endPt, linePaint);
    }

    for (int j = -8; j <= 8; j++) {
      final startPt = _isoToScreen(
        -8 * gridSpacing,
        j * gridSpacing,
        originX,
        originY,
        cosAngle,
        sinAngle,
      );
      final endPt = _isoToScreen(
        8 * gridSpacing,
        j * gridSpacing,
        originX,
        originY,
        cosAngle,
        sinAngle,
      );
      canvas.drawLine(startPt, endPt, linePaint);
    }

    // Draw smaller buildings
    _drawBuilding(
      canvas,
      -2.0 * gridSpacing,
      -2.5 * gridSpacing,
      24,
      20,
      30,
      originX,
      originY,
      cosAngle,
      sinAngle,
    );
    _drawBuilding(
      canvas,
      2.5 * gridSpacing,
      -3.0 * gridSpacing,
      20,
      20,
      25,
      originX,
      originY,
      cosAngle,
      sinAngle,
    );
    _drawBuilding(
      canvas,
      -2.5 * gridSpacing,
      1.5 * gridSpacing,
      20,
      24,
      20,
      originX,
      originY,
      cosAngle,
      sinAngle,
    );

    final centerOffset = Offset(size.width / 2, size.height * 0.65);
    final radarPaint = Paint()
      ..color = const Color(0xFF6366F1).withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawOval(
      Rect.fromCenter(center: centerOffset, width: 60, height: 30),
      radarPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: centerOffset, width: 100, height: 50),
      radarPaint,
    );
  }

  Offset _isoToScreen(
    double x,
    double y,
    double originX,
    double originY,
    double cosAngle,
    double sinAngle,
  ) {
    final screenX = originX + (x - y) * cosAngle;
    final screenY = originY + (x + y) * sinAngle;
    return Offset(screenX, screenY);
  }

  void _drawBuilding(
    Canvas canvas,
    double x,
    double y,
    double width,
    double length,
    double height,
    double originX,
    double originY,
    double cosAngle,
    double sinAngle,
  ) {
    final p0 = _isoToScreen(x, y, originX, originY, cosAngle, sinAngle);
    final p1 = _isoToScreen(x + width, y, originX, originY, cosAngle, sinAngle);
    final p2 = _isoToScreen(
      x + width,
      y + length,
      originX,
      originY,
      cosAngle,
      sinAngle,
    );
    final p3 = _isoToScreen(
      x,
      y + length,
      originX,
      originY,
      cosAngle,
      sinAngle,
    );

    final p0Top = Offset(p0.dx, p0.dy - height);
    final p1Top = Offset(p1.dx, p1.dy - height);
    final p2Top = Offset(p2.dx, p2.dy - height);
    final p3Top = Offset(p3.dx, p3.dy - height);

    final sidePaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    final leftFace = Path()
      ..moveTo(p0.dx, p0.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p3Top.dx, p3Top.dy)
      ..lineTo(p0Top.dx, p0Top.dy)
      ..close();
    canvas.drawPath(
      leftFace,
      sidePaint..color = const Color(0xFFEDF2F7).withValues(alpha: 0.6),
    );
    canvas.drawPath(leftFace, outlinePaint);

    final rightFace = Path()
      ..moveTo(p3.dx, p3.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p2Top.dx, p2Top.dy)
      ..lineTo(p3Top.dx, p3Top.dy)
      ..close();
    canvas.drawPath(
      rightFace,
      sidePaint..color = const Color(0xFFE2E8F0).withValues(alpha: 0.6),
    );
    canvas.drawPath(rightFace, outlinePaint);

    final topFace = Path()
      ..moveTo(p0Top.dx, p0Top.dy)
      ..lineTo(p1Top.dx, p1Top.dy)
      ..lineTo(p2Top.dx, p2Top.dy)
      ..lineTo(p3Top.dx, p3Top.dy)
      ..close();
    canvas.drawPath(
      topFace,
      sidePaint..color = const Color(0xFFF7FAFC).withValues(alpha: 0.7),
    );
    canvas.drawPath(topFace, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GradientLocationPinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.4);

    final shadowPaint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, size.height * 0.88),
        width: 16,
        height: 6,
      ),
      shadowPaint,
    );

    final path = Path();
    path.moveTo(center.dx, size.height * 0.85);
    path.cubicTo(
      center.dx - size.width * 0.48,
      size.height * 0.55,
      center.dx - size.width * 0.48,
      size.height * 0.1,
      center.dx,
      size.height * 0.1,
    );
    path.cubicTo(
      center.dx + size.width * 0.48,
      size.height * 0.1,
      center.dx + size.width * 0.48,
      size.height * 0.55,
      center.dx,
      size.height * 0.85,
    );
    path.close();

    final pinGradient = const LinearGradient(
      colors: [
        Color(0xFF60A5FA),
        Color(0xFF3B82F6),
        Color(0xFF6366F1),
        Color(0xFF8B5CF6),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, Paint()..shader = pinGradient);
    canvas.drawCircle(
      Offset(center.dx, size.height * 0.36),
      size.width * 0.18,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CardPanelPainter extends CustomPainter {
  final Color color;
  final bool isDemo;
  final bool isSuccess;
  final bool isScanning;
  final double pulseValue;

  CardPanelPainter({
    required this.color,
    required this.isDemo,
    this.isSuccess = false,
    this.isScanning = false,
    this.pulseValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw modern high-tech dot matrix grid
    final dotPaint = Paint()..color = const Color(0xFFE2E8F0);
    final dotSpacing = 16.0;
    for (double x = 8; x < size.width; x += dotSpacing) {
      for (double y = 8; y < size.height; y += dotSpacing) {
        canvas.drawCircle(Offset(x, y), 0.8, dotPaint);
      }
    }

    if (isDemo) {
      // Draw simulated road (double line or clean path)
      final roadPaint = Paint()
        ..color = color.withValues(alpha: 0.1)
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final roadPath = Path();
      roadPath.moveTo(size.width * 0.1, size.height * 0.5);
      roadPath.quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.85,
        size.width * 0.5,
        size.height * 0.5,
      );
      roadPath.quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.15,
        size.width * 0.9,
        size.height * 0.5,
      );
      canvas.drawPath(roadPath, roadPaint);

      // Draw dashed routing path
      final routePaint = Paint()
        ..color = color.withValues(alpha: 0.8)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final p1 = Offset(size.width * 0.1, size.height * 0.5);
      final p2 = Offset(size.width * 0.22, size.height * 0.65);
      final p3 = Offset(size.width * 0.35, size.height * 0.68);
      final p4 = Offset(size.width * 0.49, size.height * 0.5);

      final routePoints = [p1, p2, p3, p4];
      for (int i = 0; i < routePoints.length - 1; i++) {
        final start = routePoints[i];
        final end = routePoints[i + 1];
        // Draw dashes
        for (double t = 0; t <= 1; t += 0.35) {
          final pA = Offset.lerp(start, end, t)!;
          final pB = Offset.lerp(start, end, (t + 0.15).clamp(0.0, 1.0))!;
          canvas.drawLine(pA, pB, routePaint);
        }
      }

      // Draw building RRects
      final buildingPaint = Paint()
        ..color = const Color(0xFFF8FAFC)
        ..style = PaintingStyle.fill;
      final buildingStroke = Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;

      final buildings = [
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.15, size.height * 0.15, 24, 14),
          const Radius.circular(4),
        ),
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.68, size.height * 0.22, 20, 16),
          const Radius.circular(4),
        ),
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.58, size.height * 0.65, 26, 12),
          const Radius.circular(4),
        ),
      ];

      for (var b in buildings) {
        canvas.drawRRect(b, buildingPaint);
        canvas.drawRRect(b, buildingStroke);
      }

      // Draw trees
      final treeGreen = const Color(0xFF10B981).withValues(alpha: 0.8);
      final treeTrunk = const Color(0xFF94A3B8);

      final treePositions = [
        Offset(size.width * 0.38, size.height * 0.3),
        Offset(size.width * 0.82, size.height * 0.68),
      ];

      for (var tp in treePositions) {
        canvas.drawLine(
          tp,
          Offset(tp.dx, tp.dy + 6),
          Paint()
            ..color = treeTrunk
            ..strokeWidth = 1.0,
        );
        canvas.drawCircle(tp, 3.5, Paint()..color = treeGreen);
      }

      // Center Demo Pin (Destination point)
      final centerPt = Offset(size.width * 0.49, size.height * 0.5);

      // Glowing shadow under pin
      canvas.drawCircle(
        centerPt.translate(0, 1),
        8,
        Paint()
          ..color = color.withValues(alpha: 0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );

      // Pin outer ring
      canvas.drawCircle(
        centerPt,
        8,
        Paint()
          ..color = color.withValues(alpha: 0.15)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        centerPt,
        8,
        Paint()
          ..color = color.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
      // Center dot
      canvas.drawCircle(centerPt, 3.5, Paint()..color = color);
    } else {
      if (isSuccess) {
        // Keep the acquired address card extremely clean and readable.
        // Avoid drawing the road, sweeping radar, and blue/red node dots which overlap with text.
        return;
      }

      // Draw simulated road (double line or clean path)
      final roadPaint = Paint()
        ..color = color.withValues(alpha: 0.1)
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final roadPath = Path();
      roadPath.moveTo(0, size.height * 0.5);
      roadPath.quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.2,
        size.width * 0.5,
        size.height * 0.5,
      );
      roadPath.quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.8,
        size.width,
        size.height * 0.5,
      );
      canvas.drawPath(roadPath, roadPaint);

      final centerPt = Offset(size.width * 0.49, size.height * 0.5);

      // Pulse rings using pulseValue
      final pulseRadius1 = (pulseValue * 30) % 30;
      final pulseRadius2 = ((pulseValue + 0.5) * 30) % 30;

      // Pulse 1
      canvas.drawCircle(
        centerPt,
        pulseRadius1,
        Paint()
          ..color = color.withValues(alpha: 0.15 * (1.0 - pulseRadius1 / 30))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
      // Pulse 2
      canvas.drawCircle(
        centerPt,
        pulseRadius2,
        Paint()
          ..color = color.withValues(alpha: 0.15 * (1.0 - pulseRadius2 / 30))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      // Rotating sweep line
      final sweepAngle = pulseValue * 2 * math.pi;
      final sweepLength = 30.0;
      final sweepEnd = Offset(
        centerPt.dx + math.cos(sweepAngle) * sweepLength,
        centerPt.dy + math.sin(sweepAngle) * sweepLength,
      );
      canvas.drawLine(
        centerPt,
        sweepEnd,
        Paint()
          ..color = color.withValues(alpha: 0.2)
          ..strokeWidth = 0.8,
      );

      // Center GPS circle
      canvas.drawCircle(
        centerPt,
        5,
        Paint()
          ..color = color.withValues(alpha: 0.15)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(centerPt, 2.5, Paint()..color = color);

      // Nodes connection lines
      final cloudBubbleCenter = Offset(size.width * 0.25, size.height * 0.4);
      final carBubbleCenter = Offset(size.width * 0.68, size.height * 0.55);

      final linkPaint = Paint()
        ..color = color.withValues(alpha: 0.15)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;

      canvas.drawLine(centerPt, cloudBubbleCenter, linkPaint);
      canvas.drawLine(centerPt, carBubbleCenter, linkPaint);

      // Left Node (Cloud)
      canvas.drawCircle(
        cloudBubbleCenter.translate(0, 1),
        8,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.03)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
      canvas.drawCircle(cloudBubbleCenter, 8, Paint()..color = Colors.white);
      canvas.drawCircle(
        cloudBubbleCenter,
        8,
        Paint()
          ..color = const Color(0xFFE2E8F0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6,
      );
      canvas.drawCircle(
        Offset(cloudBubbleCenter.dx - 1.5, cloudBubbleCenter.dy + 1),
        2.2,
        Paint()..color = const Color(0xFF60A5FA),
      );
      canvas.drawCircle(
        Offset(cloudBubbleCenter.dx + 1.5, cloudBubbleCenter.dy),
        2.6,
        Paint()..color = const Color(0xFF3B82F6),
      );

      // Right Node (Hazard)
      canvas.drawCircle(
        carBubbleCenter.translate(0, 1),
        8,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.03)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
      canvas.drawCircle(carBubbleCenter, 8, Paint()..color = Colors.white);
      canvas.drawCircle(
        carBubbleCenter,
        8,
        Paint()
          ..color = const Color(0xFFE2E8F0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6,
      );
      canvas.drawCircle(
        carBubbleCenter,
        2.5,
        Paint()..color = const Color(0xFFEF4444),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CardPanelPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.isDemo != isDemo ||
      oldDelegate.isSuccess != isSuccess ||
      oldDelegate.isScanning != isScanning ||
      oldDelegate.pulseValue != pulseValue;
}
