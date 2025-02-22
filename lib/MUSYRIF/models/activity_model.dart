class Activity {
  final String aktivitas;
  final String kategori;
  String? dilakukan;  // Make nullable
  int? skor;         // Make nullable
  String keterangan;

  Activity({
    required this.aktivitas,
    required this.kategori,
    this.dilakukan,  // Remove required
    this.skor,      // Remove required
    this.keterangan = '',
  });
}
