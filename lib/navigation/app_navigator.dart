// CIRO — App Navigator v3
// Premium floating bottom navigation bar with active pill highlight.
// All routes preserved. Only the nav bar visual is updated.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/location_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/crisis_detail_screen.dart';
import '../screens/response_plan_screen.dart';
import '../screens/agent_logs_screen.dart';
import '../screens/map_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/demo_scenarios_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';
import '../models/crisis.dart';
import '../services/scenario_engine.dart';
import '../theme/colors.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Splash ──────────────────────────────────────────────────────────────
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),

    // ── Login ───────────────────────────────────────────────────────────────
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),

    // ── Location ────────────────────────────────────────────────────────────
    GoRoute(path: '/location', builder: (_, __) => const LocationScreen()),

    // ── Notifications ───────────────────────────────────────────────────────
    GoRoute(
      path: '/notifications',
      builder: (_, __) => const NotificationsScreen(),
    ),

    // ── Profile ─────────────────────────────────────────────────────────────
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),

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
                final crisis =
                    (state.extra as Crisis?) ??
                    ScenarioEngine.instance.activeCrisis;
                return CrisisDetailScreen(crisis: crisis);
              },
            ),
            GoRoute(
              path: 'response-plan',
              builder: (context, state) {
                final crisis =
                    (state.extra as Crisis?) ??
                    ScenarioEngine.instance.activeCrisis;
                return ResponsePlanScreen(crisis: crisis, initialTab: 0);
              },
            ),
            GoRoute(
              path: 'simulation',
              builder: (context, state) {
                final crisis =
                    (state.extra as Crisis?) ??
                    ScenarioEngine.instance.activeCrisis;
                return ResponsePlanScreen(crisis: crisis, initialTab: 1);
              },
            ),
            GoRoute(
              path: 'demo-scenarios',
              builder: (_, __) => const DemoScenariosScreen(),
            ),
          ],
        ),
        GoRoute(path: '/map', builder: (_, __) => const MapScreen()),
        GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
        GoRoute(path: '/logs', builder: (_, __) => const AgentLogsScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      ],
    ),
  ],
);

// ── Premium Floating Bottom Navigation Shell ──────────────────────────────────
class _MainShell extends StatefulWidget {
  final Widget child;
  const _MainShell({required this.child});

  static const _tabs = [
    _TabItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      path: '/home',
    ),
    _TabItem(
      icon: Icons.map_outlined,
      activeIcon: Icons.map_rounded,
      label: 'Map',
      path: '/map',
    ),
    _TabItem(
      icon: Icons.forum_outlined,
      activeIcon: Icons.forum_rounded,
      label: 'Feed',
      path: '/reports',
    ),
    _TabItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
      path: '/settings',
    ),
  ];

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  DateTime? _lastPressedAt;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/map')) return 1;
    if (location.startsWith('/reports')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex(context);
    final router = GoRouter.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // 1. If GoRouter has nested screens to pop (like crisis-detail), let it pop.
        if (router.canPop()) {
          router.pop();
          return;
        }

        // 2. If we are on a different tab (not Home), navigate back to Home.
        final location = GoRouterState.of(context).uri.toString();
        if (location != '/home') {
          router.go('/home');
          return;
        }

        // 3. We are on the Home tab. Double press back to exit the app.
        final now = DateTime.now();
        if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        // Exit the app
        await SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: CiroColors.bg1,
        extendBody: true,
        body: widget.child,
        bottomNavigationBar: _PremiumNavBar(
          currentIndex: current,
          onTap: (i) => context.go(_MainShell._tabs[i].path),
          tabs: _MainShell._tabs,
        ),
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
      color: Colors.transparent,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 12,
        top: 8,
      ),
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: tabs.asMap().entries.map((e) {
            final selected = currentIndex == e.key;
            return _NavItem(
              item: e.value,
              selected: selected,
              onTap: () => onTap(e.key),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _TabItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF4F46E5).withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          selected ? item.activeIcon : item.icon,
          size: 30, // Larger, more professional icons as requested
          color: selected ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
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
