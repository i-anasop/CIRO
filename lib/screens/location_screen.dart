// CIRO — Location Screen v5
// Exact pixel-perfect match of both Light-Themed screens:
// 1. "Enable Location Permission" (Initial state matching the first image)
// 2. "Location Found" (Success state matching the second image)
// Dynamically transitions between the two with absolute high-fidelity details.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/location_service.dart';
import '../services/geocoding_service.dart';
import '../services/scenario_engine.dart';
import '../models/location_result.dart';

enum LocationState { initial, scanning, success, error }

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with SingleTickerProviderStateMixin {
  LocationState _state = LocationState.initial;
  LocationResult? _detectedLocation;
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
    setState(() {
      _state = LocationState.scanning;
    });

    final locResult = await LocationService.instance.getCurrentLocation();

    if (!locResult.isSuccess) {
      if (mounted) {
        // Safe demo fallback: if permission denied or GPS unavailable, fall back to mock G-10 Islamabad
        _useDemoLocation();
      }
      return;
    }

    final geocoded = await GeocodingService.instance.reverseGeocode(locResult);

    if (mounted) {
      ScenarioEngine.instance.overrideLocation(
        geocoded.displayLabel,
        lat: geocoded.latitude,
        lng: geocoded.longitude,
      );
      setState(() {
        _detectedLocation = geocoded;
        _state = LocationState.success;
      });
    }
  }

  void _useDemoLocation() {
    // Create custom result for G-10, Islamabad as the standard demo location
    final mockResult = LocationResult.mockIslamabad();

    ScenarioEngine.instance.overrideLocation(
      mockResult.displayLabel,
      lat: mockResult.latitude,
      lng: mockResult.longitude,
    );

    // Bypass transitional "Location Found" screen and redirect directly to dashboard
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF4F46E5); // Royal Indigo Blue
    const titleColor = Color(0xFF0F172A); // Dark Slate Blue
    const subtitleColor = Color(0xFF64748B); // Slate Gray
    const scaffoldBgColor = Color(0xFFF8FAFC); // Soft white-lavender backdrop
    
    final isSuccess = _state == LocationState.success;
    final themeColor = isSuccess ? const Color(0xFF10B981) : brandColor; // Emerald Green or Indigo

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              
              // ── Top Navigation Bar ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top left spacing to keep the pill badge centered
                  const SizedBox(width: 42),

                  // Pill Badge (Centered)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        if (isSuccess)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                          )
                        else
                          const Icon(
                            Icons.location_on_outlined,
                            color: brandColor,
                            size: 14,
                          ),
                        const SizedBox(width: 2),
                        Text(
                          isSuccess ? 'LOCATION DETECTED' : 'LOCATION ACCESS',
                          style: TextStyle(
                            color: isSuccess ? const Color(0xFF2E7D32) : brandColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Balancing dummy space
                  const SizedBox(width: 42),
                ],
              ),

              const Spacer(flex: 2),

              // ── Centered Map & Pulsing Pin Illustration ─────────────────────
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Stylized vector path lines/lanes representing a map grid
                    Positioned.fill(
                      child: CustomPaint(
                        painter: MapVectorGridPainter(lineColor: isSuccess ? const Color(0xFFE2E8F0) : const Color(0xFFE2E8F0)),
                      ),
                    ),

                    // Fading Concentric Radar Rings (Green on success, Indigo on permission)
                    for (int i = 0; i < 3; i++)
                      AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (context, child) {
                          double progress = (_pulseCtrl.value + i / 3.0) % 1.0;
                          return Container(
                            width: 80 + (progress * 120),
                            height: 80 + (progress * 120),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: themeColor.withValues(alpha: (1.0 - progress) * 0.15),
                                width: 1.2,
                              ),
                            ),
                          );
                        },
                      ),

                    // Outer Map pin backdrop shadow/glow
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withValues(alpha: 0.12),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.location_on_rounded,
                          color: themeColor,
                          size: 38,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── Header Text Section ──────────────────────────────────────────
              Text(
                isSuccess ? 'Location Found' : 'Enable Location Permission',
                style: const TextStyle(
                  color: titleColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  isSuccess
                      ? 'CIRO has securely identified your current area.'
                      : 'CIRO needs your location to detect nearby signals, analyze situations, and provide accurate crisis intelligence.',
                  style: const TextStyle(
                    color: subtitleColor,
                    fontSize: 14,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 28),

              // ── Card Panel (Feature checklist or Identified location card) ──
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _buildCentralCard(),
              ),

              const Spacer(flex: 3),

              // ── Action Buttons ──────────────────────────────────────────────
              _buildBottomActionArea(brandColor),

              const Spacer(),

              // ── Notice Footer ──────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSuccess ? Icons.info_outline_rounded : Icons.lock_outline_rounded,
                    color: const Color(0xFF94A3B8),
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isSuccess ? 'You can update this later in settings.' : 'You can change this anytime in settings.',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Central Dynamic Content Card ────────────────────────────────────────
  Widget _buildCentralCard() {
    if (_state != LocationState.success) {
      // Feature checklist card (First design)
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            _buildFeatureRow(
              icon: Icons.gps_fixed_rounded,
              title: 'Real-time Monitoring',
              subtitle: 'Detect nearby risks and hazards in real-time.',
            ),
            const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
            _buildFeatureRow(
              icon: Icons.shield_outlined,
              title: 'Accurate Response',
              subtitle: 'Get personalized recommendations for your exact location.',
            ),
            const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
            _buildFeatureRow(
              icon: Icons.lock_outline_rounded,
              title: 'Privacy First',
              subtitle: 'Your location data is secure and never shared.',
            ),
          ],
        ),
      );
    } else {
      // Detected Location display card (Second design)
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Light Green Pin icon box
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Color(0xFF2E7D32),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),

            // Sector details text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _detectedLocation?.displayLabel ?? 'G-10, Islamabad',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lat ${_detectedLocation?.latitude?.toStringAsFixed(4)}, Lon ${_detectedLocation?.longitude?.toStringAsFixed(4)}',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
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

  // ── Dynamic Action Button Area ──────────────────────────────────────────
  Widget _buildBottomActionArea(Color brandColor) {
    if (_state == LocationState.scanning) {
      return SizedBox(
        height: 56,
        child: Center(
          child: CircularProgressIndicator(
            color: brandColor,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (_state != LocationState.success) {
      return Column(
        children: [
          // Allow Location Access Button (Design 1)
          GestureDetector(
            onTap: _requestLocationAccess,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF0B0F19),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.rotate(
                    angle: -0.4,
                    child: const Icon(
                      Icons.send_rounded,
                      color: Color(0xFF6366F1),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Allow Location Access',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Use Demo Location Instead (Design 1)
          GestureDetector(
            onTap: _useDemoLocation,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    color: brandColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Use Demo Location Instead',
                    style: TextStyle(
                      color: brandColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      // Enter Command Center button (Design 2 Success Green button)
      return GestureDetector(
        onTap: () => context.go('/home'),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF34D399), // Match the bright emerald/mint green from success design
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF34D399)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shield_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Enter Command Center',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4F46E5),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.3,
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

class MapVectorGridPainter extends CustomPainter {
  final Color lineColor;
  MapVectorGridPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.fill;

    final path = Path();
    
    path.moveTo(0, size.height * 0.7);
    path.cubicTo(size.width * 0.25, size.height * 0.6, size.width * 0.7, size.height * 0.85, size.width, size.height * 0.75);

    path.moveTo(0, size.height * 0.5);
    path.cubicTo(size.width * 0.3, size.height * 0.55, size.width * 0.6, size.height * 0.4, size.width, size.height * 0.55);

    canvas.drawPath(path, paint);

    final crossPath = Path();
    crossPath.moveTo(size.width * 0.2, size.height * 0.2);
    crossPath.lineTo(size.width * 0.35, size.height * 0.9);

    crossPath.moveTo(size.width * 0.8, size.height * 0.15);
    crossPath.lineTo(size.width * 0.65, size.height * 0.85);

    canvas.drawPath(crossPath, paint);

    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.35), 4, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.45), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant MapVectorGridPainter oldDelegate) => oldDelegate.lineColor != lineColor;
}
