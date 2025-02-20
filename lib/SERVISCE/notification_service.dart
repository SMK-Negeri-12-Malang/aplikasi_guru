import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationService {
  static const String _notificationsKey = 'notifications';

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString(_notificationsKey);
    if (notificationsJson == null) return [];
    
    List<dynamic> decodedList = json.decode(notificationsJson);
    return decodedList.cast<Map<String, dynamic>>();
  }

  Future<void> saveNotifications(List<Map<String, dynamic>> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final String notificationsJson = json.encode(notifications);
    await prefs.setString(_notificationsKey, notificationsJson);
  }

  Future<void> addNotification(Map<String, dynamic> notification) async {
    final notifications = await getNotifications();
    // Check if notification already exists
    bool exists = notifications.any((n) => 
        n['taskName'] == notification['taskName'] && 
        n['className'] == notification['className']);
    
    if (!exists) {
      notifications.add(notification);
      await saveNotifications(notifications);
    }
  }

  Future<void> removeNotification(int index) async {
    final notifications = await getNotifications();
    if (index >= 0 && index < notifications.length) {
      notifications.removeAt(index);
      await saveNotifications(notifications);
    }
  }
}
