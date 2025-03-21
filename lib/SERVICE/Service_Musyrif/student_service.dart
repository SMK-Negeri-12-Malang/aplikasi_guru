import '../../MUSYRIF/models/student_model.dart';

class StudentService {
  static final Map<String, List<Student>> _studentsByCategory = {
    'Mutabaah': [
      Student(name: 'Ahmad', category: 'Mutabaah', kelas: 'Kelas 1'),
      Student(name: 'Budi', category: 'Mutabaah', kelas: 'Kelas 2'),
      Student(name: 'Citra', category: 'Mutabaah', kelas: 'Kelas 3'),
    ],
    'Tahsin': [
      Student(name: 'Ayu', category: 'Tahsin', kelas: 'Kelas 1'),
      Student(name: 'Bambang', category: 'Tahsin', kelas: 'Kelas 2'),
      Student(name: 'Cici', category: 'Tahsin', kelas: 'Kelas 3'),
    ],
    'Tahfidz': [
      Student(name: 'Asep', category: 'Tahfidz', kelas: 'Kelas 1'),
      Student(name: 'Beni', category: 'Tahfidz', kelas: 'Kelas 2'),
      Student(name: 'Cahyo', category: 'Tahfidz', kelas: 'Kelas 3'),
    ],
  };

  static List<Student> getStudentsByCategory(String category) {
    return _studentsByCategory[category] ?? [];
  }
}
