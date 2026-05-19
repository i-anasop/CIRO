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
              onPressed: () => context.pop(),
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
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF101828).withValues(alpha: 0.025),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: props.bg,
                shape: BoxShape.circle,
              ),
              child: Icon(props.icon, color: props.color, size: 24),
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
                      Text(
                        _friendlyTime(item['time']),
                        style: const TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
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
  if (t.contains('rain') || t.contains('flood') || t.contains('critical')) {
    return const _NotificationProps(
      icon: Icons.water_drop_outlined,
      color: Color(0xFF2563EB),
      bg: Color(0xFFEFF6FF),
    );
  }
  if (t.contains('traffic') || t.contains('congestion') || t.contains('high')) {
    return const _NotificationProps(
      icon: Icons.flag_outlined,
      color: Color(0xFF5A5CE5),
      bg: Color(0xFFF0EFFE),
    );
  }
  if (t.contains('payment') || t.contains('required')) {
    return const _NotificationProps(
      icon: Icons.credit_card_rounded,
      color: Color(0xFF2563EB),
      bg: Color(0xFFEFF6FF),
    );
  }
  if (t.contains('otp') || t.contains('verification')) {
    return const _NotificationProps(
      icon: Icons.lock_outline_rounded,
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
  if (t.contains('rain')) return 'Flood Watch Ready';
  if (t.contains('traffic')) return 'Route Marked as High Priority';
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
      .replaceAll('CIRO', 'Ciro')
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
    'title': 'Welcome to CIRO',
    'details': 'Start by choosing demo G-10 or live location monitoring.',
    'time': '1 day ago',
    'isRead': true,
  },
  {
    'id': 'y2',
    'title': 'OTP Verification Successful',
    'details':
        'Your account has been successfully verified. You can now access the platform.',
    'time': '1 day ago',
    'isRead': true,
  },
];
