// CIRO — Settings Screen v7
// Premium redesign with exact home-page profile section, stat badges,
// operational mode cards, preference tiles, and service section.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/app_mode_service.dart';
import '../services/user_profile_service.dart';
import '../components/settings_sheets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    const bgColor    = Color(0xFFF8FAFC);
    const titleColor = Color(0xFF0F172A);
    const brandColor = Color(0xFF4F46E5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: const SizedBox.shrink(),
        title: const Text(
          'Settings',
          style: TextStyle(color: titleColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          physics: const BouncingScrollPhysics(),
          children: [

            // ── 1. Premium Profile Card (same as home page) ─────────────────
            ListenableBuilder(
              listenable: UserProfileService.instance,
              builder: (context, _) {
                final profile = UserProfileService.instance;
                final hasName  = profile.name.isNotEmpty;
                final hasEmail = profile.email.isNotEmpty;
                final hasRole  = profile.role.isNotEmpty;

                return GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.30),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Gradient ring avatar — exact match to home page
                            Container(
                              width: 64, height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const SweepGradient(
                                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFF4F46E5)],
                                ),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: profile.customAvatarUrl != null
                                        ? Colors.transparent
                                        : UserProfileService.avatarColors[profile.avatarIndex],
                                  ),
                                  child: profile.customAvatarUrl != null
                                      ? ClipOval(
                                          child: Image.network(
                                            profile.customAvatarUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              UserProfileService.avatarIcons[profile.avatarIndex],
                                              color: Colors.white, size: 26,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          UserProfileService.avatarIcons[profile.avatarIndex],
                                          color: Colors.white, size: 26,
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Name / email / role
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hasName ? profile.name : 'Set Up Profile',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (hasEmail) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      profile.email,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.75),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.20),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      hasRole ? profile.role : 'Tap to Edit',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Edit chevron
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                color: Colors.white, size: 16,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
                        const SizedBox(height: 16),

                        // Stat badges row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildProfileStat('Reports', '12'),
                            _buildProfileStatDivider(),
                            _buildProfileStat('Alerts', '4'),
                            _buildProfileStatDivider(),
                            _buildProfileStat('Score', '98%'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // ── 2. Operational Mode ─────────────────────────────────────────
            const Text(
              'Operational Mode',
              style: TextStyle(color: titleColor, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListenableBuilder(
              listenable: AppModeService.instance,
              builder: (context, _) {
                final service    = AppModeService.instance;
                final isRealMode = service.isRealMode;
                return Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => service.setDemoMode(true),
                        child: _OperationalModeCard(
                          title: 'Demo Mode',
                          subtitle: 'Learn and explore without affecting real-world data.',
                          icon: Icons.computer_rounded,
                          isSelected: !isRealMode,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => service.setDemoMode(false),
                        child: _OperationalModeCard(
                          title: 'Real Mode',
                          subtitle: 'Operate with live systems and real-world impact.',
                          icon: Icons.security_rounded,
                          isSelected: isRealMode,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            // ── 3. Preferences ──────────────────────────────────────────────
            const Text(
              'Preferences',
              style: TextStyle(color: titleColor, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _PreferenceListTile(
                    icon: Icons.notifications_rounded,
                    title: 'Notifications',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (val) => setState(() => _notificationsEnabled = val),
                      activeThumbColor: Colors.white,
                      activeTrackColor: brandColor,
                      inactiveTrackColor: const Color(0xFFE2E8F0),
                      inactiveThumbColor: Colors.white,
                    ),
                  ),
                  _buildDivider(),
                  _PreferenceListTile(
                    icon: Icons.people_alt_rounded,
                    title: 'Emergency Contacts',
                    onTap: () => showSettingsSheet(context, const EmergencyContactsSheet()),
                  ),
                  _buildDivider(),
                  _PreferenceListTile(
                    icon: Icons.privacy_tip_rounded,
                    title: 'Privacy & Permissions',
                    onTap: () => showSettingsSheet(context, const PrivacyPermissionsSheet()),
                  ),
                  _buildDivider(),
                  _PreferenceListTile(
                    icon: Icons.lightbulb_rounded,
                    title: 'Safety Tips',
                    onTap: () => showSettingsSheet(context, const SafetyTipsSheet()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── 4. Test Real Services ───────────────────────────────────────
            GestureDetector(
              onTap: () => showSettingsSheet(context, const TestServicesSheet()),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cell_tower_rounded, color: Color(0xFF4F46E5), size: 20),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Test Real Services', style: TextStyle(color: titleColor, fontSize: 13, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('Run a connectivity and service health check.', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── 5. About ────────────────────────────────────────────────────
            const Text(
              'About',
              style: TextStyle(color: titleColor, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      image: const DecorationImage(
                        image: AssetImage('assets/logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CIRO Command Center', style: TextStyle(color: titleColor, fontSize: 13, fontWeight: FontWeight.bold)),
                        SizedBox(height: 2),
                        Text(
                          'Version 1.2.0 • Build 120\nSmarter operations. Safer communities.',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5, fontWeight: FontWeight.w500, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 56, right: 16),
      child: Divider(color: Color(0xFFF1F5F9), height: 1),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileStatDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.20),
    );
  }
}

// ── Supporting Widget: Operational Mode Card ─────────────────────────────────
class _OperationalModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;

  const _OperationalModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF5F3FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  size: 20,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (isSelected)
            Positioned(
              top: -4, right: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFF4F46E5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Supporting Widget: Preference List Tile ──────────────────────────────────
class _PreferenceListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _PreferenceListTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF4F46E5), size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
          ],
        ),
      ),
    );
  }
}
