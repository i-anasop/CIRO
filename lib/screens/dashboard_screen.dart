// CIRO — Dashboard Screen v6
// High-fidelity, premium operations dashboard matching the user's design mockup exactly.
// Features a sweep gradient "O" in CIRO, pixel-perfect cards, a floating nav bar theme,
// and fully interactive bottom drawers for notifications, contacts, safety, and shelters.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/scenario_engine.dart';
import '../services/user_profile_service.dart';
import '../services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  // Show a premium emergency contacts bottom sheet
  void _showEmergencyContacts(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Emergency Helplines',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Direct lines to local emergency operations units.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const SizedBox(height: 20),
              _buildContactItem(
                icon: Icons.local_fire_department_rounded,
                title: 'Rescue 1122',
                subtitle: 'Disaster management & ambulance dispatch',
                phone: '1122',
                color: const Color(0xFFEF4444),
              ),
              const Divider(color: Color(0xFFF1F5F9), height: 16),
              _buildContactItem(
                icon: Icons.business_rounded,
                title: 'CDA Helpline',
                subtitle: 'Islamabad drainage & debris operations',
                phone: '1334',
                color: const Color(0xFF3B82F6),
              ),
              const Divider(color: Color(0xFFF1F5F9), height: 16),
              _buildContactItem(
                icon: Icons.security_rounded,
                title: 'NDMA Control Room',
                subtitle: 'National disaster coordination centre',
                phone: '051-111-157-157',
                color: const Color(0xFF10B981),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // Show premium safety checklist bottom sheet
  void _showSafetyTips(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Active Safety Protocol',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Critical guidelines for Urban Flooding & heavy rainfall.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const SizedBox(height: 20),
              _buildTipItem('1', 'Avoid Flooded Underpasses', 'Do not attempt to drive or walk through deep waterlogging, especially in G-10 Markaz routes.'),
              const SizedBox(height: 14),
              _buildTipItem('2', 'Unplug High-Voltage Appliances', 'Protect your home from power grid failures and waterlogged outlet electrical shocks.'),
              const SizedBox(height: 14),
              _buildTipItem('3', 'Track Official Evacuations', 'Monitor live CDA reports and prepare a basic emergency bag with drinking water.'),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // Show active shelters bottom sheet
  void _showShelters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Safe Relief Shelters',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Identified dry zones and distribution units nearby.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const SizedBox(height: 20),
              _buildShelterItem('G-10 Community Center', 'Secured dry zone, hot meals available', '1.2 km away', 'Active'),
              const Divider(color: Color(0xFFF1F5F9), height: 16),
              _buildShelterItem('F-7 Sports Complex', 'Medical station and rescue base', '3.4 km away', 'Active'),
              const Divider(color: Color(0xFFF1F5F9), height: 16),
              _buildShelterItem('Margalla Relief Shelter', 'Capacity: 120 people, cots provided', '4.8 km away', 'Standby'),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF4F46E5);
    const titleColor = Color(0xFF0F172A);
    const subtitleColor = Color(0xFF64748B);
    const scaffoldBgColor = Color(0xFFF8FAFC);

    return ListenableBuilder(
      listenable: ScenarioEngine.instance,
      builder: (context, _) {
        final engine = ScenarioEngine.instance;
        final crisis = engine.activeCrisis;

        return Scaffold(
          backgroundColor: scaffoldBgColor,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                // ── Top Navigation Bar (Location pill + Bell + Avatar) ────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dynamic Location capsule matching screenshot perfectly
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: brandColor,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            crisis.location,
                            style: const TextStyle(
                              color: titleColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Notification & Avatar row
                    ListenableBuilder(
                      listenable: UserProfileService.instance,
                      builder: (context, _) {
                        final profile = UserProfileService.instance;

                        return ListenableBuilder(
                          listenable: NotificationService.instance,
                          builder: (context, _) {
                            final unreadCount = NotificationService.instance.unreadCount;

                            return Row(
                              children: [
                                // Bell Button with dynamic badge
                                GestureDetector(
                                  onTap: () => context.push('/notifications'),
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      clipBehavior: Clip.none,
                                      children: [
                                        const Icon(
                                          Icons.notifications_none_rounded,
                                          color: titleColor,
                                          size: 22,
                                        ),
                                        if (unreadCount > 0)
                                          Positioned(
                                            top: -2,
                                            right: -2,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                '$unreadCount',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Profile Avatar with tap action to edit
                                GestureDetector(
                                  onTap: () => context.push('/profile'),
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                      gradient: const SweepGradient(
                                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFF4F46E5)],
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: profile.customAvatarUrl != null
                                              ? Colors.transparent
                                              : UserProfileService.avatarColors[profile.avatarIndex],
                                        ),
                                        child: profile.customAvatarUrl != null
                                            ? ClipOval(
                                                child: Image.network(profile.customAvatarUrl!, fit: BoxFit.cover),
                                              )
                                            : Icon(
                                                UserProfileService.avatarIcons[profile.avatarIndex],
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'CIR',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        height: 1.0, // Clear line-height vertical pad
                      ),
                    ),
                    // Elegant Blue/Purple Sweep Gradient circular glowing "O" logo
                    Container(
                      margin: const EdgeInsets.only(left: 2, bottom: 2), // High-precision baseline lift
                      width: 29,
                      height: 29,
                      padding: const EdgeInsets.all(4.5), // Gradient border thickness
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            Color(0xFF3B82F6), // Royal Blue
                            Color(0xFF8B5CF6), // Purple Glow
                            Color(0xFF4F46E5), // Indigo
                            Color(0xFF3B82F6), // Back to Royal Blue
                          ],
                        ),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: scaffoldBgColor, // Blends perfectly with the light backdrop
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Command Center',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Active Risk Card (Top Red Card) ────────────────────────────
                GestureDetector(
                  onTap: () => context.go('/home/crisis-detail', extra: crisis),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFEE2E2), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.03),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // Wave/Rain warning icon box
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFEE2E2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.thunderstorm_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'ACTIVE RISK',
                                      style: TextStyle(
                                        color: Color(0xFFEF4444),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      crisis.typeLabel,
                                      style: const TextStyle(
                                        color: titleColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFEF4444)),
                                  ),
                                  child: const Text(
                                    'HIGH',
                                    style: TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: subtitleColor,
                                  size: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Confidence',
                                    style: TextStyle(color: subtitleColor, fontSize: 12),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${crisis.confidence} %',
                                    style: const TextStyle(
                                      color: titleColor,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1.2,
                              height: 52,
                              color: const Color(0xFFF1F5F9),
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            const Expanded(
                              flex: 2,
                              child: Text(
                                'Heavy rainfall upstream may cause flash flooding in low-lying areas within the next 3–6 hours.',
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 12.5,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Three Column Signal Grid (Weather, Traffic, News) ────────
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSignalCol(
                        icon: Icons.water_drop_outlined,
                        title: 'Weather',
                        bigText: 'Heavy Rain',
                        subText: '72 mm',
                        badgeText: 'High',
                        badgeColor: const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 12),
                      _buildSignalCol(
                        icon: Icons.directions_car_outlined,
                        title: 'Traffic',
                        bigText: 'Slow',
                        subText: 'G-10 Markaz\n3 zones',
                        badgeText: 'Congested',
                        badgeColor: const Color(0xFFF57C00),
                      ),
                      const SizedBox(width: 12),
                      _buildSignalCol(
                        icon: Icons.article_outlined,
                        title: 'News / Reports',
                        bigText: '12 New',
                        subText: 'Resident report waterlogging in multiple areas',
                        actionText: 'View all',
                        onActionTap: () => context.go('/reports'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Primary Crisis Card (Lower Red Card) ──────────────────────
                GestureDetector(
                  onTap: () => context.go('/home/crisis-detail', extra: crisis),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7F7), // Soft red background tint
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFEE2E2), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Red hazard target icon
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.crisis_alert_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PRIMARY CRISIS',
                                    style: TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Margalla Town – Sector F-7',
                                    style: TextStyle(
                                      color: titleColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFEF4444)),
                                  ),
                                  child: const Text(
                                    'HIGH',
                                    style: TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: subtitleColor,
                                  size: 18,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Flash flooding reported on main boulevard and underpass.',
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 13.5,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Tags row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniTag(Icons.location_on_outlined, '2.4 km away'),
                            _buildMiniTag(Icons.access_time_rounded, 'Updated 10m ago'),
                            _buildMiniTag(Icons.assignment_outlined, 'Reports 18'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFFEE2E2), height: 1, thickness: 1),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_user_outlined,
                              color: titleColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'View Details',
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: titleColor,
                              size: 18,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Quick Actions Section ──────────────────────────────────────
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start, // Top-align action box squares
                  children: [
                    _buildQuickAction(
                      icon: Icons.warning_amber_rounded,
                      label: 'Report Crisis',
                      color: const Color(0xFFEF4444),
                      bg: const Color(0xFFFFF0F0),
                      onTap: () => context.go('/reports'),
                    ),
                    _buildQuickAction(
                      icon: Icons.phone_in_talk_rounded,
                      label: 'Emergency\nContacts',
                      color: brandColor,
                      bg: const Color(0xFFEEF2FF),
                      onTap: () => _showEmergencyContacts(context),
                    ),
                    _buildQuickAction(
                      icon: Icons.health_and_safety_rounded,
                      label: 'Safety Tips',
                      color: const Color(0xFF10B981),
                      bg: const Color(0xFFECFDF5),
                      onTap: () => _showSafetyTips(context),
                    ),
                    _buildQuickAction(
                      icon: Icons.home_work_outlined,
                      label: 'Shelters',
                      color: const Color(0xFF8B5CF6),
                      bg: const Color(0xFFF5F3FF),
                      onTap: () => _showShelters(context),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ── Section 1: System Infrastructure Monitor ───────────────────
                Row(
                  children: [
                    const Text(
                      'Infrastructure Monitor',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Flashing LIVE indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.fiber_manual_record_rounded, color: Color(0xFF22C55E), size: 8),
                          SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(color: Color(0xFF15803D), fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildInfraMonitorItem(
                      icon: Icons.flash_on_rounded,
                      title: 'Power Grid',
                      value: '78%',
                      percentage: 0.78,
                      color: const Color(0xFFF59E0B),
                      status: 'Fluctuating',
                    ),
                    const SizedBox(width: 10),
                    _buildInfraMonitorItem(
                      icon: Icons.water_damage_rounded,
                      title: 'Drainage Flow',
                      value: '92%',
                      percentage: 0.92,
                      color: const Color(0xFFEF4444),
                      status: 'Critical Surge',
                    ),
                    const SizedBox(width: 10),
                    _buildInfraMonitorItem(
                      icon: Icons.directions_car_rounded,
                      title: 'Road Safety',
                      value: '64%',
                      percentage: 0.64,
                      color: const Color(0xFF3B82F6),
                      status: 'Moderate Alert',
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ── Section 2: Active Citizen Signal Stream ─────────────────────
                Row(
                  children: [
                    const Text(
                      'Active Signal Stream',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.radar_rounded, color: Color(0xFF4F46E5), size: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildSignalStreamItem(
                  user: 'Ahmed Ali',
                  handle: '@im_ahmed',
                  text: 'G-10 Markaz mein pani gaariyon ke adhe tyre tak aa chuka hai! Road block ho chuki hai, please avoid double road.',
                  tag: 'Social Post',
                  severity: 'HIGH',
                  time: '3m ago',
                  severityColor: const Color(0xFFF57C00),
                ),
                const SizedBox(height: 12),
                _buildSignalStreamItem(
                  user: 'ISB Weather Watch',
                  handle: '@isb_weather',
                  text: 'Heavy rain cell moving south-west towards Sector I-12 and Highway. Waterlogging expected in low-lying underpasses.',
                  tag: 'Official Alert',
                  severity: 'CRITICAL',
                  time: '12m ago',
                  severityColor: const Color(0xFFD32F2F),
                ),
                const SizedBox(height: 12),
                _buildSignalStreamItem(
                  user: 'Rescue Radar',
                  handle: '@rescue_radar',
                  text: 'Minor collision near Zero Point underpass. Two vehicles blocked the left lane, traffic is piling up rapidly.',
                  tag: 'Traffic Sensor',
                  severity: 'MODERATE',
                  time: '18m ago',
                  severityColor: const Color(0xFFFBC02D),
                ),

                const SizedBox(height: 48), // Padding to clear bottom navigation
              ],
            ),
          ),
        );
      },
    );
  }

  // ── 3 Column Signal Item Widget ──────────────────────────────────────────
  Widget _buildSignalCol({
    required IconData icon,
    required String title,
    required String bigText,
    required String subText,
    String? badgeText,
    Color? badgeColor,
    String? actionText,
    VoidCallback? onActionTap,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + Label
            Row(
              children: [
                Icon(icon, size: 14, color: const Color(0xFF4F46E5)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              bigText,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subText,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10.5,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            if (badgeText != null && badgeColor != null)
              Row(
                children: [
                  Icon(Icons.arrow_upward_rounded, size: 11, color: badgeColor),
                  const SizedBox(width: 2),
                  Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            if (actionText != null)
              GestureDetector(
                onTap: onActionTap,
                child: Text(
                  actionText,
                  style: const TextStyle(
                    color: Color(0xFF4F46E5),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTag(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 28, // Guarantees both 1-line and 2-line labels occupy the exact same height
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String phone,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.phone_rounded, color: Color(0xFF4F46E5), size: 14),
              const SizedBox(width: 4),
              Text(
                phone,
                style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(String num, String heading, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFFEEF2FF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                heading,
                style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShelterItem(String name, String details, String distance, String status) {
    final active = status.toLowerCase() == 'active';
    return Row(
      children: [
        const Icon(Icons.home_work_rounded, color: Color(0xFF8B5CF6), size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                details,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              distance,
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 12.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: active ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: active ? const Color(0xFF10B981) : const Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfraMonitorItem({
    required IconData icon,
    required String title,
    required String value,
    required double percentage,
    required Color color,
    required String status,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  value: percentage,
                  color: color,
                  backgroundColor: const Color(0xFFF1F5F9),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalStreamItem({
    required String user,
    required String handle,
    required String text,
    required String tag,
    required String severity,
    required String time,
    required Color severityColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // User Avatar
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEF2FF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.substring(0, 1),
                    style: const TextStyle(
                      color: Color(0xFF4F46E5),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF3B82F6),
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      handle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Tag Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Severity Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  severity,
                  style: TextStyle(
                    color: severityColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
