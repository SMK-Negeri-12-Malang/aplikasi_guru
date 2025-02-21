import 'package:flutter/material.dart';
import 'laporan_detail.dart';

class LaporanModel {
  final String nama;
  final String kamar;
  final String pelanggaran;
  final String tanggal;
  final String poin;

  LaporanModel({
    required this.nama,
    required this.kamar,
    required this.pelanggaran,
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

  final List<Map<String, String>> _siswaList = [
    {'nama': 'Ahmad', 'kamar': 'Kamar A'},
    {'nama': 'Aisyah', 'kamar': 'Kamar A'},
    {'nama': 'Budi', 'kamar': 'Kamar B'},
    {'nama': 'Citra', 'kamar': 'Kamar C'},
    {'nama': 'Dian', 'kamar': 'Kamar D'},
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
        _poinController.text.isNotEmpty) {
      setState(() {
        laporanList.add(
          LaporanModel(
            nama: _namaController.text,
            kamar: _kamarController.text,
            pelanggaran: _selectedPelanggaran!,
            tanggal: _tanggalController.text,
            poin: _poinController.text,
          ),
        );
      });

      _namaController.clear();
      _kamarController.clear();
      _tanggalController.clear();
      _poinController.clear();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LaporanDetail(kamar: _kamarController.text),
        ),
      );
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
                  }
                });
              },
            ),
            TextField(
              controller: _tanggalController,
              decoration: InputDecoration(labelText: 'Tanggal'),
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
