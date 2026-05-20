import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/user_profile_service.dart';
import '../utils/image_picker_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _emailController = TextEditingController();
  int _selectedIndex = 0;
  String? _customUrl;
  String? _noticeTitle;
  String? _noticeSubtitle;
  IconData _noticeIcon = Icons.check_rounded;
  bool _isExpanded = false;
  bool _isProfileEditing = false;

  @override
  void initState() {
    super.initState();
    final profile = UserProfileService.instance;
    _nameController.text = profile.name;
    _roleController.text = profile.role;
    _emailController.text = profile.email;
    _selectedIndex = profile.avatarIndex;
    _customUrl = profile.customAvatarUrl;
    _isExpanded = _selectedIndex >= 3 && _customUrl == null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomPicture() async {
    final result = await pickImageBytes();
    if (result != null) {
      setState(() {
        _customUrl = result;
        _isProfileEditing = true;
        _noticeTitle = 'Profile photo ready';
        _noticeSubtitle = 'Save your profile to keep this picture locally.';
        _noticeIcon = Icons.photo_camera_rounded;
      });
    }
  }

  Future<void> _saveProfileInPlace() async {
    setState(() {
      _isProfileEditing = false;
    });
    await UserProfileService.instance.updateProfile(
      name: _nameController.text,
      role: _roleController.text,
      email: _emailController.text,
      avatarIndex: _selectedIndex,
      customAvatarUrl: _customUrl,
    );
    if (!mounted) return;
    setState(() {
      _noticeTitle = 'Profile updated';
      _noticeSubtitle = 'Saved locally on this device.';
      _noticeIcon = Icons.check_rounded;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _noticeTitle = null;
        _noticeSubtitle = null;
      });
    }
  }

  ImageProvider? _getAvatarImage(String? image) {
    if (image == null || image.isEmpty) return null;
    if (image.startsWith('data:image')) {
      try {
        final base64String = image.split(',').last;
        return MemoryImage(base64Decode(base64String));
      } catch (_) {
        return NetworkImage(image);
      }
    }
    return NetworkImage(image);
  }

  // Avatar badge configs exactly matching premium crisis responder roles
  static const List<_BadgeConfig> _badges = [
    _BadgeConfig(
      bg: Color(0xFFEEF2FF),
      ring: Color(0xFF4F46E5),
      icon: Icons.person_rounded,
      iconColor: Color(0xFF4F46E5),
    ),
    _BadgeConfig(
      bg: Color(0xFFECFDF5),
      ring: Color(0xFF10B981),
      icon: Icons.security_rounded,
      iconColor: Color(0xFF10B981),
    ),
    _BadgeConfig(
      bg: Color(0xFFFEF9C3),
      ring: Color(0xFFF59E0B),
      icon: Icons.star_rounded,
      iconColor: Color(0xFFF59E0B),
    ),
    _BadgeConfig(
      bg: Color(0xFFF3E8FF),
      ring: Color(0xFF8B5CF6),
      icon: Icons.memory_rounded,
      iconColor: Color(0xFF8B5CF6),
    ),
    _BadgeConfig(
      bg: Color(0xFFECFEFF),
      ring: Color(0xFF06B6D4),
      icon: Icons.satellite_alt_rounded,
      iconColor: Color(0xFF06B6D4),
    ),
    _BadgeConfig(
      bg: Color(0xFFFFF1F2),
      ring: Color(0xFFF43F5E),
      icon: Icons.rocket_launch_rounded,
      iconColor: Color(0xFFF43F5E),
    ),
    _BadgeConfig(
      bg: Color(0xFFEFF6FF),
      ring: Color(0xFF3B82F6),
      icon: Icons.hub_rounded,
      iconColor: Color(0xFF3B82F6),
    ),
    _BadgeConfig(
      bg: Color(0xFFFDF2F8),
      ring: Color(0xFFEC4899),
      icon: Icons.psychology_rounded,
      iconColor: Color(0xFFEC4899),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF4F46E5);
    const titleColor = Color(0xFF0F172A);
    const subtitleColor = Color(0xFF64748B);
    const bgColor = Color(0xFFF5F6FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: titleColor,
            size: 18,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: titleColor,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              if (_isProfileEditing == true) {
                _saveProfileInPlace();
              } else {
                setState(() {
                  _isProfileEditing = true;
                });
              }
            },
            icon: Icon(
              (_isProfileEditing == true)
                  ? Icons.check_rounded
                  : Icons.edit_rounded,
              color: (_isProfileEditing == true)
                  ? const Color(0xFF10B981)
                  : const Color(0xFF4F46E5),
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Large Avatar with camera badge ──────────────────────────
              Center(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Outer soft glow ring
                        Container(
                          width: 114,
                          height: 114,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFFE2E5FF),
                              width: 3.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF4F46E5,
                                ).withValues(alpha: 0.12),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: _customUrl != null
                                      ? [Colors.transparent, Colors.transparent]
                                      : [
                                          UserProfileService
                                              .avatarColors[_selectedIndex],
                                          UserProfileService
                                              .avatarColors[_selectedIndex]
                                              .withValues(alpha: 0.8),
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: _customUrl != null
                                  ? ClipOval(
                                      child: Image(
                                        image: _getAvatarImage(_customUrl)!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          UserProfileService
                                              .avatarIcons[_selectedIndex],
                                          color: Colors.white,
                                          size: 46,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      UserProfileService
                                          .avatarIcons[_selectedIndex],
                                      color: Colors.white,
                                      size: 46,
                                    ),
                            ),
                          ),
                        ),

                        // Camera badge — bottom-right, matching screenshot
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: _pickCustomPicture,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: brandColor,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome to CIRO',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Manage your CIRO responder identity',
                      style: TextStyle(
                        color: subtitleColor.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (_noticeTitle != null && _noticeSubtitle != null) ...[
                const SizedBox(height: 18),
                _ProfileNotice(
                  icon: _noticeIcon,
                  title: _noticeTitle!,
                  subtitle: _noticeSubtitle!,
                ),
              ],
              const SizedBox(height: 32),

              // ── Preset Avatar Badges Card ───────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.badge_outlined,
                            color: Color(0xFF4F46E5),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Preset Avatar Badges',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Select a premium crisis intelligence role badge',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Collapsible presets grid
                    Center(
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: [
                            ...List.generate(_isExpanded ? _badges.length : 3, (
                              index,
                            ) {
                              final isSelected =
                                  _selectedIndex == index && _customUrl == null;
                              final badge = _badges[index];

                              return GestureDetector(
                                onTap: () => setState(() {
                                  _selectedIndex = index;
                                  _customUrl = null;
                                  _isProfileEditing = true;
                                }),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 62,
                                      height: 62,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: badge.bg,
                                        border: Border.all(
                                          color: isSelected
                                              ? badge.ring
                                              : Colors.transparent,
                                          width: 2.5,
                                        ),
                                      ),
                                      child: Icon(
                                        badge.icon,
                                        color: badge.iconColor,
                                        size: 26,
                                      ),
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        top: -2,
                                        right: -2,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: badge.ring,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.check_rounded,
                                            color: Colors.white,
                                            size: 11,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                            GestureDetector(
                              onTap: () => setState(() {
                                _isExpanded = !_isExpanded;
                              }),
                              child: Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFF1F5F9),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFCBD5E1,
                                    ).withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: _isExpanded
                                      ? const Icon(
                                          Icons.keyboard_arrow_up_rounded,
                                          color: Color(0xFF64748B),
                                          size: 24,
                                        )
                                      : const Text(
                                          '+5',
                                          style: TextStyle(
                                            color: Color(0xFF4F46E5),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Profile Details Card ────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: Color(0xFF4F46E5),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profile Details',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Update your personal and professional information',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Input Fields with inline placeholders
                    _buildProfileTextField(
                      controller: _nameController,
                      placeholder: 'Full Name',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildProfileTextField(
                      controller: _roleController,
                      placeholder: 'Role / Designation',
                      icon: Icons.business_center_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildProfileTextField(
                      controller: _emailController,
                      placeholder: 'Email Address',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    const brandColor = Color(0xFF4F46E5);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Row(
        children: [
          // Icon Container on the Left
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: brandColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                readOnly: _isProfileEditing != true,
                style: const TextStyle(
                  fontSize: 14.5,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  hintText: placeholder,
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileNotice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProfileNotice({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8E2FF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF4F46E5), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
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

// Badge config helper
class _BadgeConfig {
  final Color bg;
  final Color ring;
  final IconData icon;
  final Color iconColor;
  const _BadgeConfig({
    required this.bg,
    required this.ring,
    required this.icon,
    required this.iconColor,
  });
}
