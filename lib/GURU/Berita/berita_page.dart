import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class NewsPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onNewsAdded;

  NewsPage({required this.onNewsAdded});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _tempatController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _waktuController = TextEditingController();

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

  void _submitNews() async {
    if (_judulController.text.isNotEmpty &&
        _tempatController.text.isNotEmpty &&
        _deskripsiController.text.isNotEmpty &&
        _selectedImage != null &&
        _tanggalController.text.isNotEmpty &&
        _waktuController.text.isNotEmpty) {
      try {
        // Save image to app's permanent directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'news_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = await _selectedImage!.copy('${appDir.path}/$fileName');

        final news = {
          'judul': _judulController.text,
          'tempat': _tempatController.text,
          'deskripsi': _deskripsiController.text,
          'image': savedImage,
          'imagePath': savedImage.path,
          'tanggal': _tanggalController.text,
          'waktu': _waktuController.text,
        };

        widget.onNewsAdded(news);
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berita berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error saving news: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan berita'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi semua field dan pilih gambar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Tambah Informasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
                              
                              fit: BoxFit.contain,
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
                        backgroundColor: Color(0xFF2E3F7F),
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

