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
  List<Map<String, dynamic>> filteredSiswaList = [];
  Map<String, bool> absensiData = {};
  Map<String, bool> tahfidzData = {};
  Map<String, bool> tahsinData = {};

  // Filter fields
  String searchNama = '';
  String searchKelas = '';
  String searchHalaqoh = '';
  String searchPenanggungJawab = '';

  // Controller untuk filter nama
  final _namaController = TextEditingController();

  // Dropdown options
  List<String> kelasOptions = [];
  List<String> halaqohOptions = [];
  List<String> pjOptions = [];

  @override
  void initState() {
    super.initState();
    siswaList = DataSiswa.getMockSiswa();
    filteredSiswaList = List.from(siswaList);
    _initDropdownOptions();
    _loadAbsensiData();
    _loadTahfidzTahsinData();
  }

  void _initDropdownOptions() {
    // Ambil unique value dari data siswa
    final kelasSet = <String>{};
    final halaqohSet = <String>{};
    final pjSet = <String>{};
    for (var s in siswaList) {
      if (s['kelas'] != null && s['kelas'].toString().trim().isNotEmpty) kelasSet.add(s['kelas']);
      if (s['halaqoh'] != null && s['halaqoh'].toString().trim().isNotEmpty) halaqohSet.add(s['halaqoh']);
      if (s['penanggungJawab'] != null && s['penanggungJawab'].toString().trim().isNotEmpty) pjSet.add(s['penanggungJawab']);
    }
    kelasOptions = kelasSet.toList()..sort();
    halaqohOptions = halaqohSet.toList()..sort();
    pjOptions = pjSet.toList()..sort();
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  void _filterSiswa() {
    setState(() {
      filteredSiswaList = siswaList.where((siswa) {
        final nama = (siswa['name'] ?? '').toString().toLowerCase();
        final kelas = (siswa['kelas'] ?? '').toString().toLowerCase();
        final halaqoh = (siswa['halaqoh'] ?? '').toString().toLowerCase();
        final pj = (siswa['penanggungJawab'] ?? '').toString().toLowerCase();
        return (searchNama.isEmpty || nama.contains(searchNama.toLowerCase())) &&
            (searchKelas.isEmpty || kelas.contains(searchKelas.toLowerCase())) &&
            (searchHalaqoh.isEmpty || halaqoh.contains(searchHalaqoh.toLowerCase())) &&
            (searchPenanggungJawab.isEmpty || pj.contains(searchPenanggungJawab.toLowerCase()));
      }).toList();
    });
  }

  void _resetFilter() {
    setState(() {
      searchKelas = '';
      searchHalaqoh = '';
      searchPenanggungJawab = '';
      _filterSiswa();
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              DropdownButtonFormField<String>(
                value: searchKelas.isNotEmpty ? searchKelas : null,
                decoration: InputDecoration(
                  labelText: 'Kelas',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: kelasOptions
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    searchKelas = val ?? '';
                  });
                },
                isExpanded: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: searchHalaqoh.isNotEmpty ? searchHalaqoh : null,
                decoration: InputDecoration(
                  labelText: 'Halaqoh',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: halaqohOptions
                    .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    searchHalaqoh = val ?? '';
                  });
                },
                isExpanded: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: searchPenanggungJawab.isNotEmpty ? searchPenanggungJawab : null,
                decoration: InputDecoration(
                  labelText: 'Penanggung Jawab',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: pjOptions
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    searchPenanggungJawab = val ?? '';
                  });
                },
                isExpanded: true,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _resetFilter();
                        Navigator.pop(context);
                      },
                      child: Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2E3F7F),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        _filterSiswa();
                        Navigator.pop(context);
                      },
                      child: Text('Terapkan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
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
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
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
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      'Cek Santri',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Shopee-style search bar + filter icon
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _namaController,
                    decoration: InputDecoration(
                      hintText: 'Cari Nama',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                    ),
                    onChanged: (val) {
                      searchNama = val;
                      _filterSiswa();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _showFilterSheet,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(Icons.filter_alt, color: Color(0xFF2E3F7F)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              child: ListView.builder(
                itemCount: filteredSiswaList.length,
                itemBuilder: (context, index) {
                  final siswa = filteredSiswaList[index];
                  final id = siswa['id'].toString();
                  final initials = (siswa['name'] ?? '-').isNotEmpty
                      ? siswa['name'].split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
                      : '?';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2),
                    child: Material(
                      color: Colors.white,
                      elevation: 4,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        splashColor: Colors.blue.withOpacity(0.1),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailCekSantri(
                                studentName: siswa['name'],
                                room: siswa['room'] ?? 'Tidak diketahui',
                                className: siswa['kelas'],
                                studentId: siswa['id'].toString(),
                                session: 'Sesi 1',
                                type: (tahfidzData[id] ?? false)
                                    ? 'Tahfidz'
                                    : (tahsinData[id] ?? false)
                                        ? 'Tahsin'
                                        : 'Belum diisi',
                                ayatAwal: (tahfidzData[id] ?? false) || (tahsinData[id] ?? false) ? '1' : '-',
                                ayatAkhir: (tahfidzData[id] ?? false) || (tahsinData[id] ?? false) ? '10' : '-',
                                nilai: (tahfidzData[id] ?? false) || (tahsinData[id] ?? false) ? 'Mumtaz' : '-',
                                // Tambahan detail
                                jalan: siswa['jalan'] ?? '-',
                                rtrw: siswa['rtrw'] ?? '-',
                                kota: siswa['kota'] ?? '-',
                                telepon: siswa['telepon'] ?? '-',
                                namaAyah: siswa['namaAyah'] ?? '-',
                                teleponAyah: siswa['teleponAyah'] ?? '-',
                                namaIbu: siswa['namaIbu'] ?? '-',
                                teleponIbu: siswa['teleponIbu'] ?? '-',
                                namaWali: siswa['namaWali'] ?? '-',
                                teleponWali: siswa['teleponWali'] ?? '-',
                                halaqoh: siswa['halaqoh'] ?? '-',
                                tahfidzTerakhir: siswa['tahfidzTerakhir'] ?? '-',
                                virtualAccount: siswa['virtualAccount'] ?? '-',
                                vaUangSaku: siswa['vaUangSaku'] ?? '-',
                                dataTahfidz: siswa['dataTahfidz'] ?? [],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Color(0xFF2E3F7F),
                                child: Text(
                                  initials,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      siswa['name'],
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E3F7F),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.class_, size: 16, color: Colors.grey[700]),
                                        const SizedBox(width: 4),
                                        Text(
                                          siswa['kelas'] ?? '-',
                                          style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(Icons.group, size: 16, color: Colors.grey[700]),
                                        const SizedBox(width: 4),
                                        Text(
                                          siswa['halaqoh'] ?? '-',
                                          style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(Icons.person, size: 16, color: Colors.grey[700]),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            siswa['penanggungJawab'] ?? '-',
                                            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF2E3F7F), size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
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
}