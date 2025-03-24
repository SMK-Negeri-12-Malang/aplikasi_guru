import '../../../MODELS/models_musyrif/models/activity_model.dart';

class ActivityService {
  static final ActivityService _instance = ActivityService._internal();
  factory ActivityService() => _instance;
  ActivityService._internal();

  static final Map<String, Map<String, Map<String, List<Activity>>>> _activities = {};

  List<Activity> getActivities(String date, String sesi, String studentName) {
    // Generate empty activities for new entries
    if (!_activities.containsKey(date) ||
        !_activities[date]!.containsKey(sesi) ||
        !_activities[date]![sesi]!.containsKey(studentName)) {
      return _getDefaultActivities();
    }
    return _activities[date]![sesi]![studentName] ?? _getDefaultActivities();
  }

  List<Activity> _getDefaultActivities() {
    return [
      Activity(
        aktivitas: 'Membaca Al-Quran',
        kategori: 'Tahfidz',
        dilakukan: null,
        skor: null,
        keterangan: '',
      ),
      Activity(
        aktivitas: 'Menghafal Hadits',
        kategori: 'Hadits',
        dilakukan: null,
        skor: null,
        keterangan: '',
      ),
      Activity(
        aktivitas: 'Sholat Dhuha',
        kategori: 'Ibadah',
        dilakukan: null,
        skor: null,
        keterangan: '',
      ),
    ];
  }

  void saveActivities(String date, String sesi, String studentName, List<Activity> activities) {
    _activities[date] ??= {};
    _activities[date]![sesi] ??= {};
    _activities[date]![sesi]![studentName] = activities;
  }
}
