import 'package:flutter/material.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

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
}
