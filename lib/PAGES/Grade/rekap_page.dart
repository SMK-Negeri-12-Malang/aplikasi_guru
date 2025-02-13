import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';

class RekapPage extends StatefulWidget {
  final String className;
  final List<Map<String, dynamic>> classStudents;
  final List<String> classTables;
  final Function(String, List<Map<String, dynamic>>) onSave;

  RekapPage({required this.className, required this.classStudents, required this.classTables, required this.onSave});

  @override
  _RekapPageState createState() => _RekapPageState();
}

class _RekapPageState extends State<RekapPage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredStudents = [];
  Map<int, Map<String, TextEditingController>> controllers = {};
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    filteredStudents = widget.classStudents;
    _initializeControllers();
  }

  void _initializeControllers() {
    controllers.clear();
    for (int i = 0; i < widget.classStudents.length; i++) {
      controllers[i] = {};
      for (String table in widget.classTables) {
        var grade = widget.classStudents[i]['grades'][table] ?? 0;
        controllers[i]![table] = TextEditingController(text: grade.toString());
      }
    }
  }

  @override
  void dispose() {
    controllers.forEach((key, value) {
      value.forEach((key, controller) {
        controller.dispose();
      });
    });
    searchController.dispose();
    super.dispose();
  }

  void _filterStudents(String query) {
    setState(() {
      filteredStudents = widget.classStudents
          .where((student) => student['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _updateGrade(int studentIndex, String tableName, String value) {
    setState(() {
      widget.classStudents[studentIndex]['grades'][tableName] = int.tryParse(value) ?? 0;
    });
  }

  void _saveGrades() {
    controllers.forEach((studentIndex, tableControllers) {
      tableControllers.forEach((tableName, controller) {
        widget.classStudents[studentIndex]['grades'][tableName] = int.tryParse(controller.text) ?? 0;
      });
    });
    widget.onSave(widget.className, widget.classStudents);
  }

  Future<void> _downloadCSV() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Add headers
    var headers = ['Nama Siswa', 'Tugas', 'Ulangan', 'UTS', 'UAS', 'Ujian Sekolah', 'Ujian Nasional'];
    for (var i = 0; i < headers.length; i++) {
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = headers[i] as CellValue?;
    }

    // Add data rows
    for (var i = 0; i < filteredStudents.length; i++) {
      var student = filteredStudents[i];
      var row = [
        student['name'],
        student['grades']['Tugas'] ?? 0,
        student['grades']['Ulangan'] ?? 0,
        student['grades']['UTS'] ?? 0,
        student['grades']['UAS'] ?? 0,
        student['grades']['Ujian Sekolah'] ?? 0,
        student['grades']['Ujian Nasional'] ?? 0,
      ];

      for (var j = 0; j < row.length; j++) {
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1)).value = row[j];
      }
    }

    // Save and open file
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${widget.className}_rekap.xlsx';
    final file = File(path);
    await file.writeAsBytes(excel.encode()!);

    await OpenFile.open(path);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File Excel berhasil dibuat dan dibuka')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.table_chart, size: 30),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Rekap Nilai - ${widget.className}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      body: Padding(
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Nama Siswa')),
                      DataColumn(label: Text('Tugas')),
                      DataColumn(label: Text('Ulangan')),
                      DataColumn(label: Text('UTS')),
                      DataColumn(label: Text('UAS')),
                      DataColumn(label: Text('Ujian Sekolah')),
                      DataColumn(label: Text('Ujian Nasional')),
                    ],
                    rows: List.generate(filteredStudents.length, (index) {
                      final student = filteredStudents[index];
                      int studentIndex = widget.classStudents.indexOf(student);
                      return DataRow(
                        cells: [
                          DataCell(Text(student['name'])),
                          DataCell(
                            Center(
                              child: isEditing
                                  ? TextFormField(
                                      controller: controllers[studentIndex]!['Tugas'],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      onChanged: (value) => _updateGrade(studentIndex, 'Tugas', value),
                                    )
                                  : Text(student['grades']['Tugas']?.toString() ?? '0'),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: isEditing
                                  ? TextFormField(
                                      controller: controllers[studentIndex]!['Ulangan'],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      onChanged: (value) => _updateGrade(studentIndex, 'Ulangan', value),
                                    )
                                  : Text(student['grades']['Ulangan']?.toString() ?? '0'),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: isEditing
                                  ? TextFormField(
                                      controller: controllers[studentIndex]!['UTS'],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      onChanged: (value) => _updateGrade(studentIndex, 'UTS', value),
                                    )
                                  : Text(student['grades']['UTS']?.toString() ?? '0'),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: isEditing
                                  ? TextFormField(
                                      controller: controllers[studentIndex]!['UAS'],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      onChanged: (value) => _updateGrade(studentIndex, 'UAS', value),
                                    )
                                  : Text(student['grades']['UAS']?.toString() ?? '0'),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: isEditing
                                  ? TextFormField(
                                      controller: controllers[studentIndex]!['Ujian Sekolah'],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      onChanged: (value) => _updateGrade(studentIndex, 'Ujian Sekolah', value),
                                    )
                                  : Text(student['grades']['Ujian Sekolah']?.toString() ?? '0'),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: isEditing
                                  ? TextFormField(
                                      controller: controllers[studentIndex]!['Ujian Nasional'],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      onChanged: (value) => _updateGrade(studentIndex, 'Ujian Nasional', value),
                                    )
                                  : Text(student['grades']['Ujian Nasional']?.toString() ?? '0'),
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
      floatingActionButton: Column(
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
}