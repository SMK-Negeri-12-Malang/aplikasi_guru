import 'package:aplikasi_ortu/PAGES/Absen/absensi_page.dart';
import 'package:aplikasi_ortu/PAGES/Laporan_guru/laporan_guru.dart';
import 'package:aplikasi_ortu/PAGES/Grade/class_selection_page.dart';
import 'package:aplikasi_ortu/PAGES/Home/Home_Guru.dart';
import 'package:aplikasi_ortu/PAGES/Profil/profil.dart';
import 'package:aplikasi_ortu/SPLASHSCREEN/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    NavItem(icon: Icons.note_add, label: 'Grade'),
    NavItem(icon: Icons.report, label: 'Laporan'),
    NavItem(icon: Icons.home, label: 'Home'),
    NavItem(icon: Icons.list, label: 'Absen'),
    NavItem(icon: Icons.person, label: 'Profil'),
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

    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profile_image');
    if (imagePath != null) {
      setState(() {
      });
    }
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
        appBar: _currentIndex == 2 || _currentIndex == 4 || _currentIndex == 3 ? null : AppBar(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: Text(_getAppBarTitle(), textAlign: TextAlign.center),
          centerTitle: true,
        ),
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(), // Disable page swiping
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            ClassSelectionPage(),
            LaporanGuru(onNewsAdded: (news) {}),
            DashboardPage(),
            AbsensiKelasPage(),    
            ProfileDetailPage(),
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


  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return '';
      case 1:
        return '';
      case 2:
        return '';
      case 3:
        return '';
      case 4:
        return '';
      default:
        return '';
    }
  }
}

class NavItem {
  final IconData icon;
  final String label;

  NavItem({required this.icon, required this.label});
}