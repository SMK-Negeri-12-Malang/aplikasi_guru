import '../models/activity_model.dart';

class ActivityService {
  static final ActivityService _instance = ActivityService._internal();
  factory ActivityService() => _instance;
  ActivityService._internal();

  final Map<String, Map<String, Map<String, List<Activity>>>> _activitiesData = {};

  List<Activity> getActivities(String date, String sesi, String studentName) {
    // Different activities based on session
    if (sesi == 'Pagi') {
      return [
        Activity(aktivitas: 'Sholat Subuh', kategori: 'Ibadah', dilakukan: 'Ya', skor: 100, keterangan: 'Baik Sekali'),
        Activity(aktivitas: 'Dzikir Pagi', kategori: 'Ibadah', dilakukan: 'Ya', skor: 90, keterangan: 'Baik'),
        Activity(aktivitas: 'Merapikan Tempat Tidur', kategori: 'Kebersihan', dilakukan: 'Ya', skor: 85, keterangan: 'Baik'),
        Activity(aktivitas: 'Olahraga Pagi', kategori: 'Kesehatan', dilakukan: 'Ya', skor: 80, keterangan: 'Baik'),
      ];
    } else if (sesi == 'Siang') {
      return [
        Activity(aktivitas: 'Sholat Dzuhur', kategori: 'Ibadah', dilakukan: 'Ya', skor: 100, keterangan: 'Baik Sekali'),
        Activity(aktivitas: 'Makan Siang', kategori: 'Kesehatan', dilakukan: 'Ya', skor: 90, keterangan: 'Baik'),
        Activity(aktivitas: 'Mengaji', kategori: 'Ibadah', dilakukan: 'Ya', skor: 85, keterangan: 'Baik'),
        Activity(aktivitas: 'Belajar', kategori: 'Pendidikan', dilakukan: 'Ya', skor: 80, keterangan: 'Baik'),
      ];
    } else if (sesi == 'Sore') {
      return [
        Activity(aktivitas: 'Sholat Ashar', kategori: 'Ibadah', dilakukan: 'Ya', skor: 100, keterangan: 'Baik Sekali'),
        Activity(aktivitas: 'Kegiatan Ekstrakurikuler', kategori: 'Pendidikan', dilakukan: 'Ya', skor: 90, keterangan: 'Baik'),
        Activity(aktivitas: 'Membersihkan Kamar', kategori: 'Kebersihan', dilakukan: 'Ya', skor: 85, keterangan: 'Baik'),
        Activity(aktivitas: 'Olahraga Sore', kategori: 'Kesehatan', dilakukan: 'Ya', skor: 80, keterangan: 'Baik'),
      ];
    } else if (sesi == 'Malam') {
      return [
        Activity(aktivitas: 'Sholat Maghrib', kategori: 'Ibadah', dilakukan: 'Ya', skor: 100, keterangan: 'Baik Sekali'),
        Activity(aktivitas: 'Sholat Isya', kategori: 'Ibadah', dilakukan: 'Ya', skor: 100, keterangan: 'Baik Sekali'),
        Activity(aktivitas: 'Belajar Malam', kategori: 'Pendidikan', dilakukan: 'Ya', skor: 90, keterangan: 'Baik'),
        Activity(aktivitas: 'Dzikir Malam', kategori: 'Ibadah', dilakukan: 'Ya', skor: 85, keterangan: 'Baik'),
      ];
    }
    
    // Default activities if session is not specified
    return [
      Activity(aktivitas: 'Default Activity', kategori: 'Umum', dilakukan: 'Ya', skor: 0, keterangan: '-'),
    ];
  }

  void saveActivities(String date, String sesi, String studentName, List<Activity> activities) {
    _activitiesData[date] ??= {};
    _activitiesData[date]![sesi] ??= {};
    _activitiesData[date]![sesi]![studentName] = activities.map((a) => Activity(
      aktivitas: a.aktivitas,
      kategori: a.kategori,
      dilakukan: a.dilakukan,
      skor: a.skor,
      keterangan: a.keterangan,
    )).toList();
  }

  List<Activity> _getDefaultActivities() {
    return [
      Activity(
        aktivitas: 'Membaca Al-Quran',
        kategori: 'Tahfidz',
        dilakukan: 'Ya',
        skor: 100,
        keterangan: 'Baik',
      ),
      Activity(
        aktivitas: 'Menghafal Hadits',
        kategori: 'Hadits',
        dilakukan: 'Ya',
        skor: 90,
        keterangan: 'Bagus',
      ),
      Activity(
        aktivitas: 'Sholat Dhuha',
        kategori: 'Ibadah',
        dilakukan: 'Ya',
        skor: 85,
        keterangan: 'Cukup',
      ),
    ];
  }
}
