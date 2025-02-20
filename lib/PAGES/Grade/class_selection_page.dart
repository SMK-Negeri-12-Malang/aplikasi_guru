import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'table_page.dart';
import 'rekap_page.dart'; // Import halaman rekap
import 'package:shimmer/shimmer.dart';

class ClassSelectionPage extends StatefulWidget {
  @override
  _ClassSelectionPageState createState() => _ClassSelectionPageState();
}

class _ClassSelectionPageState extends State<ClassSelectionPage> {
  final Map<String, List<String>> classTables = {};
  final Map<String, List<Map<String, dynamic>>> classStudents = {};
  final Map<String, String> classSubjects = {}; // Add this line
  bool isLoading = true;
  final List<String> gradeCategories = [
    'Tugas',
    'Ulangan',
    'UTS',
    'UAS',
    'Ujian Sekolah',
    'Ujian Nasional'
  ];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final response = await http.get(
        Uri.parse('https://67ac42f05853dfff53d9e093.mockapi.io/siswa')
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        
        // Initialize empty maps for each unique class
        Set<String> uniqueClasses = {};
        for (var student in data) {
          uniqueClasses.add(student['kelas'] ?? '');
        }

        setState(() {
          // Initialize data structures for each class
          for (String className in uniqueClasses) {
            classTables[className] = [];
            classStudents[className] = [];
          }

          // Populate students into their respective classes
          for (var student in data) {
            String className = student['kelas'] ?? '';
            classStudents[className]?.add({
              'id': student['id'],
              'name': student['name'],
              'class': className,
              'grades': {} // Initialize empty grades
            });
          }
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching students: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

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

  Widget _buildClassCard(String className, List<Map<String, dynamic>> students) {
    return Card(
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
                    Icon(Icons.class_, size: 40, color: const Color.fromARGB(255, 18, 84, 138)),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          className,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Jumlah Siswa: ${students.length}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.assessment, color: const Color.fromARGB(255, 27, 91, 143)),
                  onPressed: () => _navigateToRekapPage(className),
                ),
              ],
            ),
            Divider(height: 20),
            Text(
              'Kategori Nilai:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: gradeCategories.map((category) {
                return ActionChip(
                  label: Text(category),
                  onPressed: () => _navigateToTablePage(className, category),
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _navigateToTablePage(String className, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TablePage(
          className: className,
          tableName: category,
          students: classStudents[className]!,
          onSave: _updateStudentGrades,
        ),
      ),
    );
  }

  void _navigateToRekapPage(String className) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RekapPage(
          className: className,
          classStudents: classStudents[className]!,
          classTables: gradeCategories,
          onSave: (tableName, updatedStudents) {
            _updateStudentGrades(className, tableName, updatedStudents);
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      itemCount: 3, // Show 3 shimmer items while loading
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                height: 200,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 20,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8),
                            Container(
                              width: 150,
                              height: 15,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 100,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade900.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Kelas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pilih kelas untuk melihat nilai serta merekap nilai',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    isLoading
                        ? _buildShimmerLoading()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.all(16),
                            itemCount: classStudents.length,
                            itemBuilder: (context, index) {
                              String className = classStudents.keys.elementAt(index);
                              return Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: _buildClassCard(
                                  className,
                                  classStudents[className]!,
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
