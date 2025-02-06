import 'package:aplikasi_ortu/MUSYRIF/Detail_Kamar/studentpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Untuk menyimpan list sebagai JSON

class TaskPage extends StatefulWidget {
  final String roomName;
  final List<String> students;

  TaskPage({required this.roomName, required this.students});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<String> tasks = [];
  Map<String, bool> taskStatus = {};

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Ambil data dari penyimpanan saat pertama kali dibuka
  }

  // 📝 Fungsi untuk menyimpan daftar tugas ke SharedPreferences
  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', jsonEncode(tasks));
    await prefs.setString('taskStatus', jsonEncode(taskStatus));
  }

  // 🔄 Fungsi untuk mengambil data tugas saat aplikasi dibuka kembali
  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksData = prefs.getString('tasks');
    String? statusData = prefs.getString('taskStatus');

    if (tasksData != null) {
      setState(() {
        tasks = List<String>.from(jsonDecode(tasksData));
        taskStatus = Map<String, bool>.from(jsonDecode(statusData ?? '{}'));
      });
    }
  }

  // ➕ Tambah tugas baru
  void _addTask() {
    TextEditingController taskController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tambah Tugas"),
          content: TextField(
            controller: taskController,
            decoration: InputDecoration(hintText: "Nama Tugas"),
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
                    String newTask = taskController.text;
                    tasks.add(newTask);
                    taskStatus[newTask] = false;
                    _saveTasks(); // Simpan data ke penyimpanan
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

  // 🗑 Hapus tugas dari daftar
  void _deleteTask(String task) {
    setState(() {
      tasks.remove(task);
      taskStatus.remove(task);
      _saveTasks(); // Simpan perubahan
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tugas di ${widget.roomName}"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  String task = tasks[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(task),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: taskStatus[task],
                            onChanged: (value) {},
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(task),
                          ),
                        ],
                      ),
                      onTap: () async {
                        bool? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentPage(
                              taskName: task,
                              students: widget.students,
                            ),
                          ),
                        );

                        if (result == true) {
                          setState(() {
                            taskStatus[task] = true;
                            _saveTasks(); // Simpan status setelah checklist siswa selesai
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addTask,
              child: Text("Tambah Tugas"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
