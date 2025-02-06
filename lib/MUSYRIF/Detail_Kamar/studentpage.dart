import 'package:flutter/material.dart';

class StudentPage extends StatefulWidget {
  final String taskName;
  final List<String> students;

  StudentPage({required this.taskName, required this.students});

  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  Map<String, bool> studentStatus = {};

  @override
  void initState() {
    super.initState();
    // Inisialisasi status checklist siswa (semua false)
    for (var student in widget.students) {
      studentStatus[student] = false;
    }
  }

  // Fungsi untuk mengecek apakah semua siswa sudah dicentang
  bool _allStudentsChecked() {
    return studentStatus.values.every((status) => status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.taskName), backgroundColor: Colors.blue),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Checklist Siswa untuk ${widget.taskName}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.students.length,
                itemBuilder: (context, index) {
                  String student = widget.students[index];
                  return CheckboxListTile(
                    title: Text(student),
                    value: studentStatus[student],
                    onChanged: (value) {
                      setState(() {
                        studentStatus[student] = value ?? false;
                      });
                      if (_allStudentsChecked()) {
                        _showCompletedDialog();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tampilkan notifikasi jika semua siswa sudah dicentang
  void _showCompletedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tugas Selesai"),
          content: Text("Semua siswa telah menyelesaikan ${widget.taskName}!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context, true); // Kembali ke TaskPage dengan nilai true
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
