import 'package:flutter/foundation.dart';

class GradeStateService extends ChangeNotifier {
  static final GradeStateService _instance = GradeStateService._internal();
  factory GradeStateService() => _instance;
  GradeStateService._internal();

  final Map<String, List<Map<String, dynamic>>> _classStudents = {};

  void updateClassStudents(String className, List<Map<String, dynamic>> students) {
    // Create deep copy of students to prevent reference issues
    _classStudents[className] = students.map((student) => {
      'id': student['id'],
      'name': student['name'],
      'class': student['class'],
      'grades': Map<String, dynamic>.from(student['grades'] ?? {}),
    }).toList();
    
    notifyListeners();
  }

  List<Map<String, dynamic>> getStudentsForClass(String className) {
    // Return deep copy to prevent reference issues
    return (_classStudents[className] ?? []).map((student) => {
      'id': student['id'],
      'name': student['name'],
      'class': student['class'],
      'grades': Map<String, dynamic>.from(student['grades'] ?? {}),
    }).toList();
  }

  void updateStudentGrade(String className, String studentId, String category, int grade) {
    var students = _classStudents[className];
    if (students != null) {
      final studentIndex = students.indexWhere((s) => s['id'].toString() == studentId);
      if (studentIndex != -1) {
        // Create a new map for grades if it doesn't exist
        students[studentIndex]['grades'] ??= {};
        students[studentIndex]['grades'][category] = grade;
        
        // Create a new list to ensure state change is detected
        _classStudents[className] = List.from(students);
        notifyListeners();
      }
    }
  }

  void initializeStudentGrades(String className, List<Map<String, dynamic>> students) {
    if (!_classStudents.containsKey(className)) {
      _classStudents[className] = students.map((student) => {
        ...student,
        'grades': student['grades'] ?? {
          'Tugas': 0,
          'Ulangan': 0,
          'UTS': 0,
          'UAS': 0,
          'Ujian Sekolah': 0,
          'Ujian Nasional': 0,
        }
      }).toList();
      notifyListeners();
    }
  }

  Map<String, dynamic>? getStudent(String className, String studentId) {
    return _classStudents[className]?.firstWhere(
      (student) => student['id'].toString() == studentId,
      orElse: () => {'grades': {}},
    );
  }

  int getStudentGrade(String className, String studentId, String category) {
    var students = _classStudents[className];
    if (students != null) {
      final student = students.firstWhere(
        (s) => s['id'].toString() == studentId,
        orElse: () => {'grades': {}},
      );
      return student['grades']?[category] ?? 0;
    }
    return 0;
  }
}
