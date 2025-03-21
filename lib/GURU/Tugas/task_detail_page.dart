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
    PlatformFile? selectedFile = widget.task['file']; // Add this line
    String taskName = widget.task['name'];
    String deadline = widget.task['deadline'];
    String description = widget.task['description'] ?? '';

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
                    Container(
                      height: 70,
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
                              size: 30,
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
                        labelText: 'Nama Tugas',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      controller: TextEditingController(text: taskName),
                      onChanged: (value) => taskName = value,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Deadline',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      controller: TextEditingController(text: deadline),
                      onChanged: (value) => deadline = value,
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
                      'file': selectedFile, // Add this line
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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
      };

      await _taskManager.updateTaskInClass(
        widget.className,
        widget.task['id'],
        updatedTask
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
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 80, 
        iconTheme: IconThemeData(color: Colors.white), 
        title: Text(
          'Detail Tugas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2E3F7F),
                Color(0xFF4557A4),
              ],
            ),
          ),
        ),
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: _editTask,
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.task['image'] != null || widget.task['file'] != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'File Tugas',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3F7F),
                        ),
                      ),
                      if (widget.task['image'] != null)
                        GestureDetector(
                          onTap: _showFullImage,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              widget.task['image'],
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else if (widget.task['file'] != null)
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.file_present, color: Colors.blue),
                              SizedBox(width: 10),
                              Expanded(
                                child: InkWell( // Wrap with InkWell
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
                                icon: Icon(Icons.open_in_new, color: Colors.blue), // Changed from download icon
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
            SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.task['name'],
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E3F7F),
                            ),
                          ),
                        ),
                        if (widget.task['checked'])
                          Chip(
                            label: Text(
                              'Selesai',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Colors.green,
                          ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      widget.className,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildDeadlineInfo(),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                width: double.infinity, // Full width
                constraints: BoxConstraints(
                  minHeight: 200, // Minimum height
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deskripsi Tugas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.task['description'] ?? 'Tidak ada deskripsi',
                      style: TextStyle(fontSize: 16),
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
