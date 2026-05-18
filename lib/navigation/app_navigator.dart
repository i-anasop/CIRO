// CIRO — App Navigator v3
// Premium floating bottom navigation bar with active pill highlight.
// All routes preserved. Only the nav bar visual is updated.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/location_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/crisis_detail_screen.dart';
import '../screens/response_plan_screen.dart';
import '../screens/simulation_screen.dart';
import '../screens/agent_logs_screen.dart';
import '../screens/map_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/demo_scenarios_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';
import '../models/crisis.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Splash ──────────────────────────────────────────────────────────────
    GoRoute(
      path: '/',
      builder: (_, __) => const SplashScreen(),
    ),

    // ── Location ────────────────────────────────────────────────────────────
    GoRoute(
      path: '/location',
      builder: (_, __) => const LocationScreen(),
    ),

    // ── Notifications ───────────────────────────────────────────────────────
    GoRoute(
      path: '/notifications',
      builder: (_, __) => const NotificationsScreen(),
    ),

    // ── Profile ─────────────────────────────────────────────────────────────
    GoRoute(
      path: '/profile',
      builder: (_, __) => const ProfileScreen(),
    ),

    // ── Main shell with bottom navigation ────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => _MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const DashboardScreen(),
          routes: [
            GoRoute(
              path: 'crisis-detail',
              builder: (context, state) {
                final crisis = state.extra as Crisis;
                return CrisisDetailScreen(crisis: crisis);
              },
            ),
            GoRoute(
              path: 'response-plan',
              builder: (context, state) {
                final crisis = state.extra as Crisis;
                return ResponsePlanScreen(crisis: crisis);
              },
            ),
            GoRoute(
              path: 'simulation',
              builder: (context, state) {
                final crisis = state.extra as Crisis;
                return SimulationScreen(crisis: crisis);
              },
            ),
            GoRoute(
              path: 'demo-scenarios',
              builder: (_, __) => const DemoScenariosScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/map',
          builder: (_, __) => const MapScreen(),
        ),
        GoRoute(
          path: '/reports',
          builder: (_, __) => const ReportsScreen(),
        ),
        GoRoute(
          path: '/logs',
          builder: (_, __) => const AgentLogsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, __) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);

// ── Premium Floating Bottom Navigation Shell ──────────────────────────────────
class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  static const _tabs = [
    _TabItem(icon: Icons.home_outlined,     activeIcon: Icons.home_rounded,     label: 'Home',    path: '/home'),
    _TabItem(icon: Icons.map_outlined,      activeIcon: Icons.map_rounded,      label: 'Map',     path: '/map'),
    _TabItem(icon: Icons.add_rounded,       activeIcon: Icons.add_rounded,      label: 'Report',   path: '/reports'),
    _TabItem(icon: Icons.article_outlined,  activeIcon: Icons.article_rounded,  label: 'Logs',    path: '/logs'),
    _TabItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings', path: '/settings'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home'))     return 0;
    if (location.startsWith('/map'))      return 1;
    if (location.startsWith('/reports'))  return 2;
    if (location.startsWith('/logs'))     return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex(context);
    return Scaffold(
      backgroundColor: CiroColors.bg1,
      body: child,
      bottomNavigationBar: _PremiumNavBar(
        currentIndex: current,
        onTap: (i) => context.go(_tabs[i].path),
        tabs: _tabs,
      ),
    );
  }
}

/// Premium floating bottom nav bar with active pill highlight.
class _PremiumNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_TabItem> tabs;

  const _PremiumNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: tabs.asMap().entries.map((e) {
              final selected = currentIndex == e.key;
              final isCenter = e.key == 2; // Report button
              return _NavItem(
                item: e.value,
                selected: selected,
                isCenter: isCenter,
                onTap: () => onTap(e.key),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _TabItem item;
  final bool selected;
  final bool isCenter;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.selected,
    required this.isCenter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isCenter) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: CiroColors.brandAccent,
                shape: BoxShape.circle,
                boxShadow: CiroColors.glowCyan,
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: CiroTypography.labelSmall.copyWith(
                color: CiroColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              size: 24,
              color: selected ? CiroColors.brandAccent : CiroColors.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: CiroTypography.labelSmall.copyWith(
                color: selected ? CiroColors.brandAccent : CiroColors.textMuted,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });
}
