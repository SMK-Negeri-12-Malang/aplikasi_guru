import 'package:aplikasi_ortu/MUSYRIF/Detail_Kamar/studentpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';

class tugaskelas extends StatefulWidget {
  final String roomName;
  final List<String> students;

  tugaskelas({required this.roomName, required this.students});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<tugaskelas> {
  List<Map<String, dynamic>> tasks = [];
  bool isSelectionMode = false;
  Set<int> selectedTasks = Set<int>();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks_${widget.roomName}', jsonEncode(tasks));
  }

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksData = prefs.getString('tasks_${widget.roomName}');

    if (tasksData != null) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(jsonDecode(tasksData));
        // Ensure 'completed' field is always a boolean
        tasks.forEach((task) {
          if (task['completed'] == null) {
            task['completed'] = false;
          }
        });
      });
    }
  }

  void _addTask() {
    TextEditingController taskController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    List<String> selectedFiles = [];
    List<String> selectedImages = [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tambah Tugas"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                decoration: InputDecoration(hintText: "Nama Tugas"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(hintText: "Deskripsi Tugas"),
                maxLines: 3,
              ),
              SizedBox(height: 10),

              // Satu tombol untuk upload dokumen dan gambar
              ElevatedButton.icon(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'ppt', 'docx', 'jpg', 'png'],
                    allowMultiple: true,
                  );

                  if (result != null) {
                    for (var file in result.files) {
                      String path = file.path!;
                      if (path.endsWith('.jpg') || path.endsWith('.png')) {
                        selectedImages.add(path);
                      } else {
                        selectedFiles.add(path);
                      }
                    }
                    setState(() {});
                  }
                },
                icon: Icon(Icons.attach_file),
                label: Text("Upload Dokumen / Gambar"),
              ),
              SizedBox(height: 10),

              // Display selected images
              if (selectedImages.isNotEmpty)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: selectedImages.map((image) {
                    return Image.file(
                      File(image),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                if (taskController.text.isNotEmpty) {
                  setState(() {
                    tasks.add({
                      'name': taskController.text,
                      'description': descriptionController.text,
                      'created_at': "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                      'files': selectedFiles,
                      'images': selectedImages,
                      'completed': false,
                    });

                    _saveTasks();
                  });
                }
                Navigator.pop(context);
              },
              child: Text("Tambah"),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedTasks() {
    setState(() {
      tasks.removeWhere((task) => selectedTasks.contains(tasks.indexOf(task)));
      selectedTasks.clear();
      isSelectionMode = false;
      _saveTasks();
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      selectedTasks.clear();
    });
  }

  void _toggleTaskSelection(int index) {
    setState(() {
      if (selectedTasks.contains(index)) {
        selectedTasks.remove(index);
      } else {
        selectedTasks.add(index);
      }
    });
  }

  void _updateTaskCompletion(int index, bool completed) {
    setState(() {
      tasks[index]['completed'] = completed;
      _saveTasks();
    });
  }

  void _navigateToStudentPage(String taskName, String taskDescription, List<String> students, List<String> files, List<String> images) async {
    bool allStudentsCompleted = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentPage(
          taskName: taskName,
          taskDescription: taskDescription,
          students: students,
          files: files,
          images: images,
        ),
      ),
    );

    if (allStudentsCompleted) {
      setState(() {
        int taskIndex = tasks.indexWhere((task) => task['name'] == taskName);
        if (taskIndex != -1) {
          tasks[taskIndex]['completed'] = true;
          _saveTasks();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tugas di ${widget.roomName}"),
        backgroundColor: Colors.blue,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _toggleSelectionMode();
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Hapus Tugas'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: 'delete',
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  var task = tasks[index];
                  bool isSelected = selectedTasks.contains(index);

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    color: isSelected ? Colors.grey[300] : null,
                    child: ListTile(
                      onLongPress: () {
                        if (!isSelectionMode) {
                          _toggleSelectionMode();
                          _toggleTaskSelection(index);
                        }
                      },
                      onTap: () {
                        if (isSelectionMode) {
                          _toggleTaskSelection(index);
                        } else {
                          _navigateToStudentPage(
                            task['name'],
                            task['description'],
                            widget.students,
                            List<String>.from(task['files']),
                            List<String>.from(task['images']),
                          );
                        }
                      },
                      title: Text(task['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Dibuat pada: ${task['created_at']}", style: TextStyle(color: Colors.grey)),
                          Text("Deskripsi: ${task['description']}", style: TextStyle(color: Colors.black45)),

                          if (task['files'].isNotEmpty)
                            Text("📄 ${task['files'].length} Dokumen Terlampir", style: TextStyle(color: Colors.blue)),

                          if (task['images'].isNotEmpty)
                            Text("🖼 ${task['images'].length} Gambar Terlampir", style: TextStyle(color: Colors.green)),
                        ],
                      ),
                      trailing: isSelectionMode
                          ? Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                _toggleTaskSelection(index);
                              },
                            )
                          : Checkbox(
                              value: task['completed'],
                              onChanged: (value) {
                                _updateTaskCompletion(index, value!);
                              },
                            ),
                    ),
                  );
                },
              ),
            ),
            if (isSelectionMode)
              ElevatedButton(
                onPressed: _deleteSelectedTasks,
                child: Text("Hapus Tugas Terpilih"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}