import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AbsensiKelasPage extends StatefulWidget {
  const AbsensiKelasPage({super.key});

  @override
  _AbsensiKelasPageState createState() => _AbsensiKelasPageState();
}

class _AbsensiKelasPageState extends State<AbsensiKelasPage> {
  final List<String> kelasList = ['Kelas A', 'Kelas B', 'Kelas C', 'Kelas D'];
  final Map<String, List<Map<String, dynamic>>> siswaData = {
    'Kelas A': [
      {'name': 'Paul Walker', 'absen': '01', 'checked': false},
      {'name': 'John Doe', 'absen': '02', 'checked': false},
    ],
    'Kelas B': [
      {'name': 'Jane Doe', 'absen': '01', 'checked': false},
      {'name': 'Max Payne', 'absen': '02', 'checked': false},
    ],
    'Kelas C': [
      {'name': 'Alice Brown', 'absen': '01', 'checked': false},
      {'name': 'Bob Smith', 'absen': '02', 'checked': false},
    ],
    'Kelas D': [
      {'name': 'Charlie Green', 'absen': '01', 'checked': false},
      {'name': 'Emma White', 'absen': '02', 'checked': false},
    ],
  };

  String? selectedClass;
  int checkedCount = 0;
  int? selectedIndex;
  List<Map<String, dynamic>> savedAttendance = [];

  void _toggleCheck(int index) {
    setState(() {
      if (selectedClass != null) {
        siswaData[selectedClass]![index]['checked'] =
            !siswaData[selectedClass]![index]['checked'];
        checkedCount = siswaData[selectedClass]!
            .where((siswa) => siswa['checked'])
            .length;
      }
    });
  }

  void _saveAttendance() {
    if (selectedClass != null) {
      setState(() {
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
        for (var siswa in siswaData[selectedClass]!) {
          if (siswa['checked']) {
            savedAttendance.add({
              'name': siswa['name'],
              'absen': siswa['absen'],
              'date': formattedDate,
            });
            siswa['checked'] = false;
          }
        }
        checkedCount = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Absensi berhasil disimpan!')),
      );
    }
  }

  void _showCheckedStudents() {
    if (savedAttendance.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Siswa yang telah absen'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: savedAttendance.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(savedAttendance[index]['name']),
                  subtitle: Text('Absen: ${savedAttendance[index]['absen']} - Tanggal: ${savedAttendance[index]['date']}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'List Kelas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: kelasList.length,
              itemBuilder: (context, index) {
                String kelas = kelasList[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedClass = kelas;
                      selectedIndex = index;
                      checkedCount = siswaData[selectedClass]!
                          .where((siswa) => siswa['checked'])
                          .length;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: selectedIndex == index
                          ? Colors.blue.shade100
                          : const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.blue.shade900, // Warna border
                        width: 2, // Ketebalan border
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4), // Warna lebih pekat
                          blurRadius: 5, // Blur lebih kecil untuk efek lebih nyata
                          spreadRadius: 1, // Sedikit menyebar
                          offset: const Offset(0, 6), // Bayangan lebih panjang ke bawah
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            kelas,
                            style: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (selectedClass == kelas)
                            Text(
                              checkedCount == (siswaData[selectedClass]?.length ?? 0)
                                  ? 'Hadir Semua'
                                  : 'Hadir: $checkedCount',
                              style: TextStyle(
                                color: const Color.fromARGB(179, 0, 0, 0),
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 16,
          ),
          const Divider(),
          if (selectedClass != null) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Siswa di $selectedClass',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.info),
                    onPressed: _showCheckedStudents,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: siswaData[selectedClass]?.length ?? 0,
                itemBuilder: (context, index) {
                  var siswa = siswaData[selectedClass]![index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.blue.shade900, // Warna border
                        width: 2, // Ketebalan border
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 6), // Bayangan ke bawah
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        siswa['name']!,
                        style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      subtitle: Text(
                        'Absen: ${siswa['absen']}',
                        style: TextStyle(color: const Color.fromARGB(179, 0, 0, 0)),
                      ),
                      trailing: Checkbox(
                        value: siswa['checked'],
                        onChanged: (value) {
                          _toggleCheck(index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: TextButton(
                  onPressed: _saveAttendance,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue.shade900,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Save'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
