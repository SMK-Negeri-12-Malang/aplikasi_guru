import 'package:aplikasi_ortu/LOGIN/login.dart';
import 'package:aplikasi_ortu/PAGES/Absen/absensi_page.dart';
import 'package:aplikasi_ortu/PAGES/Berita/News_page.dart';
import 'package:aplikasi_ortu/PAGES/Chat/listchat_page.dart';
import 'package:aplikasi_ortu/PAGES/Drawer/Laporan_guru/laporan_guru.dart';
import 'package:aplikasi_ortu/PAGES/Drawer/Profil/profil_page.dart';
import 'package:aplikasi_ortu/PAGES/Drawer/Setting/setting_page.dart';
import 'package:aplikasi_ortu/PAGES/Grade/class_selection_page.dart';
import 'package:aplikasi_ortu/PAGES/Grade/grade.dart';
import 'package:aplikasi_ortu/PAGES/Home/Home_Guru.dart';
import 'package:aplikasi_ortu/splashscreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Guru',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

class homeview extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<homeview> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late List<Animation<double>> _bounceAnimations;
  int _currentIndex = 2;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<NavItem> _navItems = [
    NavItem(icon: Icons.newspaper, label: 'Berita'),
    NavItem(icon: Icons.message, label: 'Chat'),
    NavItem(icon: Icons.home, label: 'Home'),
    NavItem(icon: Icons.list, label: 'Absen'),
    NavItem(icon: Icons.note_add, label: 'Grade'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _bounceAnimations = List.generate(
      _navItems.length,
      (index) => Tween<double>(begin: 1.0, end: 1.5).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.0,
            0.8,
            curve: Curves.elasticOut,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 2) {
          setState(() {
            _currentIndex = 2;
            _pageController.jumpToPage(2);
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.blue[700],
          title: Row(
            children: [
              GestureDetector(
                onTap: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
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
            NewsPage(),
            ChatListPage(),
            DashboardPage(),
            AbsensiKelasPage(),
            ClassSelectionPage(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: BottomNavigationBar(
            items: List.generate(_navItems.length, (index) {
              return BottomNavigationBarItem(
                icon: AnimatedBuilder(
                  animation: _bounceAnimations[index],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: index == _currentIndex 
                          ? _bounceAnimations[index].value 
                          : 1.0,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          //color: index == _currentIndex
                            //  ? Colors.blue.withOpacity(0.2)
                              //: Colors.transparent,
                          //borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_navItems[index].icon),
                      ),
                    );
                  },
                ),
                label: _navItems[index].label,
              );
            }),
            currentIndex: _currentIndex,
            selectedItemColor: Colors.blue[700],
            unselectedItemColor: Colors.black54,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            onTap: _onBottomNavTapped,
            showSelectedLabels: true,
            showUnselectedLabels: false,
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;

  NavItem({required this.icon, required this.label});
}