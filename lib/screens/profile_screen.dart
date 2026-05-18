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
  final _nameController  = TextEditingController();
  final _roleController  = TextEditingController();
  final _emailController = TextEditingController();
  int _selectedIndex = 0;
  String? _customUrl;

  @override
  void initState() {
    super.initState();
    final profile = UserProfileService.instance;
    _nameController.text  = profile.name;
    _roleController.text  = profile.role;
    _emailController.text = profile.email;
    _selectedIndex        = profile.avatarIndex;
    _customUrl            = profile.customAvatarUrl;
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
      setState(() => _customUrl = result);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Profile picture updated successfully!'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _saveProfile() {
    UserProfileService.instance.updateProfile(
      name: _nameController.text,
      role: _roleController.text,
      email: _emailController.text,
      avatarIndex: _selectedIndex,
      customAvatarUrl: _customUrl,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ Profile saved successfully'),
        backgroundColor: Color(0xFF4F46E5),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }

  // Avatar badge configs exactly matching screenshot
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
  ];

  @override
  Widget build(BuildContext context) {
    const brandColor    = Color(0xFF4F46E5);
    const titleColor    = Color(0xFF0F172A);
    const subtitleColor = Color(0xFF64748B);
    const bgColor       = Color(0xFFF5F6FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: titleColor, size: 18),
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
                          width: 114, height: 114,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
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
                                          UserProfileService.avatarColors[_selectedIndex],
                                          UserProfileService.avatarColors[_selectedIndex]
                                              .withValues(alpha: 0.7),
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: _customUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        _customUrl!, fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          UserProfileService.avatarIcons[_selectedIndex],
                                          color: Colors.white, size: 46,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      UserProfileService.avatarIcons[_selectedIndex],
                                      color: Colors.white, size: 46,
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
                              width: 34, height: 34,
                              decoration: const BoxDecoration(
                                color: brandColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x334F46E5),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Personalize your CIRO operator profile',
                      style: TextStyle(
                        color: subtitleColor.withValues(alpha: 0.8),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Preset Avatar Badges ────────────────────────────────────
              const Text(
                'Preset Avatar Badges',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  final isSelected = _selectedIndex == index && _customUrl == null;
                  final badge = _badges[index];

                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedIndex = index;
                      _customUrl = null;
                    }),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 62, height: 62,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: badge.bg,
                            border: Border.all(
                              color: isSelected ? badge.ring : Colors.transparent,
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
                            top: -2, right: -2,
                            child: Container(
                              width: 20, height: 20,
                              decoration: BoxDecoration(
                                color: badge.ring,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.check_rounded, color: Colors.white, size: 11),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // ── Full Name ───────────────────────────────────────────────
              _buildFieldLabel('Full Name'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: 'e.g. Sarah Khan',
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFF4F46E5),
                iconBg: const Color(0xFFEEF2FF),
              ),
              const SizedBox(height: 20),

              // ── Role / Designation ──────────────────────────────────────
              _buildFieldLabel('Role / Designation'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _roleController,
                hint: 'e.g. CIRO Operator',
                icon: Icons.work_outline_rounded,
                iconColor: const Color(0xFF4F46E5),
                iconBg: const Color(0xFFEEF2FF),
              ),
              const SizedBox(height: 20),

              // ── Email Address ───────────────────────────────────────────
              _buildFieldLabel('Email Address'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hint: 'e.g. operator@ciro.gov.pk',
                icon: Icons.mail_outline_rounded,
                iconColor: const Color(0xFF4F46E5),
                iconBg: const Color(0xFFEEF2FF),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 36),

              // ── Actions ─────────────────────────────────────────────────
              Row(
                children: [
                  // Cancel
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        side: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF4F46E5),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Save Profile
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: const Color(0xFF4F46E5),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Save Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFCBD5E1),
          fontSize: 13.5,
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 60, minHeight: 52),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE8EDF5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE8EDF5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
        ),
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
