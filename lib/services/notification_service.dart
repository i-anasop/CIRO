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
      'id': '1',
      'title': 'Heavy Rainfall Alert (Islamabad)',
      'details': 'Red Category alert issued by Weather Agent. Expected drainage capacity peak at G-10 Markaz within 30 minutes. Emergency pumps dispatched.',
      'time': '14:32 PKT',
      'isRead': false,
    },
    {
      'id': '2',
      'title': 'Traffic Congestion Spike (G-10)',
      'details': 'Traffic Agent detected 85% route blockage near double road intersection. Traffic rerouted via alternate I-8 sector highway link.',
      'time': '14:28 PKT',
      'isRead': false,
    },
    {
      'id': '3',
      'title': 'Verified Incident: Urban Flooding',
      'details': 'Social Post corroboration received from Islamabad citizen report: "G-10 mein paani bhar gaya hai, gaariyan phans gayi hain". Onset confirmed.',
      'time': '14:15 PKT',
      'isRead': false,
    },
  ];

  List<Map<String, dynamic>> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n['isRead']).length;

  bool hasNotification(String id) =>
      _notifications.any((n) => n['id'] == id);

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
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    _systemNotificationsReady = true;
  }

  /// Request local notification permissions.
  Future<void> requestPermissions() async {
    if (kIsWeb) {
      debugPrint('CIRO system notifications are not available on web builds.');
      return;
    }

    await initialize();

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Append a new alert message to the reactive system alerts hub list.
  void addNotification({required String title, required String details}) {
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
    _showSystemNotification(
      id: now.millisecondsSinceEpoch.remainder(2147483647),
      title: title,
      details: details,
    );
  }

  void addNotificationWithId({
    required String id,
    required String title,
    required String details,
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
    _showSystemNotification(
      id: id.hashCode.abs().remainder(2147483647),
      title: title,
      details: details,
    );
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
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'ciro_alerts',
          'CIRO Alerts',
          channelDescription:
              'Crisis intelligence alerts and operational updates.',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'CIRO alert',
          icon: '@mipmap/launcher_icon',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
