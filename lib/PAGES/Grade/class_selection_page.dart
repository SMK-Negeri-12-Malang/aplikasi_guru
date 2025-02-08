import 'dart:math';
import 'package:aplikasi_ortu/PAGES/Grade/grade.dart';
import 'package:flutter/material.dart';

class ClassSelectionPage extends StatelessWidget {
  // Menghasilkan data acak untuk tiap kelas dengan 25 siswa per kelas
  final Map<String, List<Map<String, dynamic>>> classData = generateClassData();

  static Map<String, List<Map<String, dynamic>>> generateClassData() {
    final Random random = Random();
    final List<String> firstNames = [
      "Aiden", "Olivia", "Liam", "Emma", "Noah", "Ava",
      "Elijah", "Sophia", "James", "Isabella", "Benjamin", "Mia",
      "Lucas", "Charlotte", "Mason", "Amelia", "Logan", "Harper",
      "Alexander", "Evelyn", "William", "Abigail", "Jacob", "Emily",
      "Michael", "Ella", "Ethan", "Elizabeth", "Daniel", "Camila"
    ];

    final List<String> lastNames = [
      "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia",
      "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez",
      "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore",
      "Jackson", "Martin", "Lee", "Perez", "Thompson", "White",
      "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson"
    ];

    // Fungsi untuk menghasilkan nama acak
    String getRandomName() {
      String first = firstNames[random.nextInt(firstNames.length)];
      String last = lastNames[random.nextInt(lastNames.length)];
      return "$first $last";
    }

    Map<String, List<Map<String, dynamic>>> data = {};

    // Membuat data untuk masing-masing kelas
    for (String className in ['Kelas A', 'Kelas B', 'Kelas C']) {
      List<Map<String, dynamic>> students = List.generate(25, (index) {
        return {
          'name': getRandomName(),
          // Menghasilkan 3 nilai acak antara 60 dan 100
          'grades': List.generate(3, (i) => 60 + random.nextInt(41))
        };
      });
      data[className] = students;
    }
    return data;
  }

  void _showGradeOptions(BuildContext context, List<Map<String, dynamic>> students) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Jenis Rekap Nilai', style: Theme.of(context).textTheme.headlineSmall),
          content: Text('Silakan pilih jenis rekap nilai yang ingin Anda lihat.', style: Theme.of(context).textTheme.bodyMedium),
          actions: <Widget>[
            TextButton(
              child: Text('Rekap Nilai Ujian', style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GradePage(students: students),
                  ),
                );
              },
            ),
            TextButton(
              child: Text('Ulangan Harian', style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GradePage(students: students),
                  ),
                );
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Kelas'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: classData.keys.length,
          itemBuilder: (context, index) {
            String className = classData.keys.elementAt(index);
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  className,
                  style:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing:
                    const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                onTap: () {
                  _showGradeOptions(context, classData[className]!);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
