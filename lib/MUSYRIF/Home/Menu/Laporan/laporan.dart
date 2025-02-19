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
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _waktuController = TextEditingController();
  final TextEditingController _poinController = TextEditingController();

  final Map<String, List<String>> _namaSiswaPerKelas = {
    'Kelas 1': ['Ahmad', 'Ayu', 'Asep'],
    'Kelas 2': ['Budi', 'Bambang', 'Beni'],
    'Kelas 3': ['Citra', 'Cici', 'Cahyo'],
    'Kelas 4': ['Dewi', 'Dian', 'Dodi'],
    'Kelas 5': ['Eko', 'Eka', 'Endang'],
    'Kelas 6': ['Fajar', 'Fani', 'Fauzi'],
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
        _deskripsiController.text.isNotEmpty &&
        _selectedImage != null &&
        _tanggalController.text.isNotEmpty &&
        _waktuController.text.isNotEmpty &&
        _poinController.text.isNotEmpty) {
      final news = {
        'Nama': _selectedNama,
        'Kelas': _selectedKelas,
        'Deskripsi': _deskripsiController.text,
        'Image': _selectedImage,
        'Tanggal': _tanggalController.text,
        'Waktu': _waktuController.text,
        'Poin': int.parse(_poinController.text),
      };
      widget.onNewsAdded(news);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Harap isi semua field')));
    }
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
            TextField(
              controller: _deskripsiController,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.all(10),
              ),
              maxLines: 3,
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
              controller: _waktuController,
              decoration: InputDecoration(
                labelText: 'Waktu',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.all(10),
              ),
              readOnly: true,
              onTap: _pickTime,
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
              keyboardType: TextInputType.number,
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
