import 'package:flutter/material.dart';

class DetailKelasA extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<DetailKelasA> {
  List<Map<String, dynamic>> tasks = [];

  void _addTask() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController titleController = TextEditingController();
        TextEditingController descController = TextEditingController();
        DateTime? selectedDate;

        return AlertDialog(
          title: Text("Tambah Tugas"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Judul Tugas"),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: "Deskripsi Tugas"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                child: Text("Pilih Tanggal"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && selectedDate != null) {
                  setState(() {
                    tasks.add({
                      "title": titleController.text,
                      "description": descController.text,
                      "date": selectedDate,
                      "completedBy": [],
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  void _openTaskDetail(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(task: tasks[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Daftar Tugas")),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(tasks[index]["title"] ?? ""),
            subtitle: Text("${tasks[index]["date"]?.toLocal()}".split(' ')[0]),
            onTap: () => _openTaskDetail(index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskDetailPage extends StatelessWidget {
  final Map<String, dynamic> task;

  TaskDetailPage({required this.task});

  void _openStudentDetail(BuildContext context, String studentName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentDetailPage(studentName: studentName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(task["title"] ?? "Detail Tugas")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Deskripsi:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(task["description"] ?? "Tidak ada deskripsi"),
            SizedBox(height: 10),
            Text("Tanggal: ${task["date"]?.toLocal()}".split(' ')[0]),
            SizedBox(height: 10),
            Text("Sudah Dikerjakan oleh:", style: TextStyle(fontWeight: FontWeight.bold)),
            ...task["completedBy"].map<Widget>((name) => ListTile(
              title: Text(name),
              onTap: () => _openStudentDetail(context, name),
            )).toList(),
          ],
        ),
      ),
    );
  }
}

class StudentDetailPage extends StatelessWidget {
  final String studentName;

  StudentDetailPage({required this.studentName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail Siswa")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama Siswa:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(studentName),
            // Tambahkan detail siswa lainnya di sini
          ],
        ),
      ),
    );
  }
}
