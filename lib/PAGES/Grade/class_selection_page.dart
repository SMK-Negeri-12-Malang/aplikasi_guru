import 'dart:math';
import 'package:flutter/material.dart';
import 'grade.dart';

class ClassSelectionPage extends StatefulWidget {
  @override
  _ClassSelectionPageState createState() => _ClassSelectionPageState();
}

class _ClassSelectionPageState extends State<ClassSelectionPage> {
  final Map<String, List<String>> classTables = {
    'Kelas XI A': [],
    'Kelas XI B': [],
    'Kelas XI C': [],
  };

  final Map<String, List<String>> classStudents = {
    'Kelas XI A': ['Siswa A1', 'Siswa A2', 'Siswa A3'],
    'Kelas XI B': ['Siswa B1', 'Siswa B2', 'Siswa B3'],
    'Kelas XI C': ['Siswa C1', 'Siswa C2', 'Siswa C3'],
  };

  void _addTable(String className) {
    TextEditingController tableController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Tambah Tabel Baru', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: tableController,
            decoration: InputDecoration(
              labelText: 'Judul Tabel',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Batal', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('Tambah'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (tableController.text.isNotEmpty) {
                  setState(() {
                    classTables[className]!.add(tableController.text);
                  });
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GradePage(
                        className: className,
                        students: classStudents[className]!,
                      ),
                      settings: RouteSettings(
                        arguments: tableController.text,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            // Header Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.school, size: 50, color: Colors.white),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Pilih Kelas Anda',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Class List
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: classTables.keys.length,
              itemBuilder: (context, index) {
                String className = classTables.keys.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.class_, size: 40, color: Colors.blue),
                                  SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        className,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Jumlah siswa: ${classStudents[className]!.length}',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.add, color: Colors.blue),
                                onPressed: () => _addTable(className),
                              ),
                            ],
                          ),
                          Divider(height: 20, thickness: 1, color: Colors.grey[300]),
                          Column(
                            children: classTables[className]!.map((table) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  table,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                onTap: () {
                                  // Navigate to the table details
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
