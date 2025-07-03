import 'package:aplikasi_guru/SERVICE/task_manager_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart'; 
import 'package:intl/intl.dart';

class TaskDetailPage extends StatefulWidget {
  final Map<String, dynamic> task;
  final String className;
  final Function(Map<String, dynamic>) onTaskUpdated; 

  const TaskDetailPage({
    Key? key,
    required this.task,
    required this.className,
    required this.onTaskUpdated, 
  }) : super(key: key);

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TaskManagerService _taskManager = TaskManagerService();

  void _showFullImage() {
    Navigator.push( 
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: IconThemeData(color: const Color.fromARGB(255, 255, 255, 255)),
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: Image.file(
                widget.task['image'],
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _editTask() async {
    File? selectedImage = widget.task['image'];
    PlatformFile? selectedFile = widget.task['file'];
    String taskName = widget.task['name'] ?? '';
    String deadline = widget.task['deadline'] ?? '';
    String description = widget.task['description'] ?? '';
    String assignmentDate = widget.task['assignmentDate'] ?? '';
    String selectedMapel = widget.task['mapel'] ?? '';
    final List<String> mapelList = [
      'Matematika', 'Bahasa Indonesia', 'Bahasa Inggris', 'IPA', 'IPS', 'PPKN', 'Agama', 'Seni', 'PJOK', 'Lainnya'
    ];

    DateTime? selectedDeadlineDate = deadline.isNotEmpty ? DateTime.tryParse(deadline) : null;
    DateTime? selectedAssignmentDate = assignmentDate.isNotEmpty ? DateTime.tryParse(assignmentDate) : null;

    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Tugas'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedMapel.isNotEmpty ? selectedMapel : null,
                      items: mapelList.map((mapel) {
                        return DropdownMenuItem(
                          value: mapel,
                          child: Text(mapel),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Mata Pelajaran',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedMapel = value ?? '';
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Nama Tugas',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      controller: TextEditingController(text: taskName),
                      onChanged: (value) => taskName = value,
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        final DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: selectedAssignmentDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() {
                            selectedAssignmentDate = date;
                            assignmentDate = DateFormat('yyyy-MM-dd').format(date);
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.event_note, color: Colors.blue),
                            SizedBox(width: 10),
                            Text(
                              assignmentDate.isEmpty
                                  ? 'Pilih Tanggal Penugasan'
                                  : 'Penugasan: $assignmentDate',
                              style: TextStyle(
                                fontSize: 16,
                                color: assignmentDate.isEmpty ? Colors.grey : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        final DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: selectedDeadlineDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDeadlineDate = date;
                            deadline = DateFormat('yyyy-MM-dd').format(date);
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.blue),
                            SizedBox(width: 10),
                            Text(
                              deadline.isEmpty
                                  ? 'Pilih Deadline'
                                  : 'Deadline: $deadline',
                              style: TextStyle(
                                fontSize: 16,
                                color: deadline.isEmpty ? Colors.grey : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: InkWell(
                        onTap: () async {
                          FilePickerResult? result = await FilePicker.platform.pickFiles();
                          if (result != null) {
                            setState(() {
                              selectedFile = result.files.first;
                              selectedImage = null;
                            });
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              selectedFile != null
                                  ? Icons.file_present
                                  : Icons.upload_file,
                              size: 28,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 12),
                            Text(
                              selectedFile != null
                                  ? (selectedFile!.name.length > 20
                                      ? '${selectedFile!.name.substring(0, 20)}...'
                                      : selectedFile!.name)
                                  : 'Tambah File',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      controller: TextEditingController(text: description),
                      maxLines: 3,
                      onChanged: (value) => description = value,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'name': taskName,
                      'deadline': deadline,
                      'description': description,
                      'image': selectedImage,
                      'file': selectedFile,
                      'assignmentDate': assignmentDate,
                      'mapel': selectedMapel,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 16, 72, 129),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Simpan'),  
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      final updatedTask = {
        ...widget.task,
        'name': result['name'],
        'deadline': result['deadline'],
        'description': result['description'],
        'image': result['image'],
        'file': result['file'],
        'assignmentDate': result['assignmentDate'],
        'mapel': result['mapel'],
      };

      await _taskManager.updateTaskInClass(
        widget.className,
        widget.task['id'],
        updatedTask,
      );

      setState(() {
        widget.task.addAll(updatedTask);
      });
      widget.onTaskUpdated(widget.task);
    }
  }

  Widget _buildDeadlineInfo() {
    final now = DateTime.now();
    final deadline = DateFormat('yyyy-MM-dd').parse(widget.task['deadline']);
    final difference = deadline.difference(now).inDays;
    final isDeadlineNear = difference <= 3 && difference >= 0;
    final isOverdue = difference < 0;

    return Card(
      elevation: 4,
      color: isOverdue 
          ? Colors.red.shade50 
          : (isDeadlineNear ? Colors.orange.shade50 : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer,
                  color: isOverdue ? Colors.red : (isDeadlineNear ? Colors.orange : Colors.grey),
                ),
                SizedBox(width: 8),
                Text(
                  'Deadline',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              widget.task['deadline'],
              style: TextStyle(
                fontSize: 16,
                color: isOverdue ? Colors.red : (isDeadlineNear ? Colors.orange : Colors.black),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isOverdue || isDeadlineNear) ...[
              SizedBox(height: 8),
              Text(
                isOverdue 
                    ? 'Tugas sudah melewati deadline!'
                    : 'Deadline segera!',
                style: TextStyle(
                  color: isOverdue ? Colors.red : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header dengan gradient dan icon
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  spreadRadius: 2,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_turned_in_rounded, color: Colors.white, size: 28),
                        SizedBox(width: 10),
                        Text(
                          'Detail Tugas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: _editTask,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card utama info tugas
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    margin: EdgeInsets.only(bottom: 18),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama tugas dan badge selesai
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.task['name'] ?? '-',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E3F7F),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              if (widget.task['checked'] == true)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green[600],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'Selesai',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Divider(),
                          SizedBox(height: 8),
                          // Mata pelajaran
                          Row(
                            children: [
                              Icon(Icons.book, color: Colors.blue.shade700, size: 20),
                              SizedBox(width: 8),
                              Text('Mata Pelajaran:', style: TextStyle(fontWeight: FontWeight.w600)),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(widget.task['mapel'] ?? '-', style: TextStyle(color: Colors.black87)),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          // Kelas
                          Row(
                            children: [
                              Icon(Icons.class_, color: Colors.blue.shade700, size: 20),
                              SizedBox(width: 8),
                              Text('Kelas:', style: TextStyle(fontWeight: FontWeight.w600)),
                              SizedBox(width: 4),
                              Text(widget.className, style: TextStyle(color: Colors.black87)),
                            ],
                          ),
                          SizedBox(height: 8),
                          // Tanggal Penugasan
                          Row(
                            children: [
                              Icon(Icons.event_note, color: Colors.blue.shade700, size: 20),
                              SizedBox(width: 8),
                              Text('Tanggal Penugasan:', style: TextStyle(fontWeight: FontWeight.w600)),
                              SizedBox(width: 4),
                              Text(widget.task['assignmentDate'] ?? '-', style: TextStyle(color: Colors.black87)),
                            ],
                          ),
                          SizedBox(height: 8),
                          // Deadline
                          Row(
                            children: [
                              Icon(Icons.timer, color: Colors.blue.shade700, size: 20),
                              SizedBox(width: 8),
                              Text('Deadline:', style: TextStyle(fontWeight: FontWeight.w600)),
                              SizedBox(width: 4),
                              Text(widget.task['deadline'] ?? '-', style: TextStyle(color: Colors.black87)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // File/Gambar tugas
                  if (widget.task['image'] != null || widget.task['file'] != null)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: EdgeInsets.only(bottom: 18),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.attach_file, color: Color(0xFF2E3F7F)),
                                SizedBox(width: 8),
                                Text(
                                  'File/Gambar Tugas',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E3F7F),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            if (widget.task['image'] != null)
                              GestureDetector(
                                onTap: _showFullImage,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(
                                    widget.task['image'],
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            if (widget.task['file'] != null)
                              Container(
                                margin: EdgeInsets.only(top: 12),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.file_present, color: const Color.fromARGB(255, 16, 72, 129)),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: InkWell( 
                                        onTap: () async {
                                          final file = widget.task['file'];
                                          if (file != null) {
                                            try {
                                              final result = await OpenFile.open(file.path);
                                              if (result.type != ResultType.done) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Tidak dapat membuka file: ${result.message}'),
                                                    behavior: SnackBarBehavior.floating,
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Error: Tidak dapat membuka file'),
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.task['file'].name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${(widget.task['file'].size / 1024).toStringAsFixed(2)} KB',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.open_in_new, color: const Color.fromARGB(255, 16, 72, 129)),
                                      onPressed: () async {
                                        final file = widget.task['file'];
                                        if (file != null) {
                                          try {
                                            final result = await OpenFile.open(file.path);
                                            if (result.type != ResultType.done) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Tidak dapat membuka file: ${result.message}'),
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Error: Tidak dapat membuka file'),
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  // Info deadline
                  _buildDeadlineInfo(),
                  SizedBox(height: 18),
                  // Deskripsi tugas
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: 90,
                      ),
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.description, color: Color(0xFF2E3F7F)),
                              SizedBox(width: 8),
                              Text(
                                'Deskripsi Tugas',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            widget.task['description']?.isNotEmpty == true
                                ? widget.task['description']
                                : 'Tidak ada deskripsi',
                            style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
