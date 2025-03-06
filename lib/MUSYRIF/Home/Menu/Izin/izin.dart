import 'package:aplikasi_ortu/utils/widgets/custom_app_bar.dart';
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
  IzinModel(
      nama: 'Ahmad',
      tanggal: '01-02-2025 to 05-02-2025',
      kamar: 'Kelas A',
      halaqo: 'Halaqo 1',
      musyrif: 'Ustadz Ali'),
  IzinModel(
      nama: 'Aisyah',
      tanggal: '02-02-2025 to 06-02-2025',
      kamar: 'Kelas A',
      halaqo: 'Halaqo 2',
      musyrif: 'Ustadzah Fatimah'),
];

class IzinPage extends StatefulWidget {
  @override
  _IzinState createState() => _IzinState();
}

class _IzinState extends State<IzinPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tanggalMulaiController = TextEditingController();
  final TextEditingController _tanggalKembaliController =
      TextEditingController();
  final TextEditingController _kamarController = TextEditingController();
  final TextEditingController _halaqoController = TextEditingController();
  final TextEditingController _musyrifController = TextEditingController();

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
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
            tanggal:
                "${_tanggalMulaiController.text} to ${_tanggalKembaliController.text}",
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 233, 233, 233),
      body: CustomScrollView(
        slivers: [
          CustomGradientAppBar(
            title: 'Formulir Izin',
            icon: Icons.edit,
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
                          _namaController, 'Nama Santri', Icons.person),
                      SizedBox(height: 16),
                      Column(
                        children: [
                          _buildDateField(
                            _tanggalMulaiController,
                            'Tanggal keluar',
                            () => _selectDate(context, _tanggalMulaiController),
                          ),
                          SizedBox(height: 16),
                          _buildDateField(
                            _tanggalKembaliController,
                            'Tanggal Kembali',
                            () =>
                                _selectDate(context, _tanggalKembaliController),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildTextField(_kamarController, 'Kamar', Icons.room),
                      SizedBox(height: 16),
                      _buildTextField(_halaqoController, 'Halaqo', Icons.group),
                      SizedBox(height: 16),
                      _buildTextField(_musyrifController, 'Musyrif',
                          Icons.supervisor_account),
                      SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2E3F7F),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _submitIzin,
                        child: Text(
                          'Simpan Izin',
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
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
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

  Widget _buildDateField(
      TextEditingController controller, String label, VoidCallback onTap) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF2E3F7F)),
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
}
