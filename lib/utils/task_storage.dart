import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskStorage {
  static const String _storageKey = 'task_data';

  static Future<void> saveTasks(Map<String, List<Map<String, dynamic>>> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Convert File and PlatformFile objects to their paths
    final serializedTasks = tasks.map((className, taskList) {
      return MapEntry(
        className,
        taskList.map((task) {
          var serializedTask = Map<String, dynamic>.from(task);
          if (task['image'] != null) {
            serializedTask['image'] = task['image'].path;
          }
          if (task['file'] != null) {
            serializedTask['file'] = {
              'path': task['file'].path,
              'name': task['file'].name,
              'size': task['file'].size,
            };
          }
          return serializedTask;
        }).toList(),
      );
    });
    
    await prefs.setString(_storageKey, jsonEncode(serializedTasks));
  }

  static Future<Map<String, List<Map<String, dynamic>>>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null) {
      return {
        'Tugas': [],
        'Kamar B': [],
        'Kamar C': [],
        'Kamar D': [],
      };
    }

    final Map<String, dynamic> decoded = jsonDecode(jsonString);
    final Map<String, List<Map<String, dynamic>>> tasks = {};

    decoded.forEach((className, taskList) {
      tasks[className] = (taskList as List).map<Map<String, dynamic>>((task) {
        var deserializedTask = Map<String, dynamic>.from(task);
        if (task['image'] != null) {
          deserializedTask['image'] = File(task['image']);
        }
        if (task['file'] != null) {
          deserializedTask['file'] = PlatformFile(
            path: task['file']['path'],
            name: task['file']['name'],
            size: task['file']['size'],
          );
        }
        return deserializedTask;
      }).toList();
    });

    return tasks;
  }

  static Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
