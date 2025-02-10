import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class GradePage extends StatefulWidget {
  final String className;
  final List<String> students;

  GradePage({required this.className, required this.students});

  @override
  _GradePageState createState() => _GradePageState();
}

class _GradePageState extends State<GradePage> {
  final List<String> tables = [];
  late List<Map<String, dynamic>> students;
  bool isEditing = false;
  late List<List<TextEditingController>> controllers;
  List<String> taskNames = [];
  late List<TextEditingController> taskNameControllers;

  @override
  void initState() {
    super.initState();
    students = List.from(widget.students);
    _initializeTaskNames();
    _initializeControllers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String? newTable = ModalRoute.of(context)?.settings.arguments as String?;
    if (newTable != null && !tables.contains(newTable)) {
      setState(() {
        tables.add(newTable);
      });
    }
  }

  void _initializeControllers() {
    controllers = students.map((student) {
      return List.generate(student['grades'].length, (index) {
        return TextEditingController(text: student['grades'][index].toString());
      });
    }).toList();
  }

  void _initializeTaskNames() {
    if (students.isNotEmpty) {
      taskNames = List.generate(students[0]['grades'].length, (index) => 'Tugas ${index + 1}');
      taskNameControllers = List.generate(taskNames.length, (index) {
        return TextEditingController(text: taskNames[index]);
      });
    }
  }

  void _updateGrade(int studentIndex, int gradeIndex, String value) {
    setState(() {
      students[studentIndex]['grades'][gradeIndex] = int.tryParse(value) ?? 0;
      controllers[studentIndex][gradeIndex].text = students[studentIndex]['grades'][gradeIndex].toString();
    });
  }

  void _updateTaskName(int index, String value) {
    setState(() {
      taskNames[index] = value;
    });
  }

  void _saveGrades() {
    for (int studentIndex = 0; studentIndex < students.length; studentIndex++) {
      for (int gradeIndex = 0; gradeIndex < students[studentIndex]['grades'].length; gradeIndex++) {
        students[studentIndex]['grades'][gradeIndex] = int.tryParse(controllers[studentIndex][gradeIndex].text) ?? 0;
      }
    }
  }

  void _saveTaskNames() {
    setState(() {
      taskNames = taskNameControllers.map((controller) => controller.text).toList();
    });
  }

  void _addTask() {
    TextEditingController taskController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Tambah Tugas Baru',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 24),
              TextField(
                controller: taskController,
                decoration: const InputDecoration(labelText: 'Nama Tugas'),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      String taskName = taskController.text.isNotEmpty ? taskController.text : 'Tugas ${taskNames.length + 1}';
                      taskNames.add(taskName);
                      taskNameControllers.add(TextEditingController(text: taskName));
                      for (var student in students) {
                        student['grades'].add(0);
                      }
                      _initializeControllers();
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[600],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Tambah',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editTask() {
    if (isEditing) {
      _saveGrades();
      _saveTaskNames();
    }
    setState(() {
      isEditing = !isEditing;
    });
  }

  Future<void> _exportToExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Add header row
    List<String> header = ['Nama Siswa', ...taskNames];
    sheetObject.appendRow(header.cast<CellValue?>());

    // Add student data
    for (var student in students) {
      List<dynamic> row = [student['name'], ...student['grades']];
      sheetObject.appendRow(row.cast<CellValue?>());
    }

    // Save the file
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/rekap_nilai.xlsx';
    final file = File(path);
    file.writeAsBytesSync(excel.encode()!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data berhasil diekspor ke $path')),
    );
  }

  void addTable(String tableName) {
    setState(() {
      tables.add(tableName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grade Page - ${widget.className}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: _editTask,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DataTable(
                    columns: [
                      const DataColumn(
                        label: Text(
                          'Nama Siswa',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...List.generate(taskNames.length, (index) {
                        return DataColumn(
                          label: Container(
                            width: 100, // Set fixed width for consistency
                            child: isEditing
                                ? TextFormField(
                                    controller: taskNameControllers[index],
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    onChanged: (value) => _updateTaskName(index, value),
                                  )
                                : Text(
                                    taskNames[index],
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                          ),
                        );
                      }),
                    ],
                    rows: students.asMap().entries.map((entry) {
                      final studentIndex = entry.key;
                      final student = entry.value;
                      return DataRow(
                        cells: [
                          DataCell(Text(student['name'])),
                          ...List.generate(student['grades'].length, (taskIndex) {
                            return DataCell(
                              Container(
                                width: 100, // Match the header width
                                child: isEditing
                                    ? TextFormField(
                                        controller: controllers[studentIndex][taskIndex],
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        onChanged: (value) => _updateGrade(studentIndex, taskIndex, value),
                                      )
                                    : Text(student['grades'][taskIndex].toString()),
                              ),
                            );
                          }),
                        ],
                      );
                    }).toList(),
                    headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey[50]!),
                    dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
                    border: TableBorder.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: tables.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tables[index]),
                );
              },
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: widget.students.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.students[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(
            child: Icon(Icons.add, color: Colors.white),
            backgroundColor: Colors.blue.shade500,
            label: 'Tambah Tugas',
            labelBackgroundColor: Colors.blue.shade700,
            labelStyle: TextStyle(color: Colors.white),
            onTap: _addTask,
          ),
          SpeedDialChild(
            child: Icon(Icons.edit, color: Colors.white),
            backgroundColor: Colors.blue.shade500,
            label: 'Edit Tugas',
            labelBackgroundColor: Colors.blue.shade700,
            labelStyle: TextStyle(color: Colors.white),
            onTap: _editTask,
          ),
          SpeedDialChild(
            child: Icon(Icons.download, color: Colors.white),
            backgroundColor: Colors.blue.shade500,
            label: 'Ekspor ke Excel',
            labelBackgroundColor: Colors.blue.shade700,
            labelStyle: TextStyle(color: Colors.white),
            onTap: _exportToExcel,
          ),
        ],
      ),
    );
  }
}