import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/student_service.dart';

class HistoryPage extends StatefulWidget {
  final String kategori;
  final String selectedDate;

  HistoryPage({
    required this.kategori,
    required this.selectedDate,
  });

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late List<Student> students;
  final List<String> sesiList = ['Pagi', 'Sore', 'Malam'];

  @override
  void initState() {
    super.initState();
    students = StudentService.getStudentsByCategory(widget.kategori);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History ${widget.kategori}'),
        backgroundColor: Color(0xFF2E3F7F),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columns: [
              DataColumn(label: Text('Nama Santri')),
              ...sesiList.map((sesi) => DataColumn(label: Text(sesi))),
            ],
            rows: students.map((student) {
              return DataRow(
                cells: [
                  DataCell(Text(student.name)),
                  ...sesiList.map((sesi) => DataCell(
                    Center(
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
