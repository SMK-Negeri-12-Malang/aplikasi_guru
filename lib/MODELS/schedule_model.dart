class Schedule {
  final int id;
  final String namaPelajaran;
  final String hari;
  final String jam;

  Schedule({
    required this.id,
    required this.namaPelajaran,
    required this.hari,
    required this.jam,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      namaPelajaran: json['nama_pelajaran'],
      hari: json['hari'],
      jam: json['jam'],
    );
  }
}
