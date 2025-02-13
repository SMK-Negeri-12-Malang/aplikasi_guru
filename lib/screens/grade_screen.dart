import 'package:flutter/material.dart';
import '../services/grade_service.dart';
import '../models/grade_model.dart';

class GradeScreen extends StatefulWidget {
  @override
  _GradeScreenState createState() => _GradeScreenState();
}

class _GradeScreenState extends State<GradeScreen> {
  List<Grade> grades = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    try {
      final loadedGrades = await GradeService.getGrades();
      setState(() {
        grades = loadedGrades;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading grades: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grades'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: grades.length,
              itemBuilder: (context, index) {
                final grade = grades[index];
                return ListTile(
                  title: Text('Student ID: ${grade.studentId}'),
                  subtitle: Text('Score: ${grade.score}'),
                  trailing: Text('Semester: ${grade.semester}'),
                );
              },
            ),
    );
  }
}
