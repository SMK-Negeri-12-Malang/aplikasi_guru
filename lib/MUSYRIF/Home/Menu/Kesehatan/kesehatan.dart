import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Kesehatan/kesehatan_detail.dart';
import 'package:flutter/material.dart';
 // Impor halaman detail

class Santri {
  final String name;
  final String kelas;

  Santri(this.name, this.kelas);
}

class KesehatanSantri {
  final String name;
  final String kelas;
  final String keluhan;

  KesehatanSantri({required this.name, required this.kelas, required this.keluhan});
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
  String? _selectedClass;
  bool _showDropdown = false;
  bool _showAllNames = false;

  final List<Santri> _santriList = [
    Santri("Ahmad", "10A"), Santri("Budi", "11B"), Santri("Chandra", "12C"),
    Santri("Dewi", "10A"), Santri("Eka", "11B"), Santri("Faisal", "12C"),
    Santri("Gita", "10A"), Santri("Hadi", "11B"), Santri("Indra", "12C"),
  ];

  void _updateClass(String name) {
    setState(() {
      _selectedClass = _santriList.firstWhere((santri) => santri.name == name, orElse: () => Santri("", "")).kelas;
    });
  }

  void _saveData() {
    String nama = _nameController.text;
    String kelas = _selectedClass ?? "-";
    String keluhan = _keluhanController.text;

    if (nama.isEmpty || keluhan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Harap isi semua data")),
      );
      return;
    }

    // Simpan data ke list global
    kesehatanList.add(KesehatanSantri(name: nama, kelas: kelas, keluhan: keluhan));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Data disimpan: $nama - $kelas - $keluhan")),
    );

    // Kosongkan input setelah simpan
    _nameController.clear();
    _keluhanController.clear();
    setState(() {
      _selectedClass = null;
    });

    // Pindah ke halaman detail
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailKesehatan(kamar: kelas)),
    );
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
                _updateClass(value);
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
                              _updateClass(santri.name);
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
              controller: TextEditingController(text: _selectedClass),
              decoration: InputDecoration(
                labelText: "Kelas",
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
