class Schedule {
  final String hari;
  final String nama_jadwal;
  final String jam;

  Schedule({
    required this.hari,
    required this.nama_jadwal,
    required this.jam,
  });

  // Jika nanti menggunakan JSON dari API
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      hari: json['hari'],
      nama_jadwal: json['nama_jadwal'],
      jam: json['jam'],
    );
  }
}
