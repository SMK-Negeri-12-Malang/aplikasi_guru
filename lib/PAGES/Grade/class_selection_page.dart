import 'dart:math';
import 'package:flutter/material.dart';
import 'table_page.dart';
import 'rekap_page.dart'; // Import halaman rekap

class ClassSelectionPage extends StatefulWidget {
  @override
  _ClassSelectionPageState createState() => _ClassSelectionPageState();
}

class _ClassSelectionPageState extends State<ClassSelectionPage> {
  final Map<String, List<String>> classTables = {
    'Kelas XI A': [],
    'Kelas XI B': [],
    'Kelas XI C': [],
  };

  final Map<String, List<Map<String, dynamic>>> classStudents = {
    'Kelas XI A': [
      {'name': 'Siswa A1', 'grades': {}},
      {'name': 'Siswa A2', 'grades': {}},
      {'name': 'Siswa A3', 'grades': {}},
    ],
    'Kelas XI B': [
      {'name': 'Siswa B1', 'grades': {}},
      {'name': 'Siswa B2', 'grades': {}},
      {'name': 'Siswa B3', 'grades': {}},
    ],
    'Kelas XI C': [
      {'name': 'Siswa C1', 'grades': {}},
      {'name': 'Siswa C2', 'grades': {}},
      {'name': 'Siswa C3', 'grades': {}},
    ],
  };

  final Map<String, String> classSubjects = {
    'Kelas XI A': 'Matematika',
    'Kelas XI B': 'Biologi',
    'Kelas XI C': 'Ekonomi',
  };

  void _addTable(String className) {
    TextEditingController tableController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Tambah Tabel Baru', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: tableController,
            decoration: InputDecoration(
              labelText: 'Judul Tabel',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Batal', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('Tambah'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (tableController.text.isNotEmpty) {
                  setState(() {
                    classTables[className]!.add(tableController.text);
                    for (var student in classStudents[className]!) {
                      student['grades'][tableController.text] = 0;
                    }
                  });
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TablePage(
                        className: className,
                        tableName: tableController.text,
                        students: classStudents[className]!,
                        onSave: _updateStudentGrades,
                      ),
                      settings: RouteSettings(
                        arguments: tableController.text,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _updateStudentGrades(String className, String tableName, List<Map<String, dynamic>> updatedStudents) {
    setState(() {
      classStudents[className] = updatedStudents;
    });
  }

  void _showClassCard(String className) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.book, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              className,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mata Pelajaran: ${classSubjects[className]}'),
            SizedBox(height: 16),
            Divider(),
            Text(
              'Kategori Evaluasi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCategoryChip('Tugas', _isTableComplete(className, 'Tugas'), className),
                _buildCategoryChip('Ulangan', _isTableComplete(className, 'Ulangan'), className),
                _buildCategoryChip('UTS', _isTableComplete(className, 'UTS'), className),
                _buildCategoryChip('UAS', _isTableComplete(className, 'UAS'), className),
                _buildCategoryChip('Ujian Sekolah', _isTableComplete(className, 'Ujian Sekolah'), className),
                _buildCategoryChip('Ujian Nasional', _isTableComplete(className, 'Ujian Nasional'), className),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  bool _isTableComplete(String className, String tableName) {
    final students = classStudents[className]!;
    final table = classTables[className]!.contains(tableName);
    if (!table) return false;

    for (var student in students) {
      final grades = student['grades'][tableName];
      if (grades == null || grades == 0) {
        return false;
      }
    }
    return true;
  }

  Widget _buildCategoryChip(String label, bool isComplete, String className) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TablePage(
              className: className,
              tableName: label,
              students: classStudents[className]!,
              onSave: _updateStudentGrades,
            ),
          ),
        );
      },
      child: Chip(
        label: Text(label, style: TextStyle(fontSize: 12)),
        backgroundColor: isComplete ? Colors.green.shade100 : Colors.grey.shade300,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            // Header Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.school, size: 50, color: Colors.white),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Pilih Kelas Anda',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Class List
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: classTables.keys.length,
              itemBuilder: (context, index) {
                String className = classTables.keys.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.class_, size: 40, color: Colors.blue),
                                  SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        className,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Mata Pelajaran: ${classSubjects[className]}',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.assessment, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RekapPage(
                                        className: className,
                                        classStudents: classStudents[className]!,
                                        classTables: classTables[className]!, onSave: (String tableName, List<Map<String, dynamic>> updatedStudents) { _updateStudentGrades(className, tableName, updatedStudents); },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          Divider(height: 20, thickness: 1, color: Colors.grey[300]),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildCategoryChip('Tugas', _isTableComplete(className, 'Tugas'), className),
                              _buildCategoryChip('Ulangan', _isTableComplete(className, 'Ulangan'), className),
                              _buildCategoryChip('UTS', _isTableComplete(className, 'UTS'), className),
                              _buildCategoryChip('UAS', _isTableComplete(className, 'UAS'), className),
                              _buildCategoryChip('Ujian Sekolah', _isTableComplete(className, 'Ujian Sekolah'), className),
                              _buildCategoryChip('Ujian Nasional', _isTableComplete(className, 'Ujian Nasional'), className),
                            ],
                          ),
                          Column(
                            children: classTables[className]!.map((table) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  table,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                onTap: () {
                                  _showClassCard(className);
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
