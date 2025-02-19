import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Menu/keuangan.dart';  // Mengimpor halaman lainnya
import 'Menu/perizinan.dart';
import 'Menu/kesehatan.dart';
import 'Menu/guru_siswa.dart';
import 'Menu/notifikasi.dart';
import 'Menu/pengaturan.dart';

class DashboardMusyrifPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardMusyrifPage> {
  String _name = 'User';
  String _email = 'Teknologi Informasi';
  String? _profileImagePath;
  final List<String> _galleryImages = [];

  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? 'User';
      _email = prefs.getString('email') ?? 'Teknologi Informasi';
      _profileImagePath = prefs.getString('profileImagePath');
    });
  }

  // Fungsi untuk pindah halaman berdasarkan nama button
  void _onButtonPressed(String buttonType) {
    print("Button pressed: $buttonType");
    switch (buttonType) {
      case 'Keuangan':
        Navigator.push(context, MaterialPageRoute(builder: (context) => KeuanganPage()));
        break;
      case 'Perizinan':
        Navigator.push(context, MaterialPageRoute(builder: (context) => PerizinanPage()));
        break;
      case 'Kesehatan':
        Navigator.push(context, MaterialPageRoute(builder: (context) => KesehatanPage()));
        break;
      case 'Guru & Siswa':
        Navigator.push(context, MaterialPageRoute(builder: (context) => GuruSiswa()));
        break;
      case 'Notifikasi':
        Navigator.push(context, MaterialPageRoute(builder: (context) => NotifikasiPage()));
        break;
      case 'Pengaturan':
        Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanPage()));
        break;
      default:
        print('Unknown button type');
    }
  }

  // Menambahkan gambar ke gallery
  void _addGalleryImageUrl() {
    setState(() {
      _galleryImages.add(_urlController.text);
      _urlController.clear();
    });
    Navigator.of(context).pop();
  }

  void _showAddImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Image URL'),
          content: TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Enter Image URL',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addGalleryImageUrl,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: _profileImagePath != null
                              ? NetworkImage(_profileImagePath!)
                              : AssetImage('assets/default_profile.png') as ImageProvider,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _email,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          centerTitle: true,
          elevation: 10.0,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Buttons
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3, // 3 columns
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0,
                  children: [
                    _buildIconButton(Icons.account_balance_wallet, 'Keuangan'),
                    _buildIconButton(Icons.card_travel, 'Perizinan'),
                    _buildIconButton(Icons.healing, 'Kesehatan'),
                    _buildIconButton(Icons.group, 'Guru & Siswa'),
                    _buildIconButton(Icons.notifications, 'Notifikasi'),
                    _buildIconButton(Icons.settings, 'Pengaturan'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Gallery Title with Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gallery',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showAddImageDialog,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Display Gallery Images
              Column(
                children: _galleryImages.map((url) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label) {
    return GestureDetector(
      onTap: () => _onButtonPressed(label),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.shade100,
            child: Icon(icon, size: 30, color: Colors.blue.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
