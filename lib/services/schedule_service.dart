import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aplikasi_ortu/models/schedule_model.dart';

class ScheduleService {
  static const String baseUrl = 'YOUR_API_BASE_URL'; // Replace with your API URL

  Future<List<Schedule>> getSchedules() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/schedules'));
      
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((data) => Schedule.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load schedules');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
