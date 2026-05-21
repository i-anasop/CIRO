// CIRO - Notifications Screen
// Clean grouped notification feed inspired by the provided reference.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _unreadOnly = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NotificationService.instance,
      builder: (context, _) {
        final service = NotificationService.instance;
        final today = service.notifications
            .where((n) => !_unreadOnly || n['isRead'] == false)
            .toList();
        final yesterday = _demoYesterdayNotifications
            .where((n) => !_unreadOnly || n['isRead'] == false)
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8FAFC),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF101828),
                size: 25,
              ),
            ),
            title: const Text(
              'Notifications',
              style: TextStyle(
                color: Color(0xFF101828),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
              physics: const BouncingScrollPhysics(),
              children: [
                Row(
                  children: [
                    _FilterPill(
                      label: 'All',
                      selected: !_unreadOnly,
                      onTap: () => setState(() => _unreadOnly = false),
                    ),
                    const SizedBox(width: 12),
                    _FilterPill(
                      label: 'Unread',
                      selected: _unreadOnly,
                      onTap: () => setState(() => _unreadOnly = true),
                    ),
                    const Spacer(),
                    _MarkReadButton(
                      enabled: service.unreadCount > 0,
                      onTap: service.markAllAsRead,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                if (today.isNotEmpty) ...[
                  const _SectionTitle('Today'),
                  const SizedBox(height: 12),
                  ...today.map(
                    (item) => _NotificationCard(
                      item: item,
                      onTap: () => service.markAsRead(item['id']),
                    ),
                  ),
                ],
                if (yesterday.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const _SectionTitle('Yesterday'),
                  const SizedBox(height: 12),
                  ...yesterday.map(
                    (item) => _NotificationCard(item: item, onTap: () {}),
                  ),
                ],
                if (today.isEmpty && yesterday.isEmpty) const _EmptyState(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 17),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF5A5CE5) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF5A5CE5).withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF1F2937),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _MarkReadButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _MarkReadButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: enabled ? 1 : 0.55,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Mark all as read',
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF101828),
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _NotificationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final props = _props(item['title']);
    final isRead = item['isRead'] == true;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isRead
                ? const Color(0xFFE5E7EB)
                : props.color.withValues(alpha: 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF101828).withValues(alpha: 0.045),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: props.bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: props.color.withValues(alpha: 0.16)),
              ),
              child: Icon(props.icon, color: props.color, size: 23),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                _friendlyTitle(item['title']),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isRead
                                      ? const Color(0xFF475467)
                                      : const Color(0xFF101828),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            if (!isRead) ...[
                              const SizedBox(width: 5),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: props.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _friendlyTime(item['time']),
                            style: const TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (!isRead) ...[
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: props.color.withValues(alpha: 0.09),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'New',
                                style: TextStyle(
                                  color: props.color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _friendlyDetails(item['details']),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF344054),
                      fontSize: 11.5,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 90),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF5A5CE5),
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No notifications here',
            style: TextStyle(
              color: Color(0xFF101828),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationProps {
  final IconData icon;
  final Color color;
  final Color bg;

  const _NotificationProps({
    required this.icon,
    required this.color,
    required this.bg,
  });
}

_NotificationProps _props(String title) {
  final t = title.toLowerCase();
  if (t.contains('welcome')) {
    return const _NotificationProps(
      icon: Icons.waving_hand_rounded,
      color: Color(0xFF5A5CE5),
      bg: Color(0xFFF0EFFE),
    );
  }
  if (t.contains('profile')) {
    return const _NotificationProps(
      icon: Icons.account_circle_rounded,
      color: Color(0xFF2563EB),
      bg: Color(0xFFEFF6FF),
    );
  }
  if (t.contains('safety') || t.contains('guidance')) {
    return const _NotificationProps(
      icon: Icons.health_and_safety_rounded,
      color: Color(0xFF059669),
      bg: Color(0xFFECFDF5),
    );
  }
  if (t.contains('heat')) {
    return const _NotificationProps(
      icon: Icons.thermostat_rounded,
      color: Color(0xFFDC2626),
      bg: Color(0xFFFFF1F2),
    );
  }
  if (t.contains('rain') || t.contains('flood') || t.contains('critical')) {
    return const _NotificationProps(
      icon: Icons.flood_rounded,
      color: Color(0xFF2563EB),
      bg: Color(0xFFEFF6FF),
    );
  }
  if (t.contains('traffic') ||
      t.contains('congestion') ||
      t.contains('blockage') ||
      t.contains('route')) {
    return const _NotificationProps(
      icon: Icons.traffic_rounded,
      color: Color(0xFF5A5CE5),
      bg: Color(0xFFF0EFFE),
    );
  }
  if (t.contains('verified') ||
      t.contains('confirmed') ||
      t.contains('verification')) {
    return const _NotificationProps(
      icon: Icons.verified_rounded,
      color: Color(0xFF059669),
      bg: Color(0xFFECFDF5),
    );
  }
  if (t.contains('demo') || t.contains('location')) {
    return const _NotificationProps(
      icon: Icons.map_rounded,
      color: Color(0xFF5A5CE5),
      bg: Color(0xFFF0EFFE),
    );
  }
  return const _NotificationProps(
    icon: Icons.assignment_turned_in_outlined,
    color: Color(0xFF2563EB),
    bg: Color(0xFFEAF2FF),
  );
}

String _friendlyTitle(String title) {
  final t = title.toLowerCase();
  if (t.contains('welcome')) return 'Welcome to CIRO';
  if (t.contains('profile')) return 'Complete Your Profile';
  if (t.contains('safety')) return 'Safety Tips Ready';
  if (t.contains('heat')) return 'Heat Risk Alert';
  if (t.contains('rain')) return 'Flood Watch Ready';
  if (t.contains('traffic')) return 'Route Marked as High Priority';
  if (t.contains('verified incident')) return 'Incident Verified';
  if (t.contains('confirmed')) return 'Crisis Verified';
  if (t.contains('urban flooding')) return 'Incident Verified';
  if (t.contains('real mode')) return 'Live Monitoring Started';
  if (t.contains('demo mode')) return 'Demo Location Active';
  if (t.contains('demo update')) return 'Crisis Update Ready';
  return title;
}

String _friendlyDetails(String details) {
  return details
      .replaceAll('Weather Agent', 'Weather check')
      .replaceAll('Traffic Agent', 'Traffic check')
      .replaceAll('Social Post corroboration', 'Citizen report match')
      .trim();
}

String _friendlyTime(String time) {
  if (time.contains('14:32')) return '15 sec ago';
  if (time.contains('14:28')) return '5 mins ago';
  if (time.contains('14:15')) return '6 mins ago';
  if (time.contains('PKT')) return 'just now';
  return time;
}

final List<Map<String, dynamic>> _demoYesterdayNotifications = [
  {
    'id': 'y1',
    'title': 'Safety Tips Ready',
    'details':
        'Flood, heat, traffic, outage, and accident guidance is available from Quick Actions.',
    'time': '1 day ago',
    'isRead': true,
  },
];
