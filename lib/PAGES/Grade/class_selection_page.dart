import 'package:aplikasi_ortu/PAGES/Grade/grade.dart';
import 'package:flutter/material.dart';

class ClassSelectionPage extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> classData = {
    'Kelas A': [
      {'name': 'Paul Walker', 'grades': [80, 90, 85]},
      {'name': 'John Doe', 'grades': [70, 85, 75]},
    ],
    'Kelas B': [
      {'name': 'Jane Doe', 'grades': [95, 90, 100]},
      {'name': 'Max Payne', 'grades': [60, 70, 65]},
    ],
    'Kelas C': [
      {'name': 'Alice Brown', 'grades': [88, 92, 85]},
      {'name': 'Bob Smith', 'grades': [75, 80, 78]},
    ],
  };

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
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  className,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GradePage(students: classData[className]!)),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}