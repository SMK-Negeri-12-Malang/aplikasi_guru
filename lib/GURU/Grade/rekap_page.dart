import 'package:aplikasi_ortu/SERVISCE/grade_state_service.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final GradeStateService _gradeService = GradeStateService();
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredStudents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _gradeService.addListener(_onGradesUpdated);
    _loadSavedGradesAndInitialize();
  }

  @override
  void dispose() {
    _gradeService.removeListener(_onGradesUpdated);
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedGradesAndInitialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load grades for each category
      for (String category in widget.classTables) {
        final gradesKey = '${widget.className}_${category}_grades';
        final savedGradesString = prefs.getString(gradesKey);

        if (savedGradesString != null) {
          final Map<String, dynamic> savedGrades = json.decode(savedGradesString);
          
          // Update grades for each student
          for (var student in widget.classStudents) {
            final String studentId = student['id'].toString();
            if (savedGrades.containsKey(studentId)) {
              student['grades'] ??= {};
              student['grades'][category] = savedGrades[studentId][category] ?? 0;
            }
          }
        }
      }
    } catch (e) {
      print('Error loading saved grades: $e');
    } finally {
      _initializeData(); // Call initialize after loading saved grades
    }
  }

  void _initializeData() {
    try {
      setState(() {
        // Create a deep copy of students with properly initialized grades
        List<Map<String, dynamic>> initializedStudents = widget.classStudents.map((student) {
          // Ensure grades map exists
          Map<String, dynamic> grades = Map<String, dynamic>.from(
            student['grades'] as Map<dynamic, dynamic>? ?? {}
          );
          
          // Initialize missing grade categories with 0
          for (String category in widget.classTables) {
            if (!grades.containsKey(category)) {
              grades[category] = 0;
            }
          }
          
          return {
            'id': student['id']?.toString() ?? '',
            'name': student['name']?.toString() ?? '',
            'class': student['class']?.toString() ?? '',
            'grades': grades,
          };
        }).toList();

        // Update the students list
        widget.classStudents.clear();
        widget.classStudents.addAll(initializedStudents);
        filteredStudents = List.from(initializedStudents);
        isLoading = false;
      });
    } catch (e) {
      print('Error initializing data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredStudents = List.from(widget.classStudents);
      } else {
        filteredStudents = widget.classStudents
            .where((student) => student['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _onGradesUpdated() {
    if (mounted) {
      List<Map<String, dynamic>> updatedStudents = _gradeService.getStudentsForClass(widget.className);
      
      // Initialize grades for updated students
      updatedStudents = updatedStudents.map((student) {
        if (student['grades'] == null) {
          student['grades'] = {};
        }
        
        // Initialize missing grade categories with 0
        for (String category in widget.classTables) {
          if (student['grades'][category] == null) {
            student['grades'][category] = 0;
          }
        }
        return student;
      }).toList();

      setState(() {
        widget.classStudents.clear();
        widget.classStudents.addAll(updatedStudents);
        filteredStudents = List.from(widget.classStudents);
      });
    }
  }

  Widget _buildShimmerTable() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          // Search bar shimmer
          Container(
            height: 50,
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          // Table header shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(
                7, // Number of columns (No, Name, and 5 grade categories)
                (index) => Expanded(
                  flex: index == 1 ? 2 : 1, // Name column is wider
                  child: Container(
                    height: 40,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          // Table rows shimmer
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: List.generate(
                      7,
                      (colIndex) => Expanded(
                        flex: colIndex == 1 ? 2 : 1,
                        child: Container(
                          height: 30,
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeCell(dynamic value, {String? category}) {
    final displayValue = value?.toString() ?? '0';
    final isZero = value == 0 || value == null;

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isZero ? Colors.grey[200] : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        displayValue,
        style: TextStyle(
          color: isZero ? Colors.grey[600] : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  double _calculateAverage(Map<String, dynamic> grades) {
    if (widget.classTables.isEmpty) return 0.0;
    
    double total = 0;
    int count = 0;
    
    for (String category in widget.classTables) {
      var grade = grades[category];
      if (grade != null) {
        total += (grade is num ? grade : 0).toDouble();
        count++;
      }
    }
    
    return count > 0 ? total / count : 0.0;
  }

  String _getPredicate(double average) {
    if (average >= 91) return 'A+ ';
    if (average >= 81) return 'A ';
    if (average >= 76) return 'A- ';
    if (average >= 71) return 'B+ ';
    if (average >= 61) return 'B ';
    if (average >= 51) return 'B-';
    if (average >= 41) return 'C+ ';
    if (average >= 31) return 'C ';
    if (average >= 26) return 'C- ';
    if (average >= 16) return 'D+ ';
    if (average >= 6) return 'D ';
    if (average >= 1) return 'D- ';
    return 'N/A';
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              const Color.fromARGB(255, 16, 90, 150),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat rekap nilai...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Mohon tunggu sebentar',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
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
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 16, 90, 150),
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
                  Expanded(
                    child: Text(
                      'Rekap Nilai - ${widget.className}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 40), // Balance the back button
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? _buildLoadingIndicator() // Replace shimmer with new loading indicator
                  : widget.classStudents.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada data siswa untuk kelas ini.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                  labelText: 'Cari Siswa',
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onChanged: _filterStudents,
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(
                                  child: DataTable(
                                    columns: [
                                      DataColumn(label: Text('No')),
                                      DataColumn(label: Text('Nama Siswa')),
                                      ...widget.classTables.map((category) =>
                                        DataColumn(
                                          label: Tooltip(
                                            message: 'Nilai $category',
                                            child: Text(
                                              category,
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(label: Text('Rata-rata')),
                                      DataColumn(label: Text('Predikat')),
                                    ],
                                    rows: filteredStudents.asMap().entries.map((entry) {
                                      var student = entry.value;
                                      var grades = student['grades'] ?? {};
                                      double average = _calculateAverage(grades);
                                      String predicate = _getPredicate(average);

                                      return DataRow(
                                        cells: [
                                          DataCell(Text('${entry.key + 1}')),
                                          DataCell(Text(student['name'] ?? '')),
                                          ...widget.classTables.map((category) =>
                                            DataCell(_buildGradeCell(grades[category], category: category)),
                                          ),
                                          DataCell(_buildGradeCell(average.toStringAsFixed(1))),
                                          DataCell(Text(predicate)),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: isLoading || widget.classStudents.isEmpty
          ? null
          : FloatingActionButton(
              heroTag: 'download',
              onPressed: () {
                // Implement CSV download here if needed
              },
              child: Icon(Icons.download),
              backgroundColor: const Color.fromARGB(255, 11, 189, 70),
            ),
    );
  }
}