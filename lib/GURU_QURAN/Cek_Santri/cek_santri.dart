import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CekSantri extends StatefulWidget {
  const CekSantri({super.key});

  @override
  State<CekSantri> createState() => _CekSantriState();
}

class _CekSantriState extends State<CekSantri> {
  List<Map<String, dynamic>> attendanceData = [];
  List<Map<String, dynamic>> evaluatedData = [];
  List<Map<String, dynamic>> allSantriData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load attendance data
    final attendanceJson = prefs.getString('attendanceData');
    if (attendanceJson != null) {
      attendanceData = List<Map<String, dynamic>>.from(json.decode(attendanceJson));
    }

    // Load evaluated students data
    final evaluatedJson = prefs.getString('evaluatedStudents');
    if (evaluatedJson != null) {
      evaluatedData = List<Map<String, dynamic>>.from(json.decode(evaluatedJson));
    }

    // Gabungkan data absensi dan evaluasi untuk menampilkan seluruh santri
    setState(() {
      allSantriData = attendanceData.map((student) {
        final hasTahfidz = evaluatedData.any((e) =>
            e['id'].toString() == student['id'].toString() && e['type'] == 'Tahfidz');
        final hasTahsin = evaluatedData.any((e) =>
            e['id'].toString() == student['id'].toString() && e['type'] == 'Tahsin');
        return {
          'id': student['id'],
          'name': student['name'],
          'class': student['class'],
          'isPresent': student['isPresent'],
          'hasTahfidz': hasTahfidz,
          'hasTahsin': hasTahsin,
        };
      }).toList();
    });
  }

  String getKeterangan(Map<String, dynamic> student) {
    if (!student['isPresent']) {
      return '❌ Tidak Masuk';
    } else if (student['hasTahfidz'] && student['hasTahsin']) {
      return '✅✅ Sudah setor lengkap';
    } else if (student['hasTahfidz'] || student['hasTahsin']) {
      return '✅ Sudah setor sebagian';
    } else {
      return '❌ Belum setor';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rekap Santri"),
        backgroundColor: const Color(0xFF2E3F7F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Rekap Santri (Semua Santri)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: allSantriData.length,
                itemBuilder: (context, index) {
                  final student = allSantriData[index];
                  final keterangan = getKeterangan(student);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        student['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text("Kelas: ${student['class']}"),
                      trailing: Text(keterangan),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
