import 'dart:convert';
import 'package:aplikasi_guru/MODELS/grade_model.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';


class GradeService {
  static Future<List<Grade>> getGrades() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/grades'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Grade.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load grades');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  static Future<Grade> getGradeById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/grades/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Grade.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load grade details');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  static Future<List<dynamic>> getStudents() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.studentEndpoint}'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  static Future<Map<String, dynamic>> updateStudentGrades(String studentId, Map<String, dynamic> grades) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.studentEndpoint}/$studentId'),
        headers: ApiConfig.headers,
        body: json.encode({'grades': grades}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update grades');
      }
    } catch (e) {
      throw Exception('Error updating grades: $e');
    }
  }

  static Future<Map<String, dynamic>> getStudentById(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.studentEndpoint}/$studentId'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load student details');
      }
    } catch (e) {
      throw Exception('Error loading student: $e');
    }
  }
}
