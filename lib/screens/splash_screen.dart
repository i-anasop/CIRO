// CIRO — Splash Screen v3
// Minimal premium entry: light bg, blue logo, clean tagline, soft progress.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import '../services/app_mode_service.dart';
import '../services/location_service.dart';
import '../services/geocoding_service.dart';
import '../services/scenario_engine.dart';
import '../services/user_profile_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _progressCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<double> _progressVal;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _textCtrl = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _progressCtrl = AnimationController(
        duration: const Duration(milliseconds: 2200), vsync: this);

    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
    _logoFade  = CurvedAnimation(parent: _logoCtrl,    curve: Curves.easeIn);
    _textFade  = CurvedAnimation(parent: _textCtrl,    curve: Curves.easeIn);
    _progressVal = CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut);

    _logoCtrl.forward().then((_) {
      _textCtrl.forward();
      _progressCtrl.forward();
    });

    _initializeApp();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/logo.png'), context);
  }

  Future<void> _initializeApp() async {
    final startTime = DateTime.now();

    try {
      final isRealMode = AppModeService.instance.isRealMode;
      if (isRealMode) {
        // Silently request current location and geocode it asynchronously
        // to avoid blocking the main UI thread during splash animations.
        LocationService.instance.getCurrentLocation().then((locResult) {
          GeocodingService.instance.reverseGeocode(locResult).then((geocoded) {
            ScenarioEngine.instance.overrideLocation(
              geocoded.displayLabel,
              lat: geocoded.latitude,
              lng: geocoded.longitude,
            );
            
            // Silently run the real mode analysis in the background
            ScenarioEngine.instance.runRealSignalAnalysis(
              latitude: geocoded.latitude,
              longitude: geocoded.longitude,
            ).catchError((err) {
              debugPrint("Background real signal analysis failed: $err");
            });
          }).catchError((err) {
            debugPrint("Background geocoding failed: $err");
          });
        }).catchError((err) {
          debugPrint("Background location fetch failed: $err");
        });
      }
    } catch (e) {
      debugPrint("Error initializing during splash: $e");
    }

    final elapsed = DateTime.now().difference(startTime);
    final remainingDelay = const Duration(milliseconds: 2800) - elapsed;

    if (remainingDelay > Duration.zero) {
      await Future.delayed(remainingDelay);
    }

    if (mounted) {
      final isLoggedIn = UserProfileService.instance.isLoggedIn;
      if (isLoggedIn) {
        context.go('/location');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CiroColors.bg1,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center Content (Moved a bit up with padding)
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Logo ────────────────────────────────────────────────────
                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoFade,
                        child: _buildLogo(),
                      ),
                    ),

                    const SizedBox(height: CiroSpacing.xxl),

                    // ── Text ────────────────────────────────────────────────────
                    FadeTransition(
                      opacity: _textFade,
                      child: Column(children: [
                        Text('CIRO',
                            style: CiroTypography.displayLarge.copyWith(
                              letterSpacing: 4,
                            )),
                        const SizedBox(height: CiroSpacing.sm),
                        Text(
                          'Crisis Intelligence & Response Orchestrator',
                          style: CiroTypography.bodyMedium.copyWith(
                            color: CiroColors.textSecondary,
                            fontSize: 12.5,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ]),
                    ),

                    const SizedBox(height: CiroSpacing.huge),

                    // ── Progress bar ─────────────────────────────────────────────
                    FadeTransition(
                      opacity: _textFade,
                      child: SizedBox(
                        width: 180,
                        child: Column(children: [
                          AnimatedBuilder(
                            animation: _progressVal,
                            builder: (_, __) => ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value:     _progressVal.value,
                                minHeight: 3,
                                backgroundColor: CiroColors.border,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    CiroColors.brand),
                              ),
                            ),
                          ),
                          const SizedBox(height: CiroSpacing.md),
                          Text('Preparing crisis dashboard...',
                              style: CiroTypography.caption),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Version tag at the very bottom ──────────────────────────────────
            Positioned(
              bottom: 20,
              child: FadeTransition(
                opacity: _textFade,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: CiroSpacing.md, vertical: 5),
                  decoration: BoxDecoration(
                    color: CiroColors.bg4,
                    borderRadius: BorderRadius.circular(CiroSpacing.radiusCirc),
                  ),
                  child: Text('v1.0.0',
                      style: CiroTypography.caption
                          .copyWith(color: CiroColors.textMuted, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 110, height: 110,
      decoration: BoxDecoration(
        color: CiroColors.bg4,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: CiroColors.brandAccent.withValues(alpha: 0.25),
            blurRadius: 32, spreadRadius: 4,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: child,
            );
          },
        ),
      ),
    );
  }
}
