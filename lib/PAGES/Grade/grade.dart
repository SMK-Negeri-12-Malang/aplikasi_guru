import 'package:flutter/material.dart';

class GradePage extends StatefulWidget {
  final List<Map<String, dynamic>> students;

  const GradePage({super.key, required this.students});

  @override
  _GradePageState createState() => _GradePageState();
}

class _GradePageState extends State<GradePage> {
  late List<Map<String, dynamic>> students;
  bool isEditing = false;
  late List<List<TextEditingController>> controllers;

  @override
  void initState() {
    super.initState();
    students = widget.students;
    _initializeControllers();
  }

  void _initializeControllers() {
    controllers = students.map((student) {
      return List.generate(student['grades'].length, (index) {
        return TextEditingController(text: student['grades'][index].toString());
      });
    }).toList();
  }

  void _updateGrade(int studentIndex, int gradeIndex, String value) {
    setState(() {
      students[studentIndex]['grades'][gradeIndex] = int.tryParse(value) ?? 0;
      controllers[studentIndex][gradeIndex].text = students[studentIndex]['grades'][gradeIndex].toString();
    });
  }

  void _addTask() {
    TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Tugas Baru'),
        content: TextField(
          controller: taskController,
          decoration: const InputDecoration(labelText: 'Nama Tugas'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                for (var student in students) {
                  student['grades'].add(0);
                }
                _initializeControllers();
              });
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _editTask() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Nilai Siswa'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addTask,
          ),
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: _editTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            const DataColumn(label: Text('Nama Siswa')),
            ...List.generate(students[0]['grades'].length, (index) => DataColumn(label: Text('Tugas ${index + 1}'))),
          ],
          rows: students.asMap().entries.map((entry) {
            final studentIndex = entry.key;
            final student = entry.value;
            return DataRow(cells: [
              DataCell(Text(student['name'])),
              ...List.generate(student['grades'].length, (taskIndex) {
                return DataCell(
                  isEditing
                      ? TextField(
                          controller: controllers[studentIndex][taskIndex],
                          keyboardType: TextInputType.number,
                          onSubmitted: (value) => _updateGrade(studentIndex, taskIndex, value),
                        )
                      : Text(student['grades'][taskIndex].toString()),
                );
              }),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
