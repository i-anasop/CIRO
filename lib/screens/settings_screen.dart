// CIRO — Settings Screen v7
// Premium redesign with exact home-page profile section, stat badges,
// operational mode cards, preference tiles, and service section.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/interactive_map_helper.dart';
import '../services/app_mode_service.dart';
import '../services/user_profile_service.dart';
import '../services/scenario_engine.dart';
import '../services/notification_service.dart';
import '../components/settings_sheets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  Future<void> _activateRealMode(AppModeService service) async {
    service.setDemoMode(false);
    ScenarioEngine.instance.resetRealAnalysis();
    await NotificationService.instance.requestPermissions();
    NotificationService.instance.addNotification(
      title: 'Real Mode Initializing',
      details:
          'CIRO is checking live location, weather, route, and report sources.',
    );
    await ScenarioEngine.instance.runRealSignalAnalysis();
    if (mounted) setState(() {});
  }

  void _activateDemoMode(AppModeService service) {
    service.setDemoMode(true);
    ScenarioEngine.instance.reset();
    NotificationService.instance.addNotification(
      title: 'Demo Mode Activated',
      details: 'G-10 Islamabad demo monitoring is active.',
    );
    if (mounted) setState(() {});
  }

  void _showChangeLocationSheet() {
    final service = AppModeService.instance;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Change Location',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Choose demo G-10 or refresh using your current live location.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    height: 210,
                    child: createInteractiveMap(
                      latitude: 33.6946,
                      longitude: 73.0179,
                      zoom: 15,
                      selectedLayer: 'Flood Risk',
                      showRiskZone: true,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _activateDemoMode(service);
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.location_city_rounded, size: 17),
                        label: const Text('Use G-10 Demo'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _activateRealMode(service);
                        },
                        icon: const Icon(Icons.my_location_rounded, size: 17),
                        label: const Text('Use Live Location'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111827),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmSwitchToRealMode(BuildContext context, AppModeService service) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
              SizedBox(width: 8),
              Text(
                'Switch to Real Mode?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: const Text(
            'This will activate real-world operations. CIRO will request your live GPS coordinates, reverse geocode your location, and query active external pipelines.',
            style: TextStyle(height: 1.4, fontSize: 13.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _activateRealMode(service);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmSwitchToDemoMode(BuildContext context, AppModeService service) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.computer_rounded, color: Color(0xFF4F46E5)),
              SizedBox(width: 8),
              Text(
                'Switch to Demo Mode?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: const Text(
            'This will re-activate mock scenarios for a safe hackathon demonstration. Live GPS coordinates and active external API pipelines will be paused.',
            style: TextStyle(height: 1.4, fontSize: 13.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _activateDemoMode(service);
                // 4. Show snackbar to confirm
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Successfully switched to Demo Mode'),
                      ],
                    ),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF8FAFC);
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
          style: TextStyle(
            color: titleColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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
                final hasName = profile.name.isNotEmpty;
                final hasEmail = profile.email.isNotEmpty;
                final hasRole = profile.role.isNotEmpty;

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
                          color: const Color(
                            0xFF4F46E5,
                          ).withValues(alpha: 0.30),
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
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const SweepGradient(
                                  colors: [
                                    Color(0xFF3B82F6),
                                    Color(0xFF8B5CF6),
                                    Color(0xFF4F46E5),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: profile.customAvatarUrl != null
                                        ? Colors.transparent
                                        : UserProfileService
                                              .avatarColors[profile
                                              .avatarIndex],
                                  ),
                                  child: profile.customAvatarUrl != null
                                      ? ClipOval(
                                          child: Image.network(
                                            profile.customAvatarUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              UserProfileService
                                                  .avatarIcons[profile
                                                  .avatarIndex],
                                              color: Colors.white,
                                              size: 26,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          UserProfileService.avatarIcons[profile
                                              .avatarIndex],
                                          color: Colors.white,
                                          size: 26,
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
                                        color: Colors.white.withValues(
                                          alpha: 0.75,
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.20,
                                      ),
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
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
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
              style: TextStyle(
                color: titleColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListenableBuilder(
              listenable: AppModeService.instance,
              builder: (context, _) {
                final service = AppModeService.instance;
                final isRealMode = service.isRealMode;
                return Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (isRealMode) {
                            _confirmSwitchToDemoMode(context, service);
                          }
                        },
                        child: _OperationalModeCard(
                          title: 'Demo Mode',
                          subtitle:
                              'Learn and explore without affecting real-world data.',
                          icon: Icons.computer_rounded,
                          isSelected: !isRealMode,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!isRealMode) {
                            _confirmSwitchToRealMode(context, service);
                          }
                        },
                        child: _OperationalModeCard(
                          title: 'Real Mode',
                          subtitle:
                              'Operate with live systems and real-world impact.',
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
              style: TextStyle(
                color: titleColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
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
                      onChanged: (val) =>
                          setState(() => _notificationsEnabled = val),
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
                    onTap: () => showSettingsSheet(
                      context,
                      const EmergencyContactsSheet(),
                    ),
                  ),
                  _buildDivider(),
                  _PreferenceListTile(
                    icon: Icons.location_on_rounded,
                    title: 'Change Location',
                    onTap: _showChangeLocationSheet,
                  ),
                  _buildDivider(),
                  _PreferenceListTile(
                    icon: Icons.privacy_tip_rounded,
                    title: 'Privacy & Permissions',
                    onTap: () => showSettingsSheet(
                      context,
                      const PrivacyPermissionsSheet(),
                    ),
                  ),
                  _buildDivider(),
                  _PreferenceListTile(
                    icon: Icons.lightbulb_rounded,
                    title: 'Safety Tips',
                    onTap: () =>
                        showSettingsSheet(context, const SafetyTipsSheet()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── 4. About ────────────────────────────────────────────────────
            const Text(
              'About',
              style: TextStyle(
                color: titleColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
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
                    width: 52,
                    height: 52,
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
                        Text(
                          'CIRO Command Center',
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Version 1.2.0 • Build 120\nSmarter operations. Safer communities.',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
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
                  color: isSelected
                      ? const Color(0xFF4F46E5)
                      : const Color(0xFFF1F5F9),
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
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFF4F46E5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 12,
                ),
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
            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }
}
