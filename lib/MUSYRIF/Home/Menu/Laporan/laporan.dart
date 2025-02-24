import 'package:flutter/material.dart';
import 'laporan_detail.dart';
import 'package:aplikasi_ortu/MUSYRIF/Home/home_musyrif.dart'; // Import halaman dashboard

class LaporanModel {
  final String nama;
  final String kamar;
  final String pelanggaran;
  final String iqob;
  final String tanggal;
  final String poin;
   

  LaporanModel({
    required this.nama,
    required this.kamar,
    required this.pelanggaran,
    required this.iqob, // Add iqob field
    required this.tanggal,
    required this.poin,

  });
}

List<LaporanModel> laporanList = [];

class Laporan extends StatefulWidget {
  @override
  _LaporanState createState() => _LaporanState();
}

class _LaporanState extends State<Laporan> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _kamarController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _poinController = TextEditingController();
  final TextEditingController _iqobController = TextEditingController(); // Add iqob controller
  String? _selectedPelanggaran;

  final List<String> _pelanggaranList = [
    'Terlambat',
    'Tidak mengerjakan PR',
    'Membolos',
    'Berkelahi',
    'Tidak berpakaian rapi',
    'Menggunakan handphone saat pembelajaran'
  ];

  final Map<String, int> _poinPelanggaran = {
    'Terlambat': 5,
    'Tidak mengerjakan PR': 10,
    'Membolos': 15,
    'Berkelahi': 20,
    'Tidak berpakaian rapi': 5,
    'Menggunakan handphone saat pembelajaran': 10,
  };

  final Map<String, String> _iqobPelanggaran = {
    'Terlambat': 'Membersihkan halaman',
    'Tidak mengerjakan PR': 'Menulis ulang pelajaran',
    'Membolos': 'Menghafal surat pendek',
    'Berkelahi': 'Menulis surat permintaan maaf',
    'Tidak berpakaian rapi': 'Membersihkan kamar',
    'Menggunakan handphone saat pembelajaran': 'Menyerahkan handphone selama seminggu',
  };

  final List<Map<String, String>> _siswaList = [
    {'nama': 'Ahmad', 'kamar': 'Kamar A'},
    {'nama': 'Aisyah', 'kamar': 'Kamar A'},
    {'nama': 'Budi', 'kamar': 'Kamar B'},
    {'nama': 'Citra', 'kamar': 'Kamar C'},
    {'nama': 'Dian', 'kamar': 'Kamar D'},
    {'nama': 'Paul', 'kamar': 'Kamar A'},
  ];

  List<Map<String, String>> _filteredSiswa = [];

  void _filterSiswa(String query) {
    setState(() {
      _filteredSiswa = _siswaList
          .where((siswa) => siswa['nama']!.toLowerCase().startsWith(query.toLowerCase()))
          .toList();
    });
  }

  void _submitLaporan() {
    if (_namaController.text.isNotEmpty &&
        _kamarController.text.isNotEmpty &&
        _selectedPelanggaran != null &&
        _tanggalController.text.isNotEmpty &&
        _poinController.text.isNotEmpty &&
        _iqobController.text.isNotEmpty) {
      setState(() {
        laporanList.add(
          LaporanModel(
            nama: _namaController.text,
            kamar: _kamarController.text,
            pelanggaran: _selectedPelanggaran!,
            tanggal: _tanggalController.text,
            poin: _poinController.text,
            iqob: _iqobController.text, // Add iqob field
          ),
        );
      });

      _namaController.clear();
      _kamarController.clear();
      _iqobController.clear(); // Clear iqob controller
      _tanggalController.clear();
      _poinController.clear();
     

      Navigator.pop(context); // Navigate back to the previous page
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi semua data!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Pelanggaran'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _namaController,
              decoration: InputDecoration(labelText: 'Nama'),
              onChanged: _filterSiswa,
            ),
            if (_filteredSiswa.isNotEmpty)
              Container(
                height: 100,
                child: ListView.builder(
                  itemCount: _filteredSiswa.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_filteredSiswa[index]['nama']!),
                      onTap: () {
                        setState(() {
                          _namaController.text = _filteredSiswa[index]['nama']!;
                          _kamarController.text = _filteredSiswa[index]['kamar']!;
                          _filteredSiswa.clear();
                        });
                      },
                    );
                  },
                ),
              ),
            TextField(
              controller: _kamarController,
              decoration: InputDecoration(labelText: 'Kamar'),
              readOnly: true,
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Jenis Pelanggaran'),
              value: _selectedPelanggaran,
              items: _pelanggaranList.map((String pelanggaran) {
                return DropdownMenuItem<String>(
                  value: pelanggaran,
                  child: Text(pelanggaran),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPelanggaran = newValue;
                  if (newValue != null) {
                    _poinController.text = _poinPelanggaran[newValue]!.toString();
                    _iqobController.text = _iqobPelanggaran[newValue]!;
                  }
                });
              },
            ),
            TextField(
              controller: _tanggalController,
              decoration: InputDecoration(labelText: 'Tanggal'),
            ),
             TextField(
              controller: _iqobController,
              decoration: InputDecoration(labelText: 'Hukuman/Iqob'),
              readOnly: true,
            
            ),
            TextField(
              controller: _poinController,
              decoration: InputDecoration(labelText: 'Poin Pelanggaran'),
              readOnly: true,
           
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitLaporan,
              child: Text('Simpan Laporan'),
            ),
          ],
        ),
      ),
    );
  }
}