import 'package:aplikasi_ortu/services/grade_service.dart';
import 'package:aplikasi_ortu/services/grade_state_service.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

class TablePage extends StatefulWidget {
  final String className;
  final String tableName;
  final List<Map<String, dynamic>> students;
  final Function(String, String, List<Map<String, dynamic>>) onSave;

  TablePage({required this.className, required this.tableName, required this.students, required this.onSave});

  @override
  _TablePageState createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  final GradeStateService _gradeService = GradeStateService();
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredStudents = [];
  Map<int, TextEditingController> controllers = {};
  bool isEditing = false;
  bool isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _gradeService.addListener(_onGradesUpdated);
    _fetchStudents();
  }

  @override
  void dispose() {
    _gradeService.removeListener(_onGradesUpdated);
    controllers.forEach((key, controller) => controller.dispose());
    searchController.dispose();
    super.dispose();
  }

  void _onGradesUpdated() {
    final updatedStudents = _gradeService.getStudentsForClass(widget.className);
    if (mounted) {
      setState(() {
        widget.students.clear();
        widget.students.addAll(updatedStudents);
        filteredStudents = List.from(widget.students);
        _initializeControllers();
      });
    }
  }

  Future<void> _fetchStudents() async {
    setState(() {
      isLoadingData = true;
    });
    
    try {
      final response = await http.get(
        Uri.parse('https://67ac42f05853dfff53d9e093.mockapi.io/siswa')
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          widget.students.clear();
          for (var student in data) {
            if (student['kelas'] == widget.className) {
              widget.students.add({
                'id': student['id'],
                'name': student['name'],
                'class': student['kelas'],
                'grades': {
                  'Tugas': 0,
                  'Ulangan': 0,
                  'UTS': 0,
                  'UAS': 0,
                  'Ujian Sekolah': 0,
                  'Ujian Nasional': 0,
                }
              });
            }
          }
          filteredStudents = widget.students;
          _initializeControllers();
          isLoadingData = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading students: $e')),
      );
    }
  }

  void _initializeControllers() {
    controllers.clear();
    for (int i = 0; i < widget.students.length; i++) {
      final student = widget.students[i];
      final grade = _gradeService.getStudentGrade(
        widget.className,
        student['id'].toString(),
        widget.tableName
      );
      controllers[i] = TextEditingController(text: grade.toString());
    }
  }

  void _filterStudents(String query) {
    setState(() {
      filteredStudents = widget.students
          .where((student) => student['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _updateGrade(int studentIndex, String value) {
    final student = widget.students[studentIndex];
    final grade = int.tryParse(value) ?? 0;
    
    // Update both local state and service
    setState(() {
      student['grades'] ??= {};
      student['grades'][widget.tableName] = grade;
    });
    
    _gradeService.updateStudentGrade(
      widget.className,
      student['id'].toString(),
      widget.tableName,
      grade
    );
  }

  void _saveGrades() async {
    try {
      // Update all grades from controllers
      for (int i = 0; i < widget.students.length; i++) {
        final student = widget.students[i];
        final value = controllers[i]?.text ?? '0';
        final grade = int.tryParse(value) ?? 0;
        
        student['grades'] ??= {};
        student['grades'][widget.tableName] = grade;
        
        _gradeService.updateStudentGrade(
          widget.className,
          student['id'].toString(),
          widget.tableName,
          grade
        );
      }

      widget.onSave(widget.className, widget.tableName, widget.students);
      setState(() {
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nilai berhasil disimpan')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error menyimpan nilai: $e')),
      );
    }
  }

  Future<void> _downloadCSV() async {
    List<List<dynamic>> rows = [];
    rows.add(['No. Absen', 'Nama Siswa', 'Nilai']);

    for (int i = 0; i < filteredStudents.length; i++) {
      List<dynamic> row = [];
      row.add(i + 1);
      row.add(filteredStudents[i]['name']);
      var grade = filteredStudents[i]['grades'][widget.tableName] ?? 0;
      row.add(grade);
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${widget.className}_${widget.tableName}.csv';
    final file = File(path);
    await file.writeAsString(csv);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CSV berhasil diunduh di $path')),
    );
  }

  void _editTask() {
    if (isEditing) {
      _saveGrades();
    }
    setState(() {
      isEditing = !isEditing;
    });
  }

  Widget _buildShimmerTable() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            height: 50,
            margin: EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) {
              return Container(
                height: 40,
                margin: EdgeInsets.symmetric(vertical: 4),
                color: Colors.white,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom header instead of AppBar
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Icon(Icons.table_chart, size: 30, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${widget.className} (${widget.tableName})',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Cari Nama Siswa',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: _filterStudents,
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: isLoadingData
                          ? _buildShimmerTable()
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: DataTable(
                                  columns: [
                                    DataColumn(label: Text('No. Absen')),
                                    DataColumn(label: Text('Nama Siswa')),
                                    DataColumn(label: Text('Nilai')),
                                  ],
                                  rows: List.generate(filteredStudents.length, (index) {
                                    final student = filteredStudents[index];
                                    int studentIndex = widget.students.indexOf(student);
                                    return DataRow(
                                      cells: [
                                        DataCell(Text((index + 1).toString())),
                                        DataCell(Text(student['name'])),
                                        DataCell(
                                          Container(
                                            width: 100,
                                            child: isEditing
                                                ? TextFormField(
                                                    controller: controllers[studentIndex],
                                                    keyboardType: TextInputType.number,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                    ),
                                                    onChanged: (value) => _updateGrade(studentIndex, value),
                                                  )
                                                : Text((student['grades'][widget.tableName] ?? 0).toString()),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isLoadingData
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'edit',
                  onPressed: _editTask,
                  child: Icon(isEditing ? Icons.check : Icons.edit),
                  backgroundColor: Colors.blue,
                ),
                SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'download',
                  onPressed: _downloadCSV,
                  child: Icon(Icons.download),
                  backgroundColor: Colors.green,
                ),
              ],
            ),
    );
  }

  @override
  void didUpdateWidget(TablePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.students != widget.students) {
      _initializeControllers();
    }
  }
}
