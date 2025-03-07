import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TaskManagerService {
  // Change storage key to include class name
  String _getStorageKey(String className) => 'tasks_$className';

  Future<List<Map<String, dynamic>>> getTasksForClass(String className) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_getStorageKey(className));
      
      if (tasksJson != null) {
        final List<dynamic> decoded = json.decode(tasksJson);
        return decoded.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error loading tasks: $e');
    }
    return [];
  }

  Future<void> saveTaskToClass(String className, Map<String, dynamic> task) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasks = await getTasksForClass(className);
      
      tasks.add(task);
      await prefs.setString(_getStorageKey(className), json.encode(tasks));
    } catch (e) {
      print('Error saving task: $e');
    }
  }

  Future<void> updateTaskInClass(String className, String taskId, Map<String, dynamic> updatedTask) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasks = await getTasksForClass(className);
      
      final index = tasks.indexWhere((task) => task['id'] == taskId);
      if (index != -1) {
        tasks[index] = updatedTask;
        await prefs.setString(_getStorageKey(className), json.encode(tasks));
      }
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  Future<void> deleteTaskFromClass(String className, String taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasks = await getTasksForClass(className);
      
      tasks.removeWhere((task) => task['id'] == taskId);
      await prefs.setString(_getStorageKey(className), json.encode(tasks));
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  Future<void> updateTask(String className, String taskId, Map<String, dynamic> updates) async {
    try {
      final tasks = await getTasksForClass(className);
      final taskIndex = tasks.indexWhere((task) => task['id'] == taskId);
      
      if (taskIndex != -1) {
        tasks[taskIndex] = {...tasks[taskIndex], ...updates};
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_getStorageKey(className), json.encode(tasks));
      }
    } catch (e) {
      print('Error updating task: $e');
      throw e;
    }
  }

  Future<void> deleteTask(String className, String taskId) async {
    try {
      final tasks = await getTasksForClass(className);
      tasks.removeWhere((task) => task['id'] == taskId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_getStorageKey(className), json.encode(tasks));
    } catch (e) {
      print('Error deleting task: $e');
      throw e;
    }
  }
}
