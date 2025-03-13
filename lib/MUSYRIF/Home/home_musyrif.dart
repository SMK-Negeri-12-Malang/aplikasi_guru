import 'dart:io';

import 'package:aplikasi_guru/MUSYRIF/Home/Menu/Kesehatan/kesehatan.dart';
import 'package:aplikasi_guru/MUSYRIF/Home/Menu/Laporan/pelanggaran.dart';
import 'package:aplikasi_guru/MUSYRIF/Home/Menu/Izin/izin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadProfileData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      setState(() {
      });
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      setState(() {
      });
    }
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2E3F7F),
              const Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadProfileData,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        // Profile and notification section
                        Padding(
                          padding: EdgeInsets.only(
                              top: 50, left: 20, right: 20, bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.white,
                                    backgroundImage: _profileImagePath != null
                                        ? FileImage(File(_profileImagePath!))
                                        : AssetImage('assets/default_profile.png')
                                            as ImageProvider,
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _name,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        _email,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // News Section and Class Assignments remain the same
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
              },
            ),
          ),
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
