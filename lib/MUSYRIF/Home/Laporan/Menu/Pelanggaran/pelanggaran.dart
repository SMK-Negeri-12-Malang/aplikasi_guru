import 'package:flutter/material.dart';
import 'package:aplikasi_guru/ANIMASI/widgets/custom_app_bar.dart';

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
  final TextEditingController _iqobController =
      TextEditingController(); // Add iqob controller
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
    'Menggunakan handphone saat pembelajaran':
        'Menyerahkan handphone selama seminggu',
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
          .where((siswa) =>
              siswa['nama']!.toLowerCase().startsWith(query.toLowerCase()))
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
      // Check for duplicates
      bool isDuplicate = laporanList.any((laporan) =>
          laporan.nama == _namaController.text &&
          laporan.kamar == _kamarController.text &&
          laporan.pelanggaran == _selectedPelanggaran &&
          laporan.tanggal == _tanggalController.text);

      if (!isDuplicate) {
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
          SnackBar(content: Text('Data pelanggaran sudah ada!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi semua data!')),
      );
    }
  }

  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 233, 233, 233),
      body: CustomScrollView(
        slivers: [
          CustomGradientAppBar(
            title: 'Laporan Pelanggaran',
            icon: Icons.warning_rounded,
            textColor: Colors.white,
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
                        _namaController,
                        "Nama Santri",
                        Icons.person,
                        onChanged: (value) {
                          _filterSiswa(value);
                        },
                      ),
                      if (_filteredSiswa.isNotEmpty) _buildSuggestionsList(),
                      SizedBox(height: 16),
                      _buildTextField(
                        _kamarController,
                        "Kamar",
                        Icons.room,
                        readOnly: true,
                      ),
                      SizedBox(height: 16),
                      _buildDropdownField(),
                      SizedBox(height: 16),
                      _buildTextField(
                        _tanggalController,
                        "Tanggal",
                        Icons.calendar_today,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        _iqobController,
                        "Hukuman/Iqob",
                        Icons.gavel,
                        readOnly: true,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        _poinController,
                        "Poin Pelanggaran",
                        Icons.stars,
                        readOnly: true,
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
                        onPressed: _submitLaporan,
                        child: Text(
                          'Simpan Laporan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                //blurRadius: 10.0, agar putih mengkilap
                                color: Colors.white,
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
    void Function(String)? onChanged,
    void Function()? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: onTap,
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

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Pilih Jenis Pelanggaran',
        prefixIcon: Icon(Icons.warning, color: Color(0xFF2E3F7F)),
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
      isExpanded: true, // Ensure text remains within the field
      value: _selectedPelanggaran,
      items: _pelanggaranList.map((pelanggaran) {
        return DropdownMenuItem<String>(
          value: pelanggaran,
          child: Text(
            pelanggaran,
            style: TextStyle(
              fontWeight: FontWeight.normal, // Ensure text is not too bold
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedPelanggaran = value;
          _poinController.text = _poinPelanggaran[value]!.toString();
          _iqobController.text = _iqobPelanggaran[value]!;
        });
      },
    );
  }

  Widget _buildSuggestionsList() {
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
          itemCount: _filteredSiswa.length,
          itemBuilder: (context, index) {
            final siswa = _filteredSiswa[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFF2E3F7F).withOpacity(0.1),
                child: Text(
                  siswa['nama']![0],
                  style: TextStyle(
                    color: Color(0xFF2E3F7F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(siswa['nama']!),
              subtitle: Text(siswa['kamar']!),
              onTap: () {
                setState(() {
                  _namaController.text = siswa['nama']!;
                  _kamarController.text = siswa['kamar']!;
                  _filteredSiswa.clear();
                });
              },
            );
          },
        ),
      ),
    );
  }
}
