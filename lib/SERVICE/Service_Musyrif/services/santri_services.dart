import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SantriService {
  static late SharedPreferences _prefs;

  // Fungsi untuk menyimpan data santri
  static Future<void> saveSantriData(Map<String, Map<String, String>> santriData) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setString('santriData', json.encode(santriData));
  }

  // Fungsi untuk memuat data santri
  static Future<Map<String, Map<String, String>>> loadSantriData() async {
    _prefs = await SharedPreferences.getInstance();
    final savedData = _prefs.getString('santriData');
    if (savedData != null) {
      return Map<String, Map<String, String>>.from(json.decode(savedData));
    }
    return {};
  }
}
