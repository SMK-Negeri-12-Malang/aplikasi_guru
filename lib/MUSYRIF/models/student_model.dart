class Student {
  final String name;
  final String category;
  final String kelas;

  Student({
    required this.name,
    required this.category,
    required this.kelas,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name: json['name'],
      category: json['category'],
      kelas: json['kelas'],
    );
  }
}

class StudentData {
  static final Map<String, List<String>> studentsByCategory = {
    "Mutabaah": ["Ahmad", "Muhammad", "Abdullah", "Zaid"],
    "Tahsin": ["Ibrahim", "Yusuf", "Ismail", "Yahya"],
    "Tahfidz": ["Umar", "Ali", "Hamzah", "Bilal"],
  };

  static List<String> getStudentsByCategory(String category) {
    return studentsByCategory[category] ?? [];
  }
}
