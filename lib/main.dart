import 'package:aplikasi_guru/GURU/Absen/absensi_page.dart';
import 'package:aplikasi_guru/GURU/Grade/class_selection_page.dart';
import 'package:aplikasi_guru/GURU/Jadwal/jadwal_page.dart';
import 'package:aplikasi_guru/GURU/Home/Home_Guru.dart';
import 'package:aplikasi_guru/GURU/Profil/profil.dart';
import 'package:aplikasi_guru/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/page_transitions.dart';
import 'utils/animations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Guru',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFFF5F5F7), // Add this line
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CustomPageTransitionBuilder(),
            TargetPlatform.iOS: CustomPageTransitionBuilder(),
          },
        ),
        splashFactory: InkRipple.splashFactory,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return AppAnimations.fadeSlideIn(
      animation: animation,
      child: child,
    );
  }
}

class homeview extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<homeview> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  int _currentIndex = 2;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<NavItem> _navItems = [
    NavItem(icon: Icons.note_add, label: 'Nilai'),
    NavItem(icon: Icons.calendar_today, label: 'Jadwal'), 
    NavItem(icon: Icons.home, label: 'Home'),
    NavItem(icon: Icons.list, label: 'Absen'),
    NavItem(icon: Icons.person, label: 'Profil'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  
    // Initialize slide animation controller
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart,
    ));

    // Start animation after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
    });

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
    _slideController.dispose();
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
        appBar: _currentIndex == 2 || _currentIndex == 4 || _currentIndex == 3 || _currentIndex == 1 || _currentIndex == 0 ? null : AppBar(
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
            JadwalPage(), // Replace empty Container with JadwalPage
            DashboardPage(),
            AbsensiKelasPage(),    
            ProfileDetailPage(),
          ],
        ),
        bottomNavigationBar: SlideTransition(
          position: _slideAnimation,
          child: Container(
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
                  icon: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(_navItems[index].icon),
                  ),
                  label: _navItems[index].label,
                );
              }),
              currentIndex: _currentIndex,
              selectedItemColor: const Color.fromARGB(255, 33, 93, 153),
              unselectedItemColor: Colors.black54,
        backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
            onTap: _onBottomNavTapped,
              showSelectedLabels: true,
              showUnselectedLabels: false,
            ),
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