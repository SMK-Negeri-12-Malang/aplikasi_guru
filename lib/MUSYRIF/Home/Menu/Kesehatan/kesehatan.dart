import 'package:aplikasi_guru/MUSYRIF/Home/Menu/Kesehatan/kesehatan_detail.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_guru/utils/widgets/custom_app_bar.dart';

class Santri {
  final String name;
  final String kamar;

  Santri(this.name, this.kamar);
}

class KesehatanSantri {
  final String name;
  final String kamar;
  final String keluhan;

  KesehatanSantri(
      {required this.name, required this.kamar, required this.keluhan});
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
    Santri("Ahmad", "Kamar A"),
    Santri("Budi", "Kamar B"),
    Santri("Chandra", "Kamar C"),
    Santri("Dewi", "Kamar A"),
    Santri("Eka", "Kamar B"),
    Santri("Faisal", "Kamar C"),
    Santri("Gita", "Kamar A"),
    Santri("Hadi", "Kamar B"),
    Santri("Indra", "Kamar C"),
  ];

  void _updateKamar(String name) {
    setState(() {
      _selectedKamar = _santriList
          .firstWhere((santri) => santri.name == name,
              orElse: () => Santri("", ""))
          .kamar;
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
    kesehatanList
        .add(KesehatanSantri(name: nama, kamar: kamar, keluhan: keluhan));

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
    final screenWidth = MediaQuery.of(context).size.width;
    final filteredSantriList = _santriList
        .where((santri) => santri.name
            .toLowerCase()
            .contains(_nameController.text.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 233, 233, 233),
      body: CustomScrollView(
        slivers: [
          CustomGradientAppBar(
            title: 'Form Kesehatan Santri',
            icon: Icons.medical_services,
            textColor: Colors.white,
            iconColor: Colors.white,
            child: Container(),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                        _nameController,
                        "Nama Santri",
                        Icons.person,
                        onTap: () {
                          setState(() {
                            _showDropdown = true;
                          });
                        },
                        onChange: (value) {
                          setState(() {});
                          _updateKamar(value);
                        },
                      ),
                      if (_showDropdown && filteredSantriList.isNotEmpty)
                        _buildSuggestionsList(filteredSantriList),
                      SizedBox(height: 16),
                      _buildTextField(
                        TextEditingController(text: _selectedKamar),
                        "Kamar",
                        Icons.room,
                        readOnly: true,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        _keluhanController,
                        "Keluhan",
                        Icons.healing,
                        maxLines: 3,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2E3F7F),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _saveData,
                        child: Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                // blurRadius: 10.0,
                                color: Colors.white,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool readOnly = false,
    int? maxLines,
    VoidCallback? onTap,
    Function(String)? onChange,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines ?? 1,
      onTap: onTap,
      onChanged: onChange,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF2E3F7F)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF2E3F7F)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildSuggestionsList(List<Santri> filteredList) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(top: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: 200),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final santri = filteredList[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFF2E3F7F).withOpacity(0.1),
                child: Text(
                  santri.name[0],
                  style: TextStyle(
                    color: Color(0xFF2E3F7F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(santri.name),
              subtitle: Text(santri.kamar),
              onTap: () {
                setState(() {
                  _nameController.text = santri.name;
                  _updateKamar(santri.name);
                  _showDropdown = false;
                });
              },
            );
          },
        ),
      ),
    );
  }
}
