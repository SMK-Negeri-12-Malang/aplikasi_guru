import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskStorage {
  static const String _tasksKey = 'tasks_data';

  static Future<void> saveTasks(Map<String, List<Map<String, dynamic>>> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedTasks = json.encode(tasks.map((key, value) {
      return MapEntry(
        key,
        value.map((task) {
          // Create a copy of the task without File and Image objects
          final storedTask = Map<String, dynamic>.from(task);
          if (storedTask.containsKey('image')) {
            storedTask['image'] = task['image']?.path;
          }
          if (storedTask.containsKey('file')) {
            storedTask['file'] = {
              'path': task['file']?.path,
              'name': task['file']?.name,
              'size': task['file']?.size,
            };
          }
          return storedTask;
        }).toList(),
      );
    }));
    await prefs.setString(_tasksKey, encodedTasks);
  }

  static Future<Map<String, List<Map<String, dynamic>>>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString(_tasksKey);
    if (tasksString == null) return {};

    final Map<String, dynamic> decodedTasks = json.decode(tasksString);
    return decodedTasks.map((key, value) {
      return MapEntry(
        key,
        (value as List).map<Map<String, dynamic>>((task) {
          final Map<String, dynamic> restoredTask = Map<String, dynamic>.from(task);
          // Restore File and Image objects if paths exist
          if (restoredTask.containsKey('image') && restoredTask['image'] != null) {
            restoredTask['image'] = File(restoredTask['image']);
          }
          if (restoredTask.containsKey('file') && restoredTask['file'] != null) {
            restoredTask['file'] = PlatformFile(
              path: restoredTask['file']['path'],
              name: restoredTask['file']['name'],
              size: restoredTask['file']['size'],
            );
          }
          return restoredTask;
        }).toList(),
      );
    });
  }

  static Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
  }
}
