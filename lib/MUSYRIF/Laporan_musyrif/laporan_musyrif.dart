import 'dart:io';
import 'package:aplikasi_ortu/MUSYRIF/Laporan_musyrif/laporan_kelas_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class LaporanGuru extends StatefulWidget {
  final Function(Map<String, dynamic>) onNewsAdded;

  LaporanGuru({required this.onNewsAdded});

  @override
  _LaporanGuruState createState() => _LaporanGuruState();
}

class _LaporanGuruState extends State<LaporanGuru> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _waktuController = TextEditingController();
  final TextEditingController _poinController = TextEditingController();
  final List<String> _kelasList = ['Kelas 1', 'Kelas 2', 'Kelas 3', 'Kelas 4', 'Kelas 5', 'Kelas 6'];
  final Map<String, List<String>> _namaSiswaPerKelas = {
    'Kelas 1': ['Ahmad', 'Ayu', 'Asep', 'Arif', 'Aulia', 'Andi', 'Anita', 'Adit', 'Aldo', 'Alya', 'Ari', 'Ariani', 'Arman', 'Arsyad', 'Asih', 'Asri', 'Astuti', 'Aulia', 'Awan', 'Ayu'],
    'Kelas 2': ['Budi', 'Bambang', 'Beni', 'Bagus', 'Bima', 'Bayu', 'Bella', 'Bobby', 'Budiarti', 'Bunga', 'Burhan', 'Bustanul', 'Bintang', 'Berlian', 'Berliana', 'Berlian', 'Berlian', 'Berlian'],
    'Kelas 3': ['Citra', 'Cici', 'Cahyo', 'Candra', 'Cahya', 'Cipto', 'Cindy', 'Citra', 'Cici', 'Cahyo', 'Candra', 'Cahya', 'Cipto', 'Cindy', 'Citra', 'Cici', 'Cahyo', 'Candra', 'Cahya', 'Cipto'],
    'Kelas 4': ['Dewi', 'Dian', 'Dodi', 'Dina', 'Dimas', 'Damar', 'Dewi', 'Dian', 'Dodi', 'Dina', 'Dimas', 'Damar', 'Dewi', 'Dian', 'Dodi', 'Dina', 'Dimas', 'Damar', 'Dewi', 'Dian'],
    'Kelas 5': ['Eko', 'Eka', 'Endang', 'Eris', 'Evan', 'Evelyn', 'Eko', 'Eka', 'Endang', 'Eris', 'Evan', 'Evelyn', 'Eko', 'Eka', 'Endang', 'Eris', 'Evan', 'Evelyn', 'Eko', 'Eka'],
    'Kelas 6': ['Fajar', 'Fani', 'Fauzi', 'Farah', 'Fikri', 'Fina', 'Fajar', 'Fani', 'Fauzi', 'Farah', 'Fikri', 'Fina', 'Fajar', 'Fani', 'Fauzi', 'Farah', 'Fikri', 'Fina', 'Fajar', 'Fani']
  };
  String? _selectedKelas;
  String? _selectedNama;
  List<Map<String, dynamic>> _savedReports = [];

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _tanggalController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _waktuController.text = pickedTime.format(context);
      });
    }
  }

  void _submitNews() {
    if (_selectedNama != null &&
        _selectedKelas != null &&
        _deskripsiController.text.isNotEmpty &&
        _selectedImage != null &&
        _tanggalController.text.isNotEmpty &&
        _waktuController.text.isNotEmpty &&
        _poinController.text.isNotEmpty) {
      final int poin = int.parse(_poinController.text);
      final existingReportIndex = _savedReports.indexWhere((report) => report['Nama'] == _selectedNama && report['kelas'] == _selectedKelas);
      
      if (existingReportIndex != -1) {
        setState(() {
          _savedReports[existingReportIndex]['poin'] += poin;
          _savedReports[existingReportIndex]['deskripsi'] += '\n${_deskripsiController.text}';
        });
      } else {
        final news = {
          'Nama': _selectedNama,
          'kelas': _selectedKelas,
          'deskripsi': _deskripsiController.text,
          'image': _selectedImage,
          'tanggal': _tanggalController.text,
          'waktu': _waktuController.text,
          'poin': poin,
        };
        widget.onNewsAdded(news);
        setState(() {
          _savedReports.add(news);
        });
      }

      // Clear the form fields after submission
      _judulController.clear();
      _deskripsiController.clear();
      _tanggalController.clear();
      _waktuController.clear();
      _poinController.clear();
      _selectedImage = null;
      _selectedNama = null;
      _selectedKelas = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Laporan berhasil dikirim')),
      );
    } else {
      // Tampilkan pesan error jika ada field yang kosong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi semua field dan pilih gambar')),
      );
    }
  }

  void _showSavedReports() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Laporan Sebelumnya'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _kelasList.length,
            itemBuilder: (context, index) {
              final kelas = _kelasList[index];
              return Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(kelas),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LaporanKelasPage(
                          kelas: kelas,
                          reports: _savedReports.where((report) => report['kelas'] == kelas).toList(),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildInputSection(
                  title: 'Nama',
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return (_namaSiswaPerKelas[_selectedKelas] ?? []).where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      setState(() {
                        _selectedNama = selection;
                      });
                    },
                    fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'Masukkan nama siswa',
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.indigo[400]!, width: 1.5),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      );
                    },
                  ),
                ),
                
                _buildInputSection(
                  title: 'Kelas',
                  child: DropdownButtonFormField<String>(
                    value: _selectedKelas,
                    items: _kelasList.map((String kelas) {
                      return DropdownMenuItem<String>(
                        value: kelas,
                        child: Text(kelas),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedKelas = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.indigo[400]!, width: 1.5),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                
                _buildInputSection(
                  title: 'Deskripsi',
                  child: _buildTextField('Masukkan deskripsi', controller: _deskripsiController, maxLines: 4),
                ),
                
                _buildInputSection(
                  title: 'Tanggal',
                  child: InkWell(
                    onTap: _pickDate,
                    child: IgnorePointer(
                      child: _buildTextField('Pilih tanggal', controller: _tanggalController, maxLines: 1),
                    ),
                  ),
                ),
                
                _buildInputSection(
                  title: 'Waktu',
                  child: InkWell(
                    onTap: _pickTime,
                    child: IgnorePointer(
                      child: _buildTextField('Pilih waktu', controller: _waktuController, maxLines: 1),
                    ),
                  ),
                ),
                
                _buildInputSection(
                  title: 'Poin Pelanggaran',
                  child: _buildTextField('Masukkan poin pelanggaran', controller: _poinController, maxLines: 1, keyboardType: TextInputType.number),
                ),
                
                _buildInputSection(
                  title: 'Foto',
                  child: Column(
                    children: [
                      InkWell(
                        onTap: _pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.photo_library_outlined, 
                                   color: Colors.grey[600]),
                              SizedBox(width: 12),
                              Text(
                                'Pilih foto dari galeri',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_selectedImage != null) ...[
                        SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _submitNews,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[600],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                      child: Text(
                        'Kirim Informasi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _showSavedReports,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                      child: Text(
                        'Lihat Laporan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: IgnorePointer(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Transform.rotate(
                      angle: -0.3,
                      child: Text(
                        'UNTUK\nMUSYRIF',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 120,
                          height: 0.9,
                          fontWeight: FontWeight.w800,
                          // ignore: deprecated_member_use
                          color: Colors.grey.withOpacity(0.15),
                        ),
                      ),
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

  Widget _buildInputSection({
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, {required TextEditingController controller, int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo[400]!, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 16 : 12,
        ),
      ),
    );
  }
}

