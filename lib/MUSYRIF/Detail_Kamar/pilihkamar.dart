import 'package:aplikasi_ortu/MUSYRIF/Detail_Kamar/taskpage.dart';
import 'package:flutter/material.dart';



class KamarSelectionWidget extends StatefulWidget {
  @override
  _KamarSelectionWidgetState createState() => _KamarSelectionWidgetState();
}

class _KamarSelectionWidgetState extends State<KamarSelectionWidget> {
  // Data kamar, siswa, dan tugas
  List<Map<String, dynamic>> rooms = [
    {
      'name': 'Kamar 1',
      'students': ['Suprii', 'Ali', 'Budi'],
      'tasks': ['Tugas 1', 'Tugas 2']
    },
    {
      'name': 'Kamar 2',
      'students': ['Dewi', 'Siti', 'Eka'],
      'tasks': ['Tugas 1', 'Tugas 2']
    },
    {
      'name': 'Kamar 3',
      'students': ['Rani', 'Andi', 'Hani'],
      'tasks': ['Tugas 1', 'Tugas 2']
    },
  ];

  // Fungsi untuk menambahkan kamar baru
  void _addNewRoom() {
    setState(() {
      rooms.add({'name': 'Kamar Baru', 'students': [], 'tasks': []});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          // Button untuk membuat kamar baru
          ElevatedButton(
            onPressed: _addNewRoom,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Buat Kamar Baru',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          
          // Daftar Kamar yang ada
          ListView.builder(
            shrinkWrap: true,
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigasi ke halaman tugas dengan daftar siswa
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskPage(
                          roomName: rooms[index]['name'],
                          students: rooms[index]['students'],
                          
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    rooms[index]['name'],
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
