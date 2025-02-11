import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class TablePage extends StatefulWidget {
  final String className;
  final String tableName;
  final List<Map<String, dynamic>> students;

  TablePage({required this.className, required this.tableName, required this.students});

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
    filteredStudents = List.from(widget.students);
    _initializeControllers();
  }

  void _initializeControllers() {
    // Inisialisasi controller untuk setiap siswa menggunakan index asli sebagai key
    for (int i = 0; i < widget.students.length; i++) {
      controllers[i] = TextEditingController(
        text: widget.students[i]['grades'][0].toString()
      );
    }
  }

  @override
  void dispose() {
    // Bersihkan semua controller saat widget di-dispose
    controllers.values.forEach((controller) => controller.dispose());
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

  void _updateGrade(int originalIndex, String value) {
    if (value.isEmpty) return;
    
    final grade = int.tryParse(value);
    if (grade != null) {
      setState(() {
        widget.students[originalIndex]['grades'][0] = grade;
      });
    }
  }

  void _saveGrades() {
    // Simpan nilai dari semua controller ke data siswa
    controllers.forEach((index, controller) {
      final grade = int.tryParse(controller.text) ?? 0;
      widget.students[index]['grades'][0] = grade;
    });
  }

  Future<void> _downloadCSV() async {
    List<List<dynamic>> rows = [];
    rows.add(['No. Absen', 'Nama Siswa', 'Nilai']);

    for (int i = 0; i < filteredStudents.length; i++) {
      List<dynamic> row = [];
      row.add(i + 1);
      row.add(filteredStudents[i]['name']);
      row.add(filteredStudents[i]['grades'][0]);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tabel Nilai - ${widget.className} (${widget.tableName})'),
        centerTitle: true,
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
                      // Dapatkan index asli dari data students
                      final originalIndex = widget.students.indexOf(student);
                      
                      return DataRow(
                        cells: [
                          DataCell(Text((index + 1).toString())),
                          DataCell(Text(student['name'])),
                          DataCell(
                            Container(
                              width: 100,
                              child: isEditing
                                  ? TextFormField(
                                      controller: controllers[originalIndex],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      onChanged: (value) => _updateGrade(originalIndex, value),
                                    )
                                  : Text(student['grades'][0].toString()),
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
            backgroundColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}