import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/user_profile_service.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final AnimationController _bounceCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _formFade;
  late final Animation<double> _glowScale;

  final _nameController = TextEditingController();
  bool _isSigningIn = false;
  String _loadingMessage = '';
  
  // Temporary client ID overrides for runtime testing in browser without file changes
  String? _temporaryClientId;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut),
    );

    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowScale = Tween<double>(begin: 0.88, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _fadeCtrl.forward();
    _bounceCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _bounceCtrl.dispose();
    _pulseCtrl.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String? _getClientId() {
    if (_temporaryClientId != null && _temporaryClientId!.trim().isNotEmpty) {
      return _temporaryClientId!.trim();
    }
    final envVal = dotenv.env['GOOGLE_CLIENT_ID'];
    if (envVal != null && envVal.trim().isNotEmpty) {
      return envVal.trim();
    }
    return null;
  }

  // Handle Google Sign-In click
  Future<void> _handleGoogleSignIn() async {
    final clientId = _getClientId();

    if (clientId == null) {
      _showSetupGuideSheet();
      return;
    }

    setState(() {
      _isSigningIn = true;
      _loadingMessage = 'Connecting to Google accounts...';
    });

    try {
      final googleSignIn = GoogleSignIn(
        clientId: clientId,
        scopes: const ['email'],
      );

      final user = await googleSignIn.signIn();

      if (user == null) {
        // User cancelled flow
        setState(() {
          _isSigningIn = false;
        });
        return;
      }

      setState(() {
        _loadingMessage = 'Importing Google Profile...';
      });

      // Update User Profile Service with google profile info
      await UserProfileService.instance.updateProfile(
        name: user.displayName ?? user.email.split('@').first,
        role: 'Crisis Field Responder',
        email: user.email,
        avatarIndex: 0,
        customAvatarUrl: user.photoUrl,
      );

      setState(() {
        _loadingMessage = 'Authorized!';
      });

      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;

      context.go('/location');
    } on PlatformException catch (e) {
      setState(() {
        _isSigningIn = false;
      });
      final code = e.code.toLowerCase();
      final msg = (e.message ?? '').toLowerCase();
      if (code.contains('cancel') || msg.contains('cancel') || msg.contains('popup_closed')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign in was cancelled.'),
            backgroundColor: Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      _showErrorDialog(
        title: 'Google Sign-In Error',
        message: 'Platform exception: ${e.message}\n\n'
            'Please verify that your Google Cloud OAuth Client ID is correct, '
            'and that your current domain/port (e.g. localhost:${Uri.base.port}) '
            'is registered under "Authorized JavaScript Origins" in the Google Cloud Console.',
      );
    } catch (e) {
      setState(() {
        _isSigningIn = false;
      });
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('popup_closed') || errStr.contains('cancel') || errStr.contains('blocked')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign in was cancelled.'),
            backgroundColor: Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      _showErrorDialog(
        title: 'Connection Failed',
        message: 'Could not connect to Google APIs: $e\n\n'
            'Please check your network and verify your client ID configuration.',
      );
    }
  }

  // Handle manual onboarding
  Future<void> _handleManualSignIn() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your name to continue.'),
          backgroundColor: CiroColors.critical,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await UserProfileService.instance.updateProfile(
      name: name,
      role: '',
      email: '',
      avatarIndex: 0, // Royal Indigo default
    );

    if (!mounted) return;
    context.go('/location');
  }

  // Display configuration guide bottom sheet if client ID is missing
  void _showSetupGuideSheet() {
    final tempController = TextEditingController(text: _temporaryClientId ?? '');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.settings_suggest_rounded, color: CiroColors.brand, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'OAuth Client ID Required',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF0F172A),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'To enable live Google Sign-In, CIRO needs an OAuth 2.0 Web Client ID. Follow these steps to configure it:',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF475569),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStepItem('1', 'Create a Web OAuth Client ID in your Google Cloud Console.'),
                    _buildStepItem('2', 'Add Authorized JavaScript Origin: http://localhost:${Uri.base.port}'),
                    _buildStepItem('3', 'Open the .env file in the project root and add:\nGOOGLE_CLIENT_ID=your_client_id.apps.googleusercontent.com'),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 14),
                    Text(
                      'OR TEST RUNTIME OVERRIDE',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: TextField(
                        controller: tempController,
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                        decoration: const InputDecoration(
                          hintText: 'Paste Client ID to try on-the-fly...',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            // updates state inside bottom sheet
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _temporaryClientId = tempController.text;
                        });
                        Navigator.pop(context);
                        if (tempController.text.trim().isNotEmpty) {
                          _handleGoogleSignIn();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CiroColors.brand,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        tempController.text.trim().isNotEmpty
                            ? 'Apply Client ID & Connect'
                            : 'Close & Setup Locally',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
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

  Widget _buildStepItem(String number, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: CiroColors.brand,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              description,
              style: GoogleFonts.inter(
                color: const Color(0xFF334155),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Error Alert Dialog
  void _showErrorDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: CiroColors.critical),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF0F172A);
    const subtitleColor = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: CiroColors.bg1,
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CiroColors.brand.withValues(alpha: 0.08),
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
                color: CiroColors.brandLight.withValues(alpha: 0.05),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // Logo & App Branding
                    ScaleTransition(
                      scale: _logoScale,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Breathing glow outer ring
                            ScaleTransition(
                              scale: _glowScale,
                              child: Container(
                                width: 108,
                                height: 108,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      CiroColors.brand.withValues(alpha: 0.20),
                                      CiroColors.brandAccent.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: CiroColors.brand.withValues(alpha: 0.2),
                                    blurRadius: 28,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: CiroSpacing.lg),

                    FadeTransition(
                      opacity: _fadeCtrl,
                      child: Column(
                        children: [
                          Text(
                            'CIRO',
                            style: CiroTypography.displayLarge.copyWith(
                              letterSpacing: 3,
                              color: titleColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: CiroSpacing.xs),
                          Text(
                            'Crisis Intelligence & Response Orchestrator',
                            style: CiroTypography.bodyMedium.copyWith(
                              color: subtitleColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Onboarding pathways
                    FadeTransition(
                      opacity: _formFade,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Google Sign-in Button ──────────────────────────────────
                          GestureDetector(
                            onTap: _handleGoogleSignIn,
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4F46E5).withValues(alpha: 0.05),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/google.png',
                                    width: 18,
                                    height: 18,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Continue with Google',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF0F172A),
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // OR split divider
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: Color(0xFFE2E8F0),
                                  height: 1,
                                  endIndent: 16,
                                ),
                              ),
                              Text(
                                'OR CONTINUE MANUALLY',
                                style: CiroTypography.labelSmall.copyWith(
                                  color: const Color(0xFF94A3B8),
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: Color(0xFFE2E8F0),
                                  height: 1,
                                  indent: 16,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Premium Manual name card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.09), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildTextField(
                                  controller: _nameController,
                                  hint: 'Your Name',
                                  icon: Icons.person_outline_rounded,
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _handleManualSignIn,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4F46E5), // Indigo CTA
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: const Text(
                                      'Continue',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15.5,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay during authentication
          if (_isSigningIn)
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.75),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Pulsing Animated Icon Container
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                ScaleTransition(
                                  scale: _glowScale,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: (_loadingMessage.contains('Google')
                                          ? const Color(0xFF4285F4)
                                          : const Color(0xFF4F46E5)).withValues(alpha: 0.2),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: _loadingMessage.contains('Google')
                                      ? Center(
                                          child: Image.asset(
                                            'assets/google.png',
                                            width: 24,
                                            height: 24,
                                            fit: BoxFit.contain,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.shield_rounded,
                                          color: Color(0xFF4F46E5),
                                          size: 26,
                                        ),
                                ),
                                // Rotating thin accent ring
                                const SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            // Title
                            Text(
                              _loadingMessage.contains('Google')
                                  ? 'Google Authentication'
                                  : 'Securing Profile',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Subtitle / message
                            Text(
                              _loadingMessage,
                              style: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1).withValues(alpha: 0.7)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
          prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 18),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}


