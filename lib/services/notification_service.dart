import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _systemNotificationsReady = false;

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'ciro_alerts',
        'CIRO Alerts',
        description: 'Crisis intelligence alerts and operational updates.',
        importance: Importance.high,
      );

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'welcome-ciro',
      'title': 'Welcome to CIRO',
      'details':
          'Your crisis command center is ready. CIRO will place important local alerts, verification updates, and response notices here.',
      'time': 'Now',
      'isRead': false,
    },
    {
      'id': 'complete-profile',
      'title': 'Complete Your Profile',
      'details':
          'Add your name and profile picture so crisis reports and comments show your identity clearly.',
      'time': 'Now',
      'isRead': false,
    },
  ];

  List<Map<String, dynamic>> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n['isRead']).length;

  bool hasNotification(String id) => _notifications.any((n) => n['id'] == id);

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1 && !_notifications[index]['isRead']) {
      _notifications[index]['isRead'] = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n['isRead'] = true;
    }
    notifyListeners();
  }

  Future<void> initialize() async {
    if (kIsWeb || _systemNotificationsReady) return;

    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    _systemNotificationsReady = true;
  }

  /// Request local notification permissions.
  Future<void> requestPermissions() async {
    if (kIsWeb) {
      return;
    }

    await initialize();

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Append a new alert message to the reactive system alerts hub list.
  void addNotification({
    required String title,
    required String details,
    bool showSystem = false,
  }) {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$min PKT';

    _notifications.insert(0, {
      'id': now.millisecondsSinceEpoch.toString(),
      'title': title,
      'details': details,
      'time': timeStr,
      'isRead': false,
    });
    notifyListeners();
    if (showSystem) {
      _showSystemNotification(
        id: now.millisecondsSinceEpoch.remainder(2147483647),
        title: title,
        details: details,
      );
    }
  }

  void addNotificationWithId({
    required String id,
    required String title,
    required String details,
    bool showSystem = false,
  }) {
    if (hasNotification(id)) return;
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$min PKT';

    _notifications.insert(0, {
      'id': id,
      'title': title,
      'details': details,
      'time': timeStr,
      'isRead': false,
    });
    notifyListeners();
    if (showSystem) {
      _showSystemNotification(
        id: id.hashCode.abs().remainder(2147483647),
        title: title,
        details: details,
      );
    }
  }

  Future<void> _showSystemNotification({
    required int id,
    required String title,
    required String details,
  }) async {
    if (kIsWeb) return;
    await initialize();

    await _plugin.show(
      id: id,
      title: title,
      body: details,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'ciro_alerts',
          'CIRO Alerts',
          channelDescription:
              'Crisis intelligence alerts and operational updates.',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'CIRO alert',
          icon: '@mipmap/launcher_icon',
          category: AndroidNotificationCategory.alarm,
          styleInformation: BigTextStyleInformation(details),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
