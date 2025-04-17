import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_guru/SERVICE/Service_Musyrif/data_siswa.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({Key? key}) : super(key: key);

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  List<Map<String, dynamic>> siswaList = [];
  Map<String, bool> absensiData = {}; // Data Absensi untuk setiap santri

  @override
  void initState() {
    super.initState();
    siswaList = DataSiswa.getMockSiswa(); // Ambil data statik dari DataSiswa
    _loadAbsensi();
  }

  // Mengambil data absensi yang sudah ada sebelumnya
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

  // Menyimpan data absensi ke SharedPreferences
  Future<void> _updateAbsensi(String id, bool isChecked) async {
    final prefs = await SharedPreferences.getInstance();
    absensiData[id] = isChecked;

    List<Map<String, dynamic>> dataToSave = siswaList.map((siswa) {
      final idSantri = siswa['id'];
      return {
        'id': idSantri,
        'name': siswa['name'],
        'class': siswa['kelas'],
        'isPresent': absensiData[idSantri] ?? false,
      };
    }).toList();

    await prefs.setString('attendanceData', json.encode(dataToSave));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Absensi", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2E3F7F),
      ),
      body: ListView.builder(
        itemCount: siswaList.length,
        itemBuilder: (context, index) {
          final siswa = siswaList[index];
          final id = siswa['id'];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              title: Text(
                siswa['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Kelas: ${siswa['kelas']}"),
              trailing: Checkbox(
                value: absensiData[id] ?? false,
                onChanged: (value) {
                  _updateAbsensi(id, value!); // Update status absensi
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
