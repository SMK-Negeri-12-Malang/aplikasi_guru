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
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> notifications = await getNotifications();
    notifications.add(notification);
    await prefs.setString(_notificationsKey, json.encode(notifications));
  }

  Future<void> removeNotification(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> notifications = await getNotifications();
    
    if (index >= 0 && index < notifications.length) {
      notifications.removeAt(index);
      await prefs.setString(_notificationsKey, json.encode(notifications));
    }
  }

  Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);
  }
}
