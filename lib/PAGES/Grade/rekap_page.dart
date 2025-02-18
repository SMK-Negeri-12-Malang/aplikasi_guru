import 'package:aplikasi_ortu/services/grade_state_service.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

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
    _initializeData();
  }

  @override
  void dispose() {
    _gradeService.removeListener(_onGradesUpdated);
    searchController.dispose();
    super.dispose();
  }

  void _initializeData() {
    setState(() {
      final latestData = _gradeService.getStudentsForClass(widget.className);
      if (latestData.isNotEmpty) {
        filteredStudents = latestData;
        widget.classStudents.clear();
        widget.classStudents.addAll(latestData);
      } else {
        filteredStudents = List.from(widget.classStudents);
      }
      isLoading = false;
    });
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
      final updatedStudents = _gradeService.getStudentsForClass(widget.className);
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
    if (grades.isEmpty || widget.classTables.isEmpty) return 0.0;
    
    double total = 0;
    int count = 0;
    
    for (var category in widget.classTables) {
      var grade = grades[category];
      if (grade != null) {
        total += (grade as num).toDouble();
        count++;
      }
    }
    
    return count > 0 ? total / count : 0.0;
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
                  ? _buildShimmerTable()
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
                                ],
                                rows: filteredStudents.asMap().entries.map((entry) {
                                  var student = entry.value;
                                  var grades = student['grades'] ?? {};
                                  double average = _calculateAverage(grades);

                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${entry.key + 1}')),
                                      DataCell(Text(student['name'] ?? '')),
                                      ...widget.classTables.map((category) =>
                                        DataCell(_buildGradeCell(grades[category], category: category)),
                                      ),
                                      DataCell(_buildGradeCell(average.toStringAsFixed(1))),
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
      floatingActionButton: isLoading
          ? null
          : FloatingActionButton(
              heroTag: 'download',
              onPressed: () {
                // Implement CSV download here if needed
              },
              child: Icon(Icons.download),
              backgroundColor: Colors.orange,
            ),
    );
  }
}