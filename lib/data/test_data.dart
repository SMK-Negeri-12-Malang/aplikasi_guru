import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TestData {
  static List<Map<String, dynamic>> sampleData = [
    {
      'nama': 'Ahmad Santri',
      'kamar': 'A-101',
      'kelas': 'Kelas 1',
      'halaqoh': 'Halaqoh 1',
      'musyrif': 'Ust. Abdul',
      'keperluan': 'Berobat ke klinik',
      'tanggalIzin': '15-3-2024',
      'tanggalKembali': '16-3-2024',
      'status': 'Diperiksa',
      'isKembali': false,
      'timestamp': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
    },
    {
      'nama': 'Muhammad Santri',
      'kamar': 'B-102',
      'kelas': 'Kelas 2',
      'halaqoh': 'Halaqoh 2',
      'musyrif': 'Ust. Rahman',
      'keperluan': 'Pulang karena sakit',
      'tanggalIzin': '14-3-2024',
      'tanggalKembali': '17-3-2024',
      'status': 'Ditolak',
      'isKembali': false,
      'timestamp': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
    },
    {
      'nama': 'Ibrahim Santri',
      'kamar': 'C-103',
      'kelas': 'Kelas 3',
      'halaqoh': 'Halaqoh 3',
      'musyrif': 'Ust. Mahmud',
      'keperluan': 'Acara keluarga',
      'tanggalIzin': '16-3-2024',
      'tanggalKembali': '18-3-2024',
      'status': 'Diizinkan',
      'isKembali': false,
      'timestamp': DateTime.now().toIso8601String(),
    },
    {
      'nama': 'Yusuf Santri',
      'kamar': 'A-104',
      'kelas': 'Kelas 1',
      'halaqoh': 'Halaqoh 1',
      'musyrif': 'Ust. Hasan',
      'keperluan': 'Kontrol dokter',
      'tanggalIzin': '13-3-2024',
      'tanggalKembali': '14-3-2024',
      'status': 'Keluar',
      'isKembali': false,
      'timestamp': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
    },
    {
      'nama': 'Umar Santri',
      'kamar': 'B-105',
      'kelas': 'Kelas 2',
      'halaqoh': 'Halaqoh 2',
      'musyrif': 'Ust. Ali',
      'keperluan': 'Urusan KTP',
      'tanggalIzin': '12-3-2024',
      'tanggalKembali': '13-3-2024',
      'status': 'Masuk',
      'isKembali': true,
      'timestamp': DateTime.now().subtract(Duration(days: 4)).toIso8601String(),
    },
  ];

  static Future<void> initializeTestData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String>? existingData = prefs.getStringList('perizinan_data');
      
      if (existingData == null || existingData.isEmpty) {
        List<String> testDataJson = sampleData
            .map((data) => json.encode({
                  ...data,
                  'timestamp': DateTime.now().toIso8601String(),
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                }))
            .toList();
        await prefs.setStringList('perizinan_data', testDataJson);
      }
    } catch (e) {
      print('Error initializing test data: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> dataJson = prefs.getStringList('perizinan_data') ?? [];
      return dataJson
          .map((str) => json.decode(str) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting all data: $e');
      return [];
    }
  }

  static Future<void> updateData(List<Map<String, dynamic>> newData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> dataJson = newData.map((data) => json.encode(data)).toList();
      await prefs.setStringList('perizinan_data', dataJson);
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  static Future<void> resetTestData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> testDataJson = sampleData
          .map((data) => json.encode({
                ...data,
                'timestamp': DateTime.now().toIso8601String(),
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
              }))
          .toList();
      await prefs.setStringList('perizinan_data', testDataJson);
    } catch (e) {
      print('Error resetting test data: $e');
    }
  }
}
