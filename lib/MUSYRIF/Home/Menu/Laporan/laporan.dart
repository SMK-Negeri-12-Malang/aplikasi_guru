import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class Laporan extends StatefulWidget {
  final Function(Map<String, dynamic>) onNewsAdded;

  Laporan({required this.onNewsAdded});

  @override
  _LaporanGuruState createState() => _LaporanGuruState();
}

class _LaporanGuruState extends State<Laporan> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? _selectedViolation;
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _poinController = TextEditingController();

  final Map<String, List<String>> _namaSiswaPerKelas = {
    'Kelas 1': ['Ahmad', 'Ayu', 'Asep'],
    'Kelas 2': ['Budi', 'Bambang', 'Beni'],
    'Kelas 3': ['Citra', 'Cici', 'Cahyo'],
    'Kelas 4': ['Dewi', 'Dian', 'Dodi'],
    'Kelas 5': ['Eko', 'Eka', 'Endang'],
    'Kelas 6': ['Fajar', 'Fani', 'Fauzi'],
  };

  final Map<String, int> _violations = {
    'Terlambat': 5,
    'Tidak mengerjakan PR': 10,
    'Membolos': 15,
    'Berkelahi': 20,
    'Tidak berpakaian rapi': 5,
    'Menggunakan handphone saat pembelajaran': 10,
  };

  String? _selectedNama;
  String? _selectedKelas;

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
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

  void _onNamaSelected(String? nama) {
    if (nama != null) {
      setState(() {
        _selectedNama = nama;
        _selectedKelas = _namaSiswaPerKelas.entries
            .firstWhere((entry) => entry.value.contains(nama),
                orElse: () => MapEntry('', []))
            .key;
      });
    }
  }

  void _submitNews() {
    if (_selectedNama != null &&
        _selectedKelas != null &&
        _selectedViolation != null &&
        _selectedImage != null &&
        _tanggalController.text.isNotEmpty) {
      final news = {
        'Nama': _selectedNama,
        'Kelas': _selectedKelas,
        'Pelanggaran': _selectedViolation,
        'Image': _selectedImage,
        'Tanggal': _tanggalController.text,
        'Poin': _violations[_selectedViolation],
      };
      widget.onNewsAdded(news);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Harap isi semua field')));
    }
  }

  String _getSeverity(int points) {
    if (points <= 5) return 'Ringan';
    if (points <= 15) return 'Sedang';
    return 'Berat';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Laporan')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                return _namaSiswaPerKelas.values.expand((x) => x).where(
                      (option) => option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()),
                    );
              },
              onSelected: _onNamaSelected,
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Nama Siswa',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.all(10),
                  ),
                );
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: _selectedKelas),
              decoration: InputDecoration(
                labelText: 'Kelas',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.all(10),
              ),
              readOnly: true,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Jenis Pelanggaran',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.all(10),
              ),
              value: _selectedViolation,
              items: _violations.keys.map((String violation) {
                return DropdownMenuItem<String>(
                  value: violation,
                  child: Text(violation),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedViolation = newValue;
                  if (newValue != null) {
                    _poinController.text = _violations[newValue]!.toString();
                  }
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _tanggalController,
              decoration: InputDecoration(
                labelText: 'Tanggal',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.all(10),
              ),
              readOnly: true,
              onTap: _pickDate,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _poinController,
              decoration: InputDecoration(
                labelText: 'Poin Pelanggaran',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.all(10),
              ),
              readOnly: true,
            ),
            SizedBox(height: 10),
            if (_selectedViolation != null)
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text('Tingkat Pelanggaran: '),
                    Text(
                      _getSeverity(_violations[_selectedViolation]!),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getSeverity(_violations[_selectedViolation]!) == 'Ringan'
                            ? Colors.green
                            : _getSeverity(_violations[_selectedViolation]!) == 'Sedang'
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 20),
            if (_selectedImage != null)
              Container(
                height: 200,
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitNews,
              child: Text(
                'Kirim',
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 45),
                backgroundColor: Colors.green,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}