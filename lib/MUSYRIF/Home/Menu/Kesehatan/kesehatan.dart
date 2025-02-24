import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Kesehatan/kesehatan_detail.dart';
import 'package:flutter/material.dart';

class Santri {
  final String name;
  final String kamar;

  Santri(this.name, this.kamar);
}

class KesehatanSantri {
  final String name;
  final String kamar;
  final String keluhan;

  KesehatanSantri({required this.name, required this.kamar, required this.keluhan});
}

// List global untuk menyimpan data kesehatan
List<KesehatanSantri> kesehatanList = [];

class Kesehatan extends StatefulWidget {
  @override
  _KesehatanPageState createState() => _KesehatanPageState();
}

class _KesehatanPageState extends State<Kesehatan> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _keluhanController = TextEditingController();
  String? _selectedKamar;
  bool _showDropdown = false;
  bool _showAllNames = false;

  final List<Santri> _santriList = [
    Santri("Ahmad", "Kamar A"), Santri("Budi", "Kamar B"), Santri("Chandra", "Kamar C"),
    Santri("Dewi", "Kamar A"), Santri("Eka", "Kamar B"), Santri("Faisal", "Kamar C"),
    Santri("Gita", "Kamar A"), Santri("Hadi", "Kamar B"), Santri("Indra", "Kamar C"),
  ];

  void _updateKamar(String name) {
    setState(() {
      _selectedKamar = _santriList.firstWhere((santri) => santri.name == name, orElse: () => Santri("", "")).kamar;
    });
  }

  void _saveData() {
    String nama = _nameController.text;
    String kamar = _selectedKamar ?? "-";
    String keluhan = _keluhanController.text;

    if (nama.isEmpty || keluhan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Harap isi semua data")),
      );
      return;
    }

    // Simpan data ke list global
    kesehatanList.add(KesehatanSantri(name: nama, kamar: kamar, keluhan: keluhan));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Data disimpan: $nama - $kamar - $keluhan")),
    );

    // Kosongkan input setelah simpan
    _nameController.clear();
    _keluhanController.clear();
    setState(() {
      _selectedKamar = null;
    });

    // Pindah ke halaman utama
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final filteredSantriList = _santriList
        .where((santri) => santri.name.toLowerCase().contains(_nameController.text.toLowerCase()))
        .toList();
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Form Kesehatan Santri"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nama Santri",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onTap: () {
                setState(() {
                  _showDropdown = true;
                });
              },
              onChanged: (value) {
                setState(() {});
                _updateKamar(value);
              },
            ),
            if (_showDropdown && filteredSantriList.isNotEmpty)
              Card(
                child: Container(
                  constraints: BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...(_showAllNames 
                          ? filteredSantriList
                          : filteredSantriList.take(9))
                        .map((santri) {
                          return ListTile(
                            title: Text(santri.name),
                            onTap: () {
                              _nameController.text = santri.name;
                              _updateKamar(santri.name);
                              setState(() {
                                _showDropdown = false;
                              });
                            },
                          );
                        }).toList(),
                        if (!_showAllNames && filteredSantriList.length > 9)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showAllNames = true;
                              });
                            },
                            child: Text("Tampilkan Semua"),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: _selectedKamar),
              decoration: InputDecoration(
                labelText: "Kamar",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              readOnly: true,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _keluhanController,
              decoration: InputDecoration(
                labelText: "Keluhan",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: _saveData,
              child: Text(
                "Simpan",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}