import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_guru/SERVICE/Service_Musyrif/data_siswa.dart';
import 'detail_cek_santri.dart';

class CekSantri extends StatefulWidget {
  const CekSantri({Key? key}) : super(key: key);

  @override
  State<CekSantri> createState() => _CekSantriState();
}

class _CekSantriState extends State<CekSantri> {
  List<Map<String, dynamic>> siswaList = [];
  Map<String, bool> absensiData = {};
  Map<String, bool> tahfidzData = {};
  Map<String, bool> tahsinData = {};

  @override
  void initState() {
    super.initState();
    siswaList = DataSiswa.getMockSiswa();
    _loadAbsensiData();
    _loadTahfidzTahsinData();
  }

  Future<void> _loadAbsensiData() async {
    final prefs = await SharedPreferences.getInstance();
    final absensiJson = prefs.getString('attendanceData');
    if (absensiJson != null) {
      setState(() {
        final data = List<Map<String, dynamic>>.from(json.decode(absensiJson));
        absensiData = {
          for (var siswa in data) siswa['id'].toString(): siswa['isPresent'] ?? false,
        };
      });
    }
  }

  Future<void> _loadTahfidzTahsinData() async {
    final prefs = await SharedPreferences.getInstance();
    final tahfidzJson = prefs.getString('evaluatedStudents');
    if (tahfidzJson != null) {
      setState(() {
        final data = List<Map<String, dynamic>>.from(json.decode(tahfidzJson));
        for (var entry in data) {
          final id = entry['id'].toString();
          final type = entry['type'];
          if (type == 'Tahfidz') {
            tahfidzData[id] = true;
          } else if (type == 'Tahsin') {
            tahsinData[id] = true;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text(
          'Cek Santri',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E3F7F),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: siswaList.length,
          itemBuilder: (context, index) {
            final siswa = siswaList[index];
            final id = siswa['id'].toString();
            final tahfidz = tahfidzData[id] ?? false;
            final tahsin = tahsinData[id] ?? false;
            final absen = absensiData[id] ?? false;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailCekSantri(
                      studentName: siswa['name'],
                      room: siswa['room'] ?? 'Tidak diketahui',
                      className: siswa['kelas'],
                      studentId: siswa['id'].toString(),
                      session: 'Sesi 1', // Contoh data sesi
                      type: tahfidz ? 'Tahfidz' : tahsin ? 'Tahsin' : 'Belum diisi',
                      ayatAwal: tahfidz ? '1' : tahsin ? '1' : '-',
                      ayatAkhir: tahfidz ? '10' : tahsin ? '10' : '-',
                      nilai: tahfidz || tahsin ? 'Mumtaz' : '-',
                    ),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        siswa['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Kelas: ${siswa['kelas']}"),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusCheckbox(
                            label: 'Tahfidz',
                            value: tahfidz,
                            onChanged: null,
                          ),
                          _buildStatusCheckbox(
                            label: 'Tahsin',
                            value: tahsin,
                            onChanged: null,
                          ),
                          _buildStatusCheckbox(
                            label: 'Absen',
                            value: absen,
                            onChanged: null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?>? onChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF2E3F7F),
        ),
        Text(label),
      ],
    );
  }
}// end of file