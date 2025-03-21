import 'package:flutter/material.dart';
import 'dart:io';

class StudentPage extends StatefulWidget {
  final String taskName;
  final String taskDescription;
  final List<String> students;
  final List<String> files;
  final List<String> images;

  StudentPage({
    required this.taskName,
    required this.taskDescription,
    required this.students,
    required this.files,
    required this.images,
  });

  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  late List<Map<String, dynamic>> studentList;

  @override
  void initState() {
    super.initState();
    studentList = widget.students.map((student) {
      return {'name': student, 'completed': false};
    }).toList();
  }

  void _showTaskInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Text("📌 Info Tugas", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),

                // Informasi Tugas
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📝 Nama Tugas:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(widget.taskName, style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        Text("📄 Deskripsi Tugas:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(widget.taskDescription, style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Dokumen Terlampir
                if (widget.files.isNotEmpty) ...[
                  Text("📄 Dokumen Terlampir:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.files.map((file) {
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: Icon(Icons.insert_drive_file, color: Colors.blue),
                          title: Text(file.split('/').last, style: TextStyle(fontSize: 14)),
                          onTap: () {
                            // Tambahkan aksi untuk membuka dokumen
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],

                SizedBox(height: 10),

                // Galeri Gambar di Info
                if (widget.images.isNotEmpty) ...[
                  Text("🖼 Gambar Terkait:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: widget.images.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(File(widget.images[index]), fit: BoxFit.cover),
                      );
                    },
                  ),
                ],

                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _checkAllStudentsCompleted() {
    bool allCompleted = studentList.every((student) => student['completed']);
    if (allCompleted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Tugas: ${widget.taskName}"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.info, size: 28, color: Colors.white),
            onPressed: () => _showTaskInfo(context),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Siswa yang Ditugaskan:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ...studentList.map((student) {
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(student['name'][0], style: TextStyle(color: Colors.white)),
                  ),
                  title: Text(student['name'], style: TextStyle(fontSize: 14)),
                  trailing: Checkbox(
                    value: student['completed'],
                    onChanged: (value) {
                      setState(() {
                        student['completed'] = value!;
                        _checkAllStudentsCompleted();
                      });
                    },
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}