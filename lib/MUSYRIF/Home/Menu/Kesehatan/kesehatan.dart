import 'package:flutter/material.dart';

class Santri {
  final String name;
  final String kelas;

  Santri(this.name, this.kelas);
}

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
    Santri("Joko", "10A"), Santri("Kiki", "11B"), Santri("Lina", "12C"),
    Santri("Mira", "10A"), Santri("Nanda", "11B"), Santri("Omar", "12C"),
    Santri("Putri", "10A"), Santri("Qori", "11B"), Santri("Rizki", "12C"),
    Santri("Siti", "10A"), Santri("Taufik", "11B"), Santri("Umar", "12C"),
    Santri("Vina", "10A"), Santri("Wahyu", "11B"), Santri("Xenia", "12C"),
    Santri("Yogi", "10A"), Santri("Zahra", "11B"), Santri("Bagas", "12C"),
    Santri("Citra", "10A"), Santri("Dian", "11B"), Santri("Edo", "12C"),
  ];

  void _updateClass(String name) {
    setState(() {
      _selectedClass = _santriList.firstWhere((santri) => santri.name == name, orElse: () => Santri("", "")).kelas;
    });
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
              onPressed: () {
                String nama = _nameController.text;
                String kelas = _selectedClass ?? "-";
                String keluhan = _keluhanController.text;

                if (nama.isEmpty || keluhan.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Harap isi semua data")),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Data disimpan: $nama - $kelas - $keluhan")),
                );
              },
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
