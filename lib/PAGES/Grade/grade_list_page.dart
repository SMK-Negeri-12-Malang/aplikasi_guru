import 'package:aplikasi_ortu/PAGES/Grade/add_column_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/animations.dart';
import 'add_task_dialog.dart';

class GradeListPage extends StatefulWidget {
  final String className;
  final Function(String, List<String>) onTableUpdate;

  GradeListPage({
    required this.className,
    required this.onTableUpdate,
  });

  @override
  _GradeListPageState createState() => _GradeListPageState();
}

class _GradeListPageState extends State<GradeListPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Map<String, dynamic>> students = [];
  Map<String, List<Map<String, dynamic>>> tasks = {
    'Tugas': [],
    'Ulangan': []
  };
  bool isLoading = true;
  bool isEditMode = false; // Add this property

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('https://67ac42f05853dfff53d9e093.mockapi.io/siswa')
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          students = List<Map<String, dynamic>>.from(
            data.where((student) => student['kelas'] == widget.className)
          );
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => isLoading = false);
    }
  }

  void _addTask(String type) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddTaskDialog(),
    );

    if (result != null) {
      setState(() {
        tasks[type]!.add(result);
        // Update all students with new task
        for (var student in students) {
          if (student['grades'] == null) {
            student['grades'] = {};
          }
          student['grades'][result['title']] = 0;
        }
      });
      // Update tables in rekap page
      List<String> allTables = [...tasks['Tugas']!.map((t) => t['title']),
                               ...tasks['Ulangan']!.map((t) => t['title'])];
      widget.onTableUpdate(widget.className, allTables);
    }
  }

  void _editColumnTitle(String type, int index) async {
    final TextEditingController textController = TextEditingController(
      text: tasks[type]![index]['title']
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Judul Kolom'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: 'Judul Baru',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, textController.text),
            child: Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        String oldTitle = tasks[type]![index]['title'];
        tasks[type]![index]['title'] = result;
        
        // Update grades with new column name
        for (var student in students) {
          if (student['grades'] != null && student['grades'].containsKey(oldTitle)) {
            student['grades'][result] = student['grades'][oldTitle];
            student['grades'].remove(oldTitle);
          }
        }
      });
      _updateRekapTables();
    }
    textController.dispose();
  }

  void _addColumn(String type) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddColumnDialog(type: type),
    );

    if (result != null) {
      setState(() {
        tasks[type]!.add(result);
        // Initialize grades for new column
        for (var student in students) {
          student['grades'] ??= {};
          student['grades'][result['title']] = 0;
        }
      });
      _updateRekapTables();
    }
  }

  void _updateRekapTables() {
    List<String> allTables = [
      ...tasks['Tugas']!.map((t) => t['title']),
      ...tasks['Ulangan']!.map((t) => t['title'])
    ];
    widget.onTableUpdate(widget.className, allTables);
  }

  void _toggleEditMode() {
    setState(() {
      isEditMode = !isEditMode;
    });
  }

  void _saveChanges() {
    // Here you would typically save to your backend
    setState(() {
      isEditMode = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Perubahan berhasil disimpan'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelas ${widget.className}'),
        actions: [
          if (isEditMode)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveChanges,
              tooltip: 'Simpan Perubahan',
            ),
          IconButton(
            icon: Icon(isEditMode ? Icons.edit_off : Icons.edit),
            onPressed: _toggleEditMode,
            tooltip: isEditMode ? 'Matikan Mode Edit' : 'Aktifkan Mode Edit',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value.startsWith('add_')) {
                _addColumn(value.substring(4));
              } else {
                _addTask(value);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'add_Tugas',
                child: Text('Tambah Kolom Tugas'),
              ),
              PopupMenuItem(
                value: 'add_Ulangan',
                child: Text('Tambah Kolom Ulangan'),
              ),
              PopupMenuItem(
                value: 'Tugas',
                child: Text('Tambah Tugas'),
              ),
              PopupMenuItem(
                value: 'Ulangan',
                child: Text('Tambah Ulangan'),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DataTable(
                      columns: [
                        DataColumn(label: Text('No')),
                        DataColumn(label: Text('Nama')),
                        ...tasks['Tugas']!.asMap().entries.map((entry) =>
                          DataColumn(
                            label: GestureDetector(
                              onTap: isEditMode ? () => _editColumnTitle('Tugas', entry.key) : null,
                              child: Tooltip(
                                message: entry.value['description'] ?? '',
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(entry.value['title']),
                                    if (isEditMode) Icon(Icons.edit, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        ...tasks['Ulangan']!.asMap().entries.map((entry) =>
                          DataColumn(
                            label: GestureDetector(
                              onTap: isEditMode ? () => _editColumnTitle('Ulangan', entry.key) : null,
                              child: Tooltip(
                                message: entry.value['description'] ?? '',
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(entry.value['title']),
                                    if (isEditMode) Icon(Icons.edit, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      rows: students.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var student = entry.value;
                        return DataRow(
                          cells: [
                            DataCell(Text('${idx + 1}')),
                            DataCell(Text(student['name'])),
                            ...tasks['Tugas']!.map((task) =>
                              DataCell(
                                isEditMode
                                    ? TextFormField(
                                        initialValue: student['grades']?[task['title']]?.toString() ?? '0',
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          student['grades'] ??= {};
                                          student['grades'][task['title']] = int.tryParse(value) ?? 0;
                                        },
                                      )
                                    : Text(student['grades']?[task['title']]?.toString() ?? '0'),
                              ),
                            ),
                            ...tasks['Ulangan']!.map((task) =>
                              DataCell(
                                isEditMode
                                    ? TextFormField(
                                        initialValue: student['grades']?[task['title']]?.toString() ?? '0',
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          student['grades'] ??= {};
                                          student['grades'][task['title']] = int.tryParse(value) ?? 0;
                                        },
                                      )
                                    : Text(student['grades']?[task['title']]?.toString() ?? '0'),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
