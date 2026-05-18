// CIRO — Notifications Screen v6
// High-fidelity, premium notifications feed matching the user's uploaded mockup design exactly.
// Features unified layout, Left edge vertical colored urgency stripes, custom categories with dot alerts,
// clock-timed PKT sub-rows, custom back chevron, and interactive expand/collapse animation cards.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Track expanded notification items for details dropdown
  final Set<String> _expandedIds = {};

  // Extract color, bg color, label, and icon dynamically per category matching screenshot
  Map<String, dynamic> _getAlertProps(String title) {
    final t = title.toLowerCase();
    if (t.contains('heavy') || t.contains('rainfall') || t.contains('critical') || t.contains('red')) {
      return {
        'color': const Color(0xFFEF4444), // Critical Red
        'bgColor': const Color(0xFFFEE2E2),
        'label': 'CRITICAL',
        'icon': Icons.thunderstorm_rounded,
      };
    } else if (t.contains('traffic') || t.contains('congestion') || t.contains('high') || t.contains('orange')) {
      return {
        'color': const Color(0xFFF97316), // High Orange
        'bgColor': const Color(0xFFFFEDD5),
        'label': 'HIGH',
        'icon': Icons.directions_car_outlined,
      };
    } else {
      return {
        'color': const Color(0xFF3B82F6), // Verified/Info Blue
        'bgColor': const Color(0xFFDBEAFE),
        'label': 'VERIFIED',
        'icon': Icons.home_work_outlined,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF0F172A);
    const subtitleColor = Color(0xFF64748B);
    const scaffoldBgColor = Color(0xFFF8FAFC);

    return ListenableBuilder(
      listenable: NotificationService.instance,
      builder: (context, _) {
        final service = NotificationService.instance;
        final list = service.notifications;
        final unreadCount = service.unreadCount;

        return Scaffold(
          backgroundColor: scaffoldBgColor,
          appBar: AppBar(
            backgroundColor: scaffoldBgColor,
            elevation: 0,
            leadingWidth: 70,
            leading: Padding(
              padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: Color(0xFF0F172A),
                    size: 24,
                  ),
                ),
              ),
            ),
            title: const Text(
              'Notifications',
              style: TextStyle(
                color: titleColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                // ── 1. SYSTEM ALERTS HUB TOP CARD ─────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Bell Icon Container
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEEF2FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: Color(0xFF4F46E5),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Text Description Row
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'SYSTEM ALERTS HUB',
                              style: TextStyle(
                                color: Color(0xFF4F46E5),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${list.length} Alerts Logged',
                                  style: const TextStyle(
                                    color: titleColor,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (unreadCount > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$unreadCount Unread',
                                      style: const TextStyle(
                                        color: Color(0xFFEF4444),
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Mark All Read Button
                      if (unreadCount > 0)
                        OutlinedButton(
                          onPressed: () {
                            service.markAllAsRead();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✨ All notifications marked as read'),
                                backgroundColor: Color(0xFF4F46E5),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_rounded, color: Color(0xFF4F46E5), size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Mark all read',
                                style: TextStyle(
                                  color: Color(0xFF4F46E5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── 2. SYSTEM ALERTS FEED ─────────────────────────────────────
                if (list.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 80.0),
                      child: Column(
                        children: [
                          Icon(Icons.notifications_off_outlined,
                              color: subtitleColor.withValues(alpha: 0.3), size: 48),
                          const SizedBox(height: 16),
                          const Text(
                            'No Alerts Available',
                            style: TextStyle(color: subtitleColor, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...list.map((item) {
                    final id = item['id'];
                    final isRead = item['isRead'];
                    final isExpanded = _expandedIds.contains(id);
                    final props = _getAlertProps(item['title']);

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              // Left solid vertical category accent bar
                              Container(
                                width: 5.5,
                                color: props['color'],
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    // Mark alert as read on click
                                    service.markAsRead(id);

                                    // Toggle expansion to read details inline
                                    setState(() {
                                      if (isExpanded) {
                                        _expandedIds.remove(id);
                                      } else {
                                        _expandedIds.add(id);
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header Row matching mockup exactly
                                        Row(
                                          children: [
                                            // Circular colored background icon container
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: props['bgColor'],
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                props['icon'],
                                                color: props['color'],
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            // Content Column
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Category dot and tag row
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 6,
                                                        height: 6,
                                                        decoration: BoxDecoration(
                                                          color: props['color'],
                                                          shape: BoxShape.circle,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        props['label'],
                                                        style: TextStyle(
                                                          color: props['color'],
                                                          fontSize: 9.5,
                                                          fontWeight: FontWeight.w900,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  // Notification Title
                                                  Text(
                                                    item['title'],
                                                    style: TextStyle(
                                                      color: isRead ? subtitleColor : titleColor,
                                                      fontSize: 14.5,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  // Clock icon and PKT timestamp row
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.access_time_rounded,
                                                        color: Color(0xFF94A3B8),
                                                        size: 13,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        item['time'],
                                                        style: const TextStyle(
                                                          color: Color(0xFF94A3B8),
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Right Chevron Arrow
                                            Icon(
                                              Icons.chevron_right_rounded,
                                              color: const Color(0xFF94A3B8),
                                              size: 24,
                                              key: ValueKey('chevron_$id'),
                                            ),
                                          ],
                                        ),

                                        // Collapsible inline details panel
                                        AnimatedCrossFade(
                                          firstChild: const SizedBox(height: 0),
                                          secondChild: Padding(
                                            padding: const EdgeInsets.only(top: 14.0),
                                            child: Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF8FAFC),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                              ),
                                              child: Text(
                                                item['details'],
                                                style: const TextStyle(
                                                  color: titleColor,
                                                  fontSize: 12.5,
                                                  height: 1.45,
                                                ),
                                              ),
                                            ),
                                          ),
                                          crossFadeState: isExpanded
                                              ? CrossFadeState.showSecond
                                              : CrossFadeState.showFirst,
                                          duration: const Duration(milliseconds: 200),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}
