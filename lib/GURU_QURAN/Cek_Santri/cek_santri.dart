import 'dart:convert';
import 'package:aplikasi_guru/GURU_QURAN/Cek_Santri/detail_cek_santri.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CekSantri extends StatefulWidget {
  final List<Map<String, dynamic>>?
      passedData; // Accept data from Kepesantrenan

  const CekSantri({super.key, this.passedData});

  @override
  State<CekSantri> createState() => _CekSantriState();
}

class _CekSantriState extends State<CekSantri> {
  String _searchQuery = "";
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> evaluatedStudents = [];

  @override
  void initState() {
    super.initState();
    if (widget.passedData != null) {
      // Use passed data if available
      evaluatedStudents = widget.passedData!;
    } else {
      _loadEvaluatedStudents();
    }
  }

  Future<void> _loadEvaluatedStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('evaluatedStudents');
    if (savedData != null) {
      setState(() {
        evaluatedStudents =
            List<Map<String, dynamic>>.from(json.decode(savedData));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = evaluatedStudents.where((student) {
      final name = student['name']?.toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: Container(
          padding: EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: const Text(
              "Cek Santri",
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search bar
            Container(
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari berdasarkan nama...',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF2E3F7F)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            SizedBox(height: 16),
            // List of evaluated students
            Expanded(
              child: ListView.builder(
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) {
                  final student = filteredStudents[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailCekSantri(
                              studentName: student['name'] ?? '-',
                              room: student['className'] ?? '-',
                              className: student['level'] ?? '-',
                              studentId: student['id'] ?? '-',
                              session: student['session'] ?? '-',
                              type: student['type'] ?? '-',
                              ayatAwal: student['ayatAwal'] ?? '-',
                              ayatAkhir: student['ayatAkhir'] ?? '-',
                              nilai: student['nilai'] ?? '-',
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(student['name'] ?? '-'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Kelas: ${student['className'] ?? '-'}"),
                              Text("Sesi: ${student['session'] ?? '-'}"),
                              Text("Tipe: ${student['type'] ?? '-'}"),
                              Text(
                                  "Ayat Awal: ${student['ayatAwal'] ?? '-'}, Ayat Akhir: ${student['ayatAkhir'] ?? '-'}"),
                              Text("Nilai: ${student['nilai'] ?? '-'}"),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      ),
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
