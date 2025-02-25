import 'package:flutter/material.dart';
import 'izin_detail.dart';
import 'package:aplikasi_ortu/MUSYRIF/Home/home_musyrif.dart';

class IzinModel {
  final String nama;
  final String tanggal;
  final String kamar;
  final String halaqo;
  final String musyrif;

  IzinModel({
    required this.nama,
    required this.tanggal,
    required this.kamar,
    required this.halaqo,
    required this.musyrif,
  });
}

List<IzinModel> izinList = [
  IzinModel(nama: 'Ahmad', tanggal: '01-02-2025 to 05-02-2025', kamar: 'Kelas A', halaqo: 'Halaqo 1', musyrif: 'Ustadz Ali'),
  IzinModel(nama: 'Aisyah', tanggal: '02-02-2025 to 06-02-2025', kamar: 'Kelas A', halaqo: 'Halaqo 2', musyrif: 'Ustadzah Fatimah'),
];

class IzinPage extends StatefulWidget {
  @override
  _IzinState createState() => _IzinState();
}

class _IzinState extends State<IzinPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tanggalMulaiController = TextEditingController();
  final TextEditingController _tanggalKembaliController = TextEditingController();
  final TextEditingController _kamarController = TextEditingController();
  final TextEditingController _halaqoController = TextEditingController();
  final TextEditingController _musyrifController = TextEditingController();

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  void _submitIzin() {
    if (_namaController.text.isNotEmpty &&
        _tanggalMulaiController.text.isNotEmpty &&
        _tanggalKembaliController.text.isNotEmpty &&
        _kamarController.text.isNotEmpty &&
        _halaqoController.text.isNotEmpty &&
        _musyrifController.text.isNotEmpty) {
      setState(() {
        izinList.add(
          IzinModel(
            nama: _namaController.text,
            tanggal: "${_tanggalMulaiController.text} to ${_tanggalKembaliController.text}",
            kamar: _kamarController.text,
            halaqo: _halaqoController.text,
            musyrif: _musyrifController.text,
          ),
        );
      });

      _namaController.clear();
      _tanggalMulaiController.clear();
      _tanggalKembaliController.clear();
      _kamarController.clear();
      _halaqoController.clear();
      _musyrifController.clear();

      Navigator.pop(context);
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
        title: Text('Formulir Izin'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _namaController,
              decoration: InputDecoration(labelText: 'Nama',border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),),
            ),
            SizedBox(height:10),
            TextField(
              controller: _tanggalMulaiController,
              decoration: InputDecoration(labelText: 'Tanggal Mulai',border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),),
              readOnly: true,
              onTap: () => _selectDate(context, _tanggalMulaiController),
            ),
            SizedBox(height:10),
            TextField(
              controller: _tanggalKembaliController,
              decoration: InputDecoration(labelText: 'Tanggal Kembali',border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),),
              readOnly: true,
              onTap: () => _selectDate(context, _tanggalKembaliController),
            ),
            SizedBox(height:10),
            TextField(
              controller: _kamarController,
              decoration: InputDecoration(labelText: 'Kamar',border:  OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),),
            ),
            SizedBox(height:10),
            TextField(
              controller: _halaqoController,
              decoration: InputDecoration(labelText: 'Halaqo',border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),),
            ),
            SizedBox(height:10),
            TextField(
              controller: _musyrifController,
              decoration: InputDecoration(labelText: 'Musyrif',border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: _submitIzin,
              child: Text('Simpan Izin', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}