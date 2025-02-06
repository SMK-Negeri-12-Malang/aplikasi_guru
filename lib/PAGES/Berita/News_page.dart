import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  File? _selectedImage; // Variabel untuk menyimpan gambar
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Tambah Informasi",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Jenis Informasi
            _buildSectionTitle('Jenis Informasi:'),
            _buildTextField('Masukkan jenis informasi'),
            SizedBox(height: 16.0),

            // Judul Informasi
            _buildSectionTitle('Judul Informasi:'),
            _buildTextField('Masukkan judul informasi'),
            SizedBox(height: 16.0),

            // Waktu dan Tempat
            _buildSectionTitle('Waktu Dan Tempat:'),
            _buildTextField('Masukkan waktu dan tempat'),
            SizedBox(height: 16.0),

            // Deskripsi
            _buildSectionTitle('Deskripsi:'),
            _buildTextField('Masukkan deskripsi', maxLines: 3),
            SizedBox(height: 16.0),

            // Foto (Ganti Attach File dengan Upload Gambar)
            _buildSectionTitle('Foto:'),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('Pilih foto', enabled: false),
                ),
                IconButton(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image), // Ikon diganti ke 'image'
                  color: Colors.blue,
                ),
              ],
            ),

            // Tampilkan Gambar yang Dipilih
            if (_selectedImage != null) ...[
              SizedBox(height: 10),
              Center(
                child: Image.file(_selectedImage!,
                    width: 200, height: 200, fit: BoxFit.cover),
              ),
            ],

            SizedBox(height: 32.0),

            // Tombol Kirim
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Fungsi untuk menambahkan informasi
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: Colors.blue, width: 2),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: Text(
                  'Kirim',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget untuk judul setiap bagian
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget untuk input textfield
  Widget _buildTextField(String hint, {int maxLines = 1, bool enabled = true}) {
    return TextField(
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.blue[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}