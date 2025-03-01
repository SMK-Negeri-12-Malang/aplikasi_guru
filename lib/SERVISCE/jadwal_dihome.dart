import 'package:aplikasi_ortu/models/jadwal_home.dart';
import 'package:intl/intl.dart';

class ScheduleService {
  static const String baseUrl = 'YOUR_API_BASE_URL'; // Replace with your API URL

  Future<List<Schedule>> getSchedules() async {
    // Simulate API call with dummy data
    await Future.delayed(Duration(seconds: 1));
    
    return [
      Schedule(
        hari: 'Senin',
        namaPelajaran: 'Matematika',
        jam: '07:30 - 09:00',
        kelas: 'Kelas 7A',
      ),
      Schedule(
        hari: 'Senin',
        namaPelajaran: 'IPA',
        jam: '09:30 - 11:00',
        kelas: 'Kelas 8B',
      ),
      Schedule(
        hari: 'Selasa',
        namaPelajaran: 'Bahasa Indonesia',
        jam: '07:30 - 09:00',
        kelas: 'Kelas 7B',
      ),
      Schedule(
        hari: 'Rabu',
        namaPelajaran: 'IPS',
        jam: '10:00 - 11:30',
        kelas: 'Kelas 9A',
      ),
      // Add current day schedules to ensure we see data
      Schedule(
        hari: DateFormat('EEEE', 'id_ID').format(DateTime.now()),
        namaPelajaran: 'Mata Pelajaran Hari Ini 1',
        jam: '08:00 - 09:30',
        kelas: 'Kelas 8A',
      ),
      Schedule(
        hari: DateFormat('EEEE', 'id_ID').format(DateTime.now()),
        namaPelajaran: 'Mata Pelajaran Hari Ini 2',
        jam: '10:00 - 11:30',
        kelas: 'Kelas 8B',
      ),
    ];
  }
}
