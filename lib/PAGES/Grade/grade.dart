import 'package:flutter/material.dart';

class GradePage extends StatelessWidget {
  final List<Map<String, dynamic>> students;

  const GradePage({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Nilai Siswa'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Nama Siswa')),
            DataColumn(label: Text('Tugas 1')),
            DataColumn(label: Text('Tugas 2')),
            DataColumn(label: Text('Tugas 3')),
            DataColumn(label: Text('Rata-rata')),
          ],
          rows: students.map((student) {
            final grades = student['grades'] as List<int>;
            final average = grades.reduce((a, b) => a + b) / grades.length;
            return DataRow(cells: [
              DataCell(Text(student['name'])),
              DataCell(Text(grades[0].toString())),
              DataCell(Text(grades[1].toString())),
              DataCell(Text(grades[2].toString())),
              DataCell(Text(average.toStringAsFixed(2))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}