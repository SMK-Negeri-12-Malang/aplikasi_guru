import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_guru/SERVICE/Service_Musyrif/data_siswa.dart';

class CekSantri extends StatefulWidget {
  const CekSantri({Key? key}) : super(key: key);

  @override
  State<CekSantri> createState() => _CekSantriState();
}

class _CekSantriState extends State<CekSantri> {
  List<Map<String, dynamic>> siswaList = [];
  Map<String, bool> absensiData = {};
  Map<String, Map<String, String>> hafalanData = {};

  @override
  void initState() {
    super.initState();
    siswaList = DataSiswa.getMockSiswa();
    _loadAbsensi();
    _loadHafalan();
  }

  Future<void> _loadAbsensi() async {
    final prefs = await SharedPreferences.getInstance();
    final absensiJson = prefs.getString('attendanceData');
    if (absensiJson != null) {
      List<dynamic> data = json.decode(absensiJson);
      final absensi = {
        for (var siswa in data) siswa['id']: siswa['isPresent'] ?? false
      };
      setState(() {
        absensiData = absensi.cast<String, bool>();
      });
    }
  }

  Future<void> _loadHafalan() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('hafalanDataByDate');
    if (savedData != null) {
      Map<String, Map<String, Map<String, String>>> hafalanDataByDate =
          Map<String, Map<String, Map<String, String>>>.from(
              json.decode(savedData).map((key, value) => MapEntry(
                  key,
                  Map<String, Map<String, String>>.from(value.map(
                      (k, v) => MapEntry(k, Map<String, String>.from(v)))))));
      String today = DateTime.now().toString().split(' ')[0];
      setState(() {
        hafalanData = hafalanDataByDate[today] ?? {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSiswa = siswaList.where((siswa) {
      final id = siswa['id'];
      final isPresent = absensiData[id] ?? false;
      final tahfidzKey = '${id}_Tahfidz';
      final tahsinKey = '${id}_Tahsin';
      final isTahfidzFilled = hafalanData[tahfidzKey] != null;
      final isTahsinFilled = hafalanData[tahsinKey] != null;
      return isPresent && (!isTahfidzFilled || !isTahsinFilled);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      body: Column(
        children: [
          // Header Container menggantikan AppBar
          Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 1.0), // Add padding to move the title down
                child: Center(
                  child: Text(
                    'Cek Santri',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Isi konten santri
          Expanded(
            child: ListView.builder(
              itemCount: filteredSiswa.length,
              itemBuilder: (context, index) {
                final siswa = filteredSiswa[index];
                final id = siswa['id'];
                final tahfidzKey = '${id}_Tahfidz';
                final tahsinKey = '${id}_Tahsin';
                final isTahfidzFilled = hafalanData[tahfidzKey] != null;
                final isTahsinFilled = hafalanData[tahsinKey] != null;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        siswa['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("Kelas: ${siswa['kelas']}"),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Tahfidz'),
                          Checkbox(
                            value: isTahfidzFilled,
                            onChanged: null,
                          ),
                          const SizedBox(width: 16),
                          const Text('Tahsin'),
                          Checkbox(
                            value: isTahsinFilled,
                            onChanged: null,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
