import 'package:aplikasi_guru/SERVICE/grade_service.dart';
import 'package:aplikasi_guru/SERVICE/grade_state_service.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

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
  List<String> columns = ['Nilai'];
  bool hasUnsavedChanges = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _gradeService.addListener(_onGradesUpdated);
    _loadSavedGrades().then((_) {
      if (widget.students.isEmpty) {
        _fetchStudents();
      } else {
        setState(() {
          filteredStudents = List.from(widget.students);
          _initializeControllers();
          isLoadingData = false;
        });
      }
    });
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

  Future<void> _loadSavedGrades() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gradesKey = '${widget.className}_${widget.tableName}_grades';
      final savedGradesString = prefs.getString(gradesKey);

      if (savedGradesString != null) {
        final Map<String, dynamic> savedGrades = json.decode(savedGradesString);
        
        setState(() {
          for (var student in widget.students) {
            final String studentId = student['id'].toString();
            if (savedGrades.containsKey(studentId)) {
              student['grades'] = Map<String, dynamic>.from(savedGrades[studentId]);
              // Update the grade service
              _gradeService.updateStudentGrade(
                widget.className,
                studentId,
                widget.tableName,
                savedGrades[studentId][widget.tableName] ?? 0
              );
            }
          }
          filteredStudents = List.from(widget.students);
        });
      }
    } catch (e) {
      print('Error loading saved grades: $e');
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

  Future<void> _saveGrades() async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi'),
          content: Text('Apakah Anda yakin ingin menyimpan nilai?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Batal', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Simpan', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 76, 175, 101),
              ),
            ),
          ],
        );
      },
    ) ?? false;

    if (!confirm) return;

    // Show loading dialog
    setState(() => isSaving = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Card(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Menyimpan nilai...'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    try {
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final gradesKey = '${widget.className}_${widget.tableName}_grades';
      
      Map<String, dynamic> gradesData = {};
      for (var student in widget.students) {
        gradesData[student['id'].toString()] = student['grades'];
      }
      
      await prefs.setString(gradesKey, jsonEncode(gradesData));

      // Update state service and call onSave
      for (int i = 0; i < widget.students.length; i++) {
        final student = widget.students[i];
        final grade = student['grades']?[widget.tableName] ?? 0;
        
        _gradeService.updateStudentGrade(
          widget.className,
          student['id'].toString(),
          widget.tableName,
          grade
        );
      }

      widget.onSave(widget.className, widget.tableName, widget.students);
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [    
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Berhasil!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Nilai telah berhasil disimpan'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('ok', style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(100, 40),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      setState(() {
        hasUnsavedChanges = false;
        isEditing = false;
        isSaving = false;
      });

    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error dialog
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Gagal menyimpan nilai: $e'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          );
        },
      );

      setState(() => isSaving = false);
    }
  }

  Future<void> _downloadCSV() async {
    try {
      // Create a new Excel document
      var excel = Excel.createExcel();
      String sheetName = 'Nilai ${widget.tableName}';
      excel.rename('Sheet1', sheetName);
      
      // Get the sheet
      var sheet = excel[sheetName];

      // Add headers with style
      var headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('1565C0'),
        fontColorHex: ExcelColor.fromHexString('FFFFFF'),
        horizontalAlign: HorizontalAlign.Center,
      );

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        ..value = TextCellValue('No. Absen')
        ..cellStyle = headerStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
        ..value = TextCellValue('Nama Siswa')
        ..cellStyle = headerStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
        ..value = TextCellValue('Nilai')
        ..cellStyle = headerStyle;

      // Add data with cell style
      var dataStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
      );

      for (int i = 0; i < filteredStudents.length; i++) {
        var rowIndex = i + 1;
        
        // No Absen
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          ..value = TextCellValue((i + 1).toString())
          ..cellStyle = dataStyle;
        
        // Nama Siswa
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          ..value = filteredStudents[i]['name']
          ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Left);
        
        // Nilai
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          ..value = TextCellValue(
              filteredStudents[i]['grades'][widget.tableName] != null && 
              filteredStudents[i]['grades'][widget.tableName] != 0 
                  ? filteredStudents[i]['grades'][widget.tableName].toString() 
                  : '-')
          ..cellStyle = dataStyle;
      }

      // Set column widths
      sheet.setColumnWidth(0, 15);
      sheet.setColumnWidth(1, 35);
      sheet.setColumnWidth(2, 15);

      try {
        // Get downloads directory for Android or documents directory for iOS
        final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
        final fileName = '${widget.className}_${widget.tableName}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        final filePath = '${directory.path}/$fileName';
        
        final file = File(filePath);
        await file.writeAsBytes(excel.encode()!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('File Excel berhasil disimpan di:\n$filePath')),
              ],
            ),
            backgroundColor: const Color.fromARGB(255, 76, 175, 101),
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.all(16),
          ),
        );
      } catch (e) {
        throw Exception('Gagal menyimpan file: $e');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Error: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  void _editTask() {
    if (isEditing) {
      _saveGrades();
      setState(() {
        isEditing = false;
      });
    } else {
      setState(() {
        isEditing = true;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (isEditing && hasUnsavedChanges) {
      bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Perubahan Belum Disimpan'),
            content: Text('Anda memiliki perubahan yang belum disimpan. Apakah Anda yakin ingin keluar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Batal', style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('keluar', style: TextStyle(color: const Color.fromARGB(255, 250, 249, 249))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          );
        },
      ) ?? false;
      return confirm;
    }
    return true;
  }

  String _getPredicate(int nilai) {
    if (nilai >= 91) return 'A+ ';
    if (nilai >= 81) return 'A ';
    if (nilai >= 76) return 'A- ';
    if (nilai >= 71) return 'B+ ';
    if (nilai >= 61) return 'B ';
    if (nilai >= 51) return 'B-';
    if (nilai >= 41) return 'C+ ';
    if (nilai >= 31) return 'C ';
    if (nilai >= 26) return 'C- ';
    if (nilai >= 16) return 'D+ ';
    if (nilai >= 6) return 'D ';
    if (nilai >= 1) return 'D- ';
    return 'N/A';
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              const Color.fromARGB(255, 16, 89, 150),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat data nilai...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: Stack(
                    children: [
                      Positioned(
                        left: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () async {
                              if (await _onWillPop()) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '${widget.className} (${widget.tableName})',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoadingData
                  ? _buildLoadingIndicator()
                  : Padding(
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
                                          DataColumn(label: Text('Predikat')), 
                                        ],
                                        rows: List.generate(filteredStudents.length, (index) {
                                          final student = filteredStudents[index];
                                          int studentIndex = widget.students.indexOf(student);
                                          final nilai = student['grades']?[widget.tableName] ?? 0;
                                          final predicate = _getPredicate(nilai);
                                          
                                          return DataRow(
                                            cells: [
                                              DataCell(Text((index + 1).toString())),
                                              DataCell(Text(student['name'])),
                                              DataCell(
                                                isEditing
                                                    ? TextFormField(
                                                        initialValue: nilai != 0 ? nilai.toString() : '',
                                                        keyboardType: TextInputType.number,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            student['grades'] ??= {};
                                                            student['grades'][widget.tableName] = value.isEmpty ? 0 : int.tryParse(value) ?? 0;
                                                            hasUnsavedChanges = true;
                                                          });
                                                        },
                                                      )
                                                    : Text(nilai != 0 ? nilai.toString() : '-'),
                                              ),
                                              DataCell(Text(predicate)), 
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
        floatingActionButton: isLoadingData
            ? null
            : Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FloatingActionButton.small(
                              heroTag: 'edit',
                              onPressed: _editTask,
                              child: Icon(isEditing ? Icons.save : Icons.edit),
                              backgroundColor: isEditing 
                                ? const Color.fromARGB(255, 140, 175, 76) 
                                : const Color.fromARGB(255, 152, 243, 33),
                              tooltip: isEditing ? 'Simpan Nilai' : 'Edit Nilai',
                            ),
                            SizedBox(height: 8),
                            FloatingActionButton.small(
                              heroTag: 'download',
                              onPressed: () async {
                                bool confirm = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Konfirmasi Unduh'),
                                      content: Text('Apakah Anda yakin ingin mengunduh data nilai dalam format Excel?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: Text('Batal'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: Text('Unduh'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromARGB(255, 19, 184, 19),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ) ?? false;

                                if (confirm) {
                                  await _downloadCSV();
                                }
                              },
                              child: Icon(Icons.download),
                              backgroundColor: const Color.fromARGB(255, 19, 184, 19),
                              tooltip: 'Unduh CSV',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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

  Widget _buildShimmerTable() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: [
              DataColumn(label: Container(width: 80, height: 20, color: Colors.white)),
              DataColumn(label: Container(width: 150, height: 20, color: Colors.white)),
              DataColumn(label: Container(width: 80, height: 20, color: Colors.white)),
              DataColumn(label: Container(width: 80, height: 20, color: Colors.white)), 
            ],
            rows: List.generate(10, (index) => DataRow(cells: [
              DataCell(Container(width: 80, height: 20, color: Colors.white)),
              DataCell(Container(width: 150, height: 20, color: Colors.white)),
              DataCell(Container(width: 80, height: 20, color: Colors.white)),
              DataCell(Container(width: 80, height: 20, color: Colors.white)), 
            ])),
          ),
        ),
      ),
    );
  }
}
