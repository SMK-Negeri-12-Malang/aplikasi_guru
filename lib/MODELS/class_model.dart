class ClassModel {
  final String id;
  final String kelas;

  ClassModel({
    required this.id,
    required this.kelas,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] ?? '',
      kelas: json['kelas'] ?? '',
    );
  }
}
