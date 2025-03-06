import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Kesehatan/kesehatan.dart';
import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Laporan/pelanggaran.dart';
import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Izin/izin.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Widgets/berita_baru.dart';
import 'Widgets/gallery_section.dart';
import 'Widgets/berita.dart';

class DashboardMusyrifPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardMusyrifPage> {
  String _name = 'User';
  String _email = 'Teknologi Informasi';
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? 'User';
      _email = prefs.getString('user_email') ?? 'Teknologi Informasi';
      _profileImagePath = prefs.getString('profile_image_path');
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight =
        screenHeight * 0.15; // Adjust the height based on screen size

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 233, 233),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
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
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: _profileImagePath != null
                              ? NetworkImage(_profileImagePath!)
                              : AssetImage('assets/default_profile.png')
                                  as ImageProvider,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NewsCarousel(),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: [
                        _buildMenuCard(Icons.report, 'Pelanggaran'),
                        _buildMenuCard(Icons.card_travel, 'Perizinan'),
                        _buildMenuCard(Icons.healing, 'Kesehatan'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GallerySection(),
                  ActivitySection(),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(IconData icon, String label) {
    return GestureDetector(
      onTap: () => _onButtonPressed(label),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.blue.shade700),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onButtonPressed(String buttonType) {
    print("Button pressed: $buttonType");
    switch (buttonType) {
      case 'Pelanggaran':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Laporan(
                    // Handle the news added
                    )));
        break;
      case 'Perizinan':
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => IzinPage()));
        break;
      case 'Kesehatan':
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Kesehatan()));
        break;
      default:
        print('Unknown button type');
    }
  }
}
