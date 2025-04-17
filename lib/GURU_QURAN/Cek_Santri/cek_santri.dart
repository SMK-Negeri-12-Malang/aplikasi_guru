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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cek Santri",
        style: TextStyle(color: Colors.white,)),
        backgroundColor: const Color(0xFF2E3F7F),
      ),
      body: ListView.builder(
        itemCount: siswaList.length,
        itemBuilder: (context, index) {
          final siswa = siswaList[index];
          final id = siswa['id'];
          final isPresent = absensiData[id] ?? false;
          final tahfidzKey = '${id}_Tahfidz';
          final tahsinKey = '${id}_Tahsin';

          final isTahfidzFilled = hafalanData[tahfidzKey] != null;
          final isTahsinFilled = hafalanData[tahsinKey] != null;

          final keteranganAbsensi = isPresent ? '✅ Hadir' : '❌ Tidak Hadir';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              title: Text(
                siswa['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Kelas: ${siswa['kelas']}"),
                  const SizedBox(height: 4),
                  Text("Absensi: $keteranganAbsensi"),
                  Row(
                    children: [
                      const Text('Tahfidz'),
                      Checkbox(
                        value: isTahfidzFilled,
                        onChanged: null, // Tidak bisa diubah dari halaman ini
                      ),
                      const Text('Tahsin'),
                      Checkbox(
                        value: isTahsinFilled,
                        onChanged: null, // Tidak bisa diubah dari halaman ini
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
