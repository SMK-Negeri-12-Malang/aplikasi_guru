import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class NotificationService {
  static const String _notificationsKey = 'notifications';

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notificationsStr = prefs.getString(_notificationsKey);
    if (notificationsStr != null) {
      final List<dynamic> decoded = json.decode(notificationsStr);
      return List<Map<String, dynamic>>.from(decoded);
    }
    return [];
  }

  Future<void> saveNotifications(List<Map<String, dynamic>> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final String notificationsJson = json.encode(notifications);
    await prefs.setString(_notificationsKey, notificationsJson);
  }

  Future<void> addNotification(Map<String, dynamic> notification) async {
    try {
      final notifications = await getNotifications();
      
      // Convert deadline string to DateTime for comparison
      final deadlineDate = DateFormat('yyyy-MM-dd').parse(notification['deadline']);
      final now = DateTime.now();
      final difference = deadlineDate.difference(now).inDays;

      // Check for existing notification with same taskId
      final existingIndex = notifications.indexWhere((n) => 
        n['taskId'] == notification['taskId'] && 
        n['deadline'] == notification['deadline']
      );
      
      // Only process if deadline is within 3 days or overdue within 1 day
      if (difference <= 3 && difference >= -1) {
        final updatedNotification = {
          ...notification,
          'deadlineDate': deadlineDate.toIso8601String(),
          'createdAt': DateTime.now().toIso8601String(),
          'daysLeft': difference,
          'notificationId': notification['taskId'] + '_' + notification['deadline'], // Add unique identifier
        };

        if (existingIndex != -1) {
          // Skip if notification already exists
          return;
        } else {
          // Add new notification only if it doesn't exist
          notifications.add(updatedNotification);
          await saveNotifications(notifications);
          print('New notification added: ${notification['taskName']} - Deadline: ${notification['deadline']}');
        }
      }
    } catch (e) {
      print('Error adding notification: $e');
    }
  }

  Future<void> updateNotification(String taskId, Map<String, dynamic> updates) async {
    final notifications = await getNotifications();
    final index = notifications.indexWhere((n) => n['taskId'] == taskId);
    
    if (index != -1) {
      if (updates['isCompleted'] == true) {
        notifications.removeAt(index);
      } else {
        notifications[index] = {...notifications[index], ...updates};
      }
      await saveNotifications(notifications);
    }
  }

  Future<void> removeNotification(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> notifications = await getNotifications();
    if (index >= 0 && index < notifications.length) {
      notifications.removeAt(index);
      await prefs.setString(_notificationsKey, json.encode(notifications));
    }
  }

  Future<List<Map<String, dynamic>>> getActiveNotifications() async {
    try {
      final notifications = await getNotifications();
      final now = DateTime.now();
      
      // Use a map to ensure uniqueness based on taskId and deadline combination
      final Map<String, Map<String, dynamic>> uniqueNotifications = {};
      
      for (var notification in notifications) {
        if (notification['deadline'] == null || notification['taskId'] == null) continue;
        
        final deadlineDate = DateFormat('yyyy-MM-dd').parse(notification['deadline']);
        final difference = deadlineDate.difference(now).inDays;
        
        if (difference <= 3 && difference >= -1 && !notification['isCompleted']) {
          // Create unique key combining taskId and deadline
          final uniqueKey = '${notification['taskId']}_${notification['deadline']}';
          
          // Only keep if not already present
          if (!uniqueNotifications.containsKey(uniqueKey)) {
            uniqueNotifications[uniqueKey] = notification;
          }
        }
      }
      
      return uniqueNotifications.values.toList();
    } catch (e) {
      print('Error getting active notifications: $e');
      return [];
    }
  }

  bool isDeadlineNear(String deadline) {
    try {
      final now = DateTime.now();
      final deadlineDate = DateFormat('yyyy-MM-dd').parse(deadline);
      final difference = deadlineDate.difference(now).inDays;
      
      // Consider deadline near if it's within next 3 days or overdue within last day
      return difference <= 3 && difference >= -1;
    } catch (e) {
      print('Error checking deadline: $e');
      return false;
    }
  }

  deleteNotification(String taskId) {}
}
