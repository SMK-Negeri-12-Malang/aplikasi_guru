class Activity {
  String aktivitas;
  String kategori;
  String? dilakukan;
  int? skor;
  String keterangan;

  Activity({
    required this.aktivitas,
    required this.kategori,
    this.dilakukan,
    this.skor,
    required this.keterangan,
  });
}
