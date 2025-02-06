import 'dart:io';

import 'package:aplikasi_ortu/LOGIN/login.dart';
import 'package:aplikasi_ortu/PAGES/Absen/absensi_page.dart';
import 'package:aplikasi_ortu/PAGES/Berita/News_page.dart';
import 'package:aplikasi_ortu/PAGES/Chat/listchat_page.dart';
import 'package:aplikasi_ortu/PAGES/Drawer/Laporan_guru/laporan_guru.dart';
import 'package:aplikasi_ortu/PAGES/Drawer/Profil/profil_page.dart';
import 'package:aplikasi_ortu/PAGES/Drawer/Setting/setting_page.dart';
import 'package:aplikasi_ortu/PAGES/Grade/grade_page.dart';
import 'package:aplikasi_ortu/PAGES/Home/Home_Guru.dart';
import 'package:aplikasi_ortu/splashscreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class homeview extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<homeview> {
  late PageController _pageController;
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

 @override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      if (_currentIndex != 0) {
        // Jika bukan halaman pertama, pindah ke halaman home
        setState(() {
          _currentIndex = 0;
          _pageController.jumpToPage(0);
        });
        return false; // Mencegah keluar dari aplikasi
      }
      return true; // Keluar dari aplikasi jika sudah di halaman Home
    },
    child: Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue),
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Text(
                  'Purwanto Hermawan S.KON',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
       drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              //decoration: BoxDecoration(
              //color: Colors.blue[300],
              //),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color.fromARGB(255, 115, 115, 115),
                    child: Icon(Icons.person, color: Colors.blue, size: 40),
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Purwanto Hermawan S.KON',
                    style: TextStyle(
                      //  color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'wantoherman123@gmail.com',
                    //style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Laporan Guru'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LaporanGuru()), // Pastikan halaman LaporanGuruPage tersedia
                );
              },
            ),
            Divider(
              thickness: 1,
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()), // Pastikan halaman SettingsPage tersedia
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Konfirmasi Logout"),
                      content: Text("Apakah Anda yakin ingin logout?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Tutup dialog
                          },
                          child: Text("Batal"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Tutup dialog
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      LoginScreen()), // Ganti halaman dengan LogoutPage
                            );
                          },
                          child: Text("Logout"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          //LoginScreen(),
          DashboardPage(),         
          ChatListPage(),
          // ignore: avoid_types_as_parameter_names
          NewsPage(),
          AbsensiKelasPage(),
          GradePage(),
          
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.blue[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        onTap: _onBottomNavTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Absen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_add),
            label: 'Grade',
          ),
        ],
      ),
    ),
  );
}
}
