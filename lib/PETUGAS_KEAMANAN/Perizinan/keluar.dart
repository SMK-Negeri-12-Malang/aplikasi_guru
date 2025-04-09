import 'package:aplikasi_guru/ANIMASI/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class KeluarPage extends StatefulWidget {
  @override
  _KeluarPageState createState() => _KeluarPageState();
}

class _KeluarPageState extends State<KeluarPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _siswaController = TextEditingController();
  final TextEditingController _kamarController = TextEditingController();
  final TextEditingController _halaqohController = TextEditingController();
  final TextEditingController _musyrifController = TextEditingController();
  final TextEditingController _keperluanController = TextEditingController();
  final TextEditingController _tanggalIzinController = TextEditingController();
  final TextEditingController _tanggalKembaliController = TextEditingController();

  final List<String> _kelasOptions = ['Kelas 1', 'Kelas 2', 'Kelas 3']; // Add class options
  String? _selectedKelas = 'Kelas 1'; // Default selected class

  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: 1)),
      ),
    );
    if (picked != null) {
      setState(() {
        _tanggalIzinController.text =
            "${picked.start.day}-${picked.start.month}-${picked.start.year}";
        _tanggalKembaliController.text =
            "${picked.end.day}-${picked.end.month}-${picked.end.year}";
      });
    }
  }

  Future<void> _saveToLocalStorage(Map<String, dynamic> newData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> existingDataJson = prefs.getStringList('perizinan_data') ?? [];
      List<Map<String, dynamic>> existingData = existingDataJson
          .map((str) => json.decode(str) as Map<String, dynamic>)
          .toList();
      
      existingData.add(newData);
      List<String> updatedDataJson = existingData
          .map((data) => json.encode(data))
          .toList();
          
      await prefs.setStringList('perizinan_data', updatedDataJson);
    } catch (e) {
      print('Error saving data: $e');
      throw e;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final data = {
          'nama': _siswaController.text,
          'kamar': _kamarController.text,
          'kelas': _selectedKelas!,
          'halaqoh': _halaqohController.text,
          'musyrif': _musyrifController.text,
          'keperluan': _keperluanController.text,
          'tanggalIzin': _tanggalIzinController.text,
          'tanggalKembali': _tanggalKembaliController.text,
          'status': 'Keluar',
          'isKembali': false,
          'timestamp': DateTime.now().toIso8601String(),
        };

        await _saveToLocalStorage(data);

        // Clear form
        _formKey.currentState!.reset();
        _selectedKelas = 'Kelas 1';
        _tanggalIzinController.clear();
        _tanggalKembaliController.clear();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil disimpan')),
        );

        Navigator.pop(context, true); // Return true to indicate success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Color(0xFF2E3F7F),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Formulir Keluar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(_siswaController, 'Nama Siswa', Icons.person),
                        SizedBox(height: 16),
                        _buildTextField(_kamarController, 'Kamar', Icons.room),
                        SizedBox(height: 16),
                        _buildDropdownField('Kelas', Icons.class_), // Replace text field with dropdown
                        SizedBox(height: 16),
                        _buildTextField(_halaqohController, 'Halaqoh', Icons.group),
                        SizedBox(height: 16),
                        _buildTextField(_musyrifController, 'Musyrif', Icons.supervisor_account),
                        SizedBox(height: 16),
                        _buildTextField(_keperluanController, 'Keperluan', Icons.note),
                        SizedBox(height: 16),
                        _buildDateField(_tanggalIzinController, 'Tanggal Izin', Icons.calendar_today, () => _selectDateRange(context)),
                        SizedBox(height: 16),
                        _buildDateField(_tanggalKembaliController, 'Tanggal Kembali', Icons.calendar_today, null, readOnly: true),
                        SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2E3F7F),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _submitForm,
                          child: Text(
                            'Simpan Data',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF2E3F7F)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Field ini wajib diisi';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(TextEditingController controller, String label, IconData icon, VoidCallback? onTap, {bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly || onTap == null,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF2E3F7F)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Field ini wajib diisi';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField(String label, IconData icon) {
    return DropdownButtonFormField<String>(
      value: _selectedKelas,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF2E3F7F)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (String? newValue) {
        setState(() {
          _selectedKelas = newValue;
        });
      },
      items: _kelasOptions.map((kelas) {
        return DropdownMenuItem(
          value: kelas,
          child: Text(kelas),
        );
      }).toList(),
    );
  }
}
