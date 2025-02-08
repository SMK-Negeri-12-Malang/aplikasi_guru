import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class NewsPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onNewsAdded;

  NewsPage({required this.onNewsAdded});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _jenisController = TextEditingController();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _tempatController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _submitNews() {
    if (_jenisController.text.isNotEmpty &&
        _judulController.text.isNotEmpty &&
        _tempatController.text.isNotEmpty &&
        _deskripsiController.text.isNotEmpty &&
        _selectedImage != null) {
      final news = {
        'jenis': _jenisController.text,
        'judul': _judulController.text,
        'tempat': _tempatController.text,
        'deskripsi': _deskripsiController.text,
        'image': _selectedImage,
      };
      widget.onNewsAdded(news);
      Navigator.pop(context); // Ensure this navigates back to DashboardPage
    } else {
      // Tampilkan pesan error jika ada field yang kosong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi semua field dan pilih gambar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Tambah Informasi",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildInputSection(
              title: 'Jenis Informasi',
              child: _buildTextField('Masukkan jenis informasi', controller: _jenisController, maxLines: 1),
            ),
            
            _buildInputSection(
              title: 'Judul Informasi',
              child: _buildTextField('Masukkan judul informasi', controller: _judulController, maxLines: 1),
            ),
            
            _buildInputSection(
              title: 'Tempat',
              child: _buildTextField('Masukkan tempat', controller: _tempatController, maxLines: 3),
            ),
            
            _buildInputSection(
              title: 'Deskripsi',
              child: _buildTextField('Masukkan deskripsi', controller: _deskripsiController, maxLines: 4),
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
            
            Center(
              child: ElevatedButton(
                onPressed: _submitNews,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[600],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 48,
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
            ),
          ],
        ),
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

  Widget _buildTextField(String hint, {required TextEditingController controller, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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