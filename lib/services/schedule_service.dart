import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aplikasi_ortu/models/schedule_model.dart';

class ScheduleService {
  static const String baseUrl = 'http://26.214.65.15/auth_schedule/endpoints/get_jadwal.php';

  Future<List<Schedule>> getSchedules() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => Schedule(
          hari: item['hari'] ?? '',
          nama_jadwal: item['nama_jadwal'] ?? '',
          jam: item['jam'] ?? '',
        )).toList();
      } else {
        throw Exception('Failed to load schedules');
      }
    } catch (e) {
      throw Exception('Error fetching schedules: $e');
    }
  }
}
