// laporan_model.dart
class Laporan {
  final String nama;
  final String kelas;
  final String pelanggaran;
  final String tanggal;
  final int poin;
  final String tingkatPelanggaran;

  Laporan({
    required this.nama,
    required this.kelas,
    required this.pelanggaran,
    required this.tanggal,
    required this.poin,
    required this.tingkatPelanggaran,
  });

  // Method to convert a map to a Laporan object
  factory Laporan.fromMap(Map<String, dynamic> map) {
    return Laporan(
      nama: map['Nama'],
      kelas: map['Kelas'],
      pelanggaran: map['Pelanggaran'],
      tanggal: map['Tanggal'],
      poin: map['Poin'],
      tingkatPelanggaran: map['Tingkat Pelanggaran'],
    );
  }

  // Method to convert a Laporan object to a map
  Map<String, dynamic> toMap() {
    return {
      'Nama': nama,
      'Kelas': kelas,
      'Pelanggaran': pelanggaran,
      'Tanggal': tanggal,
      'Poin': poin,
      'Tingkat Pelanggaran': tingkatPelanggaran,
    };
  }
}