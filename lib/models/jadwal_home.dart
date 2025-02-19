class Schedule {
  final String hari;
  final String namaPelajaran;
  final String jam;
  final String kelas;

  Schedule({
    required this.hari,
    required this.namaPelajaran,
    required this.jam,
    required this.kelas,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      hari: json['hari'],
      namaPelajaran: json['namaPelajaran'],
      jam: json['jam'],
      kelas: json['kelas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hari': hari,
      'namaPelajaran': namaPelajaran,
      'jam': jam,
      'kelas': kelas,
    };
  }
}
