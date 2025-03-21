import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'table_page.dart';
import 'rekap_page.dart'; 
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? selectedSubject; // Add this line
  List<String> subjects = ['Bahasa Indonesia', 'Matematika', 'IPA', 'IPS', 'Bahasa Inggris']; // Add this line

  @override
  void initState() {
    super.initState();
    _loadSavedDataAndFetchStudents();
  }

  Future<void> _loadSavedDataAndFetchStudents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await _fetchStudents(); // First fetch students

      // After fetching students, load saved grades for each class and category
      for (String className in classStudents.keys) {
        for (String category in gradeCategories) {
          final gradesKey = '${className}_${category}_grades';
          final savedGradesString = prefs.getString(gradesKey);

          if (savedGradesString != null) {
            final Map<String, dynamic> savedGrades = json.decode(savedGradesString);
            
            // Update grades for students in this class
            for (var student in classStudents[className]!) {
              final String studentId = student['id'].toString();
              if (savedGrades.containsKey(studentId)) {
                student['grades'] ??= {};
                student['grades'][category] = savedGrades[studentId][category] ?? 0;
              }
            }
          }
        }
      }

      // Update state to refresh UI
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading saved grades: $e');
    }
  }

  Future<void> _fetchStudents() async {
    setState(() => isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse('https://67ac42f05853dfff53d9e093.mockapi.io/siswa')
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        Set<String> uniqueClasses = {};
        
        // First pass: collect unique classes
        for (var student in data) {
          uniqueClasses.add(student['kelas'] ?? '');
        }

        // Initialize data structures
        for (String className in uniqueClasses) {
          classTables[className] = [];
          classStudents[className] = [];
        }

        // Second pass: populate students with initialized grades
        for (var student in data) {
          String className = student['kelas'] ?? '';
          Map<String, dynamic> grades = {};
          
          // Initialize all grade categories to 0
          for (String category in gradeCategories) {
            grades[category] = 0;
          }

          classStudents[className]?.add({
            'id': student['id'],
            'name': student['name'],
            'class': className,
            'grades': grades
          });
        }
      }
    } catch (e) {
      print('Error fetching students: $e');
    } finally {
      setState(() => isLoading = false);
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

  double _getCategoryCompletion(String className, String category) {
    final students = classStudents[className]!;
    int totalStudents = students.length;
    int filledGrades = 0;

    for (var student in students) {
      final grades = student['grades']?[category];
      if (grades != null && grades != 0) {
        filledGrades++;
      }
    }

    return totalStudents > 0 ? (filledGrades / totalStudents) : 0.0;
  }

  Color _getCompletionColor(double percentage) {
    if (percentage == 0) {
      return Colors.grey.shade100;
    }
    
    // Create a gradient from white to green based on percentage
    int green = (percentage * 255).round();
    return Color.fromRGBO(255 - (green ~/ 2), 255, 255 - (green ~/ 2), 1.0);
  }

  Widget _buildCategoryChip(String label, bool isComplete, String className) {
    double completion = _getCategoryCompletion(className, label);
    Color chipColor = _getCompletionColor(completion);
    
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
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              chipColor,
              Colors.white,
            ],
            stops: [completion, 1.0],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label, 
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 4),
              Text(
                '${(completion * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassCard(String className, List<Map<String, dynamic>> students) {
    // Define subject names based on class
    Map<String, String> subjectNames = {
      'Kelas 7A': 'Bahasa Indonesia',
      'Kelas 7B': 'Bahasa Thailand',
      // Add more classes and their subjects as needed
    };

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
                    Icon(Icons.class_, size: 40, color: const Color.fromARGB(255, 18, 87, 143)),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          className,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Mata Pelajaran: ${subjectNames[className] ?? ""}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.assessment, color: const Color.fromARGB(255, 44, 180, 90)),
                  iconSize: 30,
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
                return _buildCategoryChip(category, false, className);
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
    // Initialize grades for all students before navigation
    List<Map<String, dynamic>> preparedStudents = classStudents[className]!.map((student) {
      // Create a new map with proper typing and initialized grades
      Map<String, dynamic> grades = {};
      for (String category in gradeCategories) {
        grades[category] = student['grades']?[category] ?? 0;
      }

      return {
        'id': student['id']?.toString() ?? '',
        'name': student['name']?.toString() ?? '',
        'class': student['class']?.toString() ?? '',
        'grades': grades,
      };
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RekapPage(
          className: className,
          classStudents: preparedStudents,
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
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22), // reduced vertical padding
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
                          fontSize: 24, // reduced font size
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4), // reduced spacing
                  Text(
                    'Pilih kelas untuk melihat nilai serta merekap nilai',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14, // reduced font size
                    ),
                  ),
                  SizedBox(height: 10), // reduced spacing
                  // Add Subject Dropdown
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text('Pilih Mata Pelajaran'),
                        value: selectedSubject,
                        items: subjects.map((String subject) {
                          return DropdownMenuItem<String>(
                            value: subject,
                            child: Text(subject),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedSubject = newValue;
                          });
                        },
                      ),
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
