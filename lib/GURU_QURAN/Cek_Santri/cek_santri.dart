import 'package:aplikasi_guru/GURU_QURAN/Cek_Santri/detail_cek_santri.dart';
import 'package:aplikasi_guru/GURU_QURAN/Cek_Santri/data_santri_statik.dart';
import 'package:flutter/material.dart';

class CekSantri extends StatefulWidget {//genak no barch
  const CekSantri({super.key});

  @override
  State<CekSantri> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<CekSantri> {
  String? _selectedSchool; // SMP or SMA
  String? _selectedClass;
  String? _selectedSession;
  String? _selectedHalaqoh;

  final List<String> schools = ["SMP", "SMA"];
  final List<String> classes = ["7", "8", "9", "10", "11", "12"];
  final List<String> sessions = ["1", "2", "3", "4"];
  final List<String> halaqohs = ["Takhassus 1", "Takhassus 2", "Takhassus 3"];

  @override
  Widget build(BuildContext context) {
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
            title: Text(
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
            // School selection card
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: schools.map((school) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSchool = school;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: _selectedSchool == school
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        school,
                        style: TextStyle(
                          color: _selectedSchool == school
                              ? Color(0xFF2E3F7F)
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 10),
            // Filters
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedClass,
                    decoration: InputDecoration(
                      labelText: "Pilih Kelas",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedClass = newValue;
                      });
                    },
                    items: classes
                        .map((kelas) => DropdownMenuItem(
                              value: kelas,
                              child: Text(kelas,
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ))
                        .toList(),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSession,
                    decoration: InputDecoration(
                      labelText: "Pilih Sesi",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSession = newValue;
                      });
                    },
                    items: sessions
                        .map((session) => DropdownMenuItem(
                              value: session,
                              child: Text(session,
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedHalaqoh,
              decoration: InputDecoration(
                labelText: "Pilih Halaqoh",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedHalaqoh = newValue;
                });
              },
              items: halaqohs
                  .map((halaqoh) => DropdownMenuItem(
                        value: halaqoh,
                        child: Text(halaqoh,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ))
                  .toList(),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: santriData.length,
                itemBuilder: (context, index) {
                  final santri = santriData[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(santri['studentName']),
                      subtitle: Text("Kelas: ${santri['className']} - Ruang: ${santri['room']}"),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailCekSantri(
                              studentName: santri['studentName'],
                              room: santri['room'],
                              className: santri['className'],
                              studentId: santri['studentId'],
                              progressData: santri['progressData'],
                            ),
                          ),
                        );
                      },
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