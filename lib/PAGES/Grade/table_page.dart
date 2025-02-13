import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';

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
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredStudents = [];
  Map<int, TextEditingController> controllers = {};
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    filteredStudents = widget.students;
    _initializeControllers();
  }

  void _initializeControllers() {
    controllers.clear();
    for (int i = 0; i < widget.students.length; i++) {
      var grade = widget.students[i]['grades'][widget.tableName] ?? 0;
      controllers[i] = TextEditingController(text: grade.toString());
    }
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) => controller.dispose());
    searchController.dispose();
    super.dispose();
  }

  void _filterStudents(String query) {
    setState(() {
      filteredStudents = widget.students
          .where((student) => student['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _updateGrade(int studentIndex, String value) {
    setState(() {
      widget.students[studentIndex]['grades'][widget.tableName] = int.tryParse(value) ?? 0;
    });
  }

  void _saveGrades() {
    controllers.forEach((index, controller) {
      widget.students[index]['grades'][widget.tableName] = int.tryParse(controller.text) ?? 0;
    });
    widget.onSave(widget.className, widget.tableName, widget.students);
  }

  Future<void> _downloadCSV() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Add headers
    var headers = ['No. Absen', 'Nama Siswa', 'Nilai'];
    for (var i = 0; i < headers.length; i++) {
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = headers[i] as CellValue?;
    }

    // Add data rows
    for (var i = 0; i < filteredStudents.length; i++) {
      var student = filteredStudents[i];
      var row = [
        i + 1,
        student['name'],
        student['grades'][widget.tableName] ?? 0,
      ];

      for (var j = 0; j < row.length; j++) {
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1)).value = row[j];
      }
    }

    // Save and open file
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${widget.className}_${widget.tableName}.xlsx';
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
                '    ${widget.className} (${widget.tableName})',
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