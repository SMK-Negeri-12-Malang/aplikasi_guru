import 'package:aplikasi_guru/GURU/Absen/absensi_page.dart';
import 'package:aplikasi_guru/GURU/Grade/grade_home.dart';
import 'package:aplikasi_guru/GURU/Jadwal/jadwal_page.dart';
import 'package:aplikasi_guru/GURU/Home/home_guru.dart';
import 'package:aplikasi_guru/GURU/Profil/profil.dart';
import 'package:aplikasi_guru/GURU_QURAN/Cek_Santri/cek_santri.dart';
import 'package:aplikasi_guru/GURU_QURAN/Home/home_quran.dart';
import 'package:aplikasi_guru/GURU_QURAN/Kepesantrenan/Kepesantrenan.dart';
import 'package:aplikasi_guru/GURU_QURAN/Absensi/absensi.dart';
import 'package:aplikasi_guru/GURU_QURAN/Profil/profil.dart';
import 'package:aplikasi_guru/MUSYRIF/Home/home_musyrif.dart';
import 'package:aplikasi_guru/MUSYRIF/Profil/profil.dart';
import 'package:aplikasi_guru/MUSYRIF/Tugas/tugas.dart';
import 'package:aplikasi_guru/MUSYRIF/keuangan/keuangan.dart';
import 'package:aplikasi_guru/MUSYRIF/Home/Laporan/Lihat_Laporan/laporan_santri.dart';
import 'package:aplikasi_guru/PETUGAS_KEAMANAN/Home/home_petugas.dart';
import 'package:aplikasi_guru/PETUGAS_KEAMANAN/Perizinan/keluar.dart';
import 'package:aplikasi_guru/PETUGAS_KEAMANAN/Perizinan/masuk.dart';
import 'package:aplikasi_guru/SPLASHSCREEN/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_guru/data/test_data.dart';
import 'ANIMASI/page_transitions.dart';
import 'ANIMASI/animations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TestData.initializeTestData();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Sekolah',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFFF5F5F7),
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

// Enum to represent user roles
enum UserRole { guru, musyrif, guru_quran, petugas_keamanan }

// Main dashboard view that decides which role's dashboard to display
class homeview extends StatefulWidget {
  final UserRole role;

  // Default to guru role if not specified
  const homeview({Key? key, this.role = UserRole.guru}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<homeview>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // Show the appropriate dashboard based on role
    if (widget.role == UserRole.guru) {
      return GuruDashboard();
    } else if (widget.role == UserRole.guru_quran) {
      return GuruQuranDashboard();
    } else if (widget.role == UserRole.petugas_keamanan) {
      return PetugasKeamananDashboard();
    } else {
      return MusyrifDashboard();
    }
  }
}

// Teacher's dashboard implementation
class GuruDashboard extends StatefulWidget {
  @override
  _GuruDashboardState createState() => _GuruDashboardState();
}

class _GuruDashboardState extends State<GuruDashboard>
    with SingleTickerProviderStateMixin {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
    });

    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profile_image');
    if (imagePath != null) {
      setState(() {});
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
        appBar: _currentIndex == 2 ||
                _currentIndex == 4 ||
                _currentIndex == 3 ||
                _currentIndex == 1 ||
                _currentIndex == 0
            ? null
            : AppBar(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                title: Text(_getAppBarTitle(), textAlign: TextAlign.center),
                centerTitle: true,
              ),
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            ClassSelectionPage(),
            JadwalPage(),
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

// Musyrif's dashboard implementation
class MusyrifDashboard extends StatefulWidget {
  @override
  _MusyrifDashboardState createState() => _MusyrifDashboardState();
}

class _MusyrifDashboardState extends State<MusyrifDashboard>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late List<Animation<double>> _bounceAnimations;
  int _currentIndex = 2;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<NavItem> _navItems = [
    NavItem(icon: Icons.task, label: 'Tugas'),
    NavItem(icon: Icons.account_balance_wallet, label: 'keuangan'),
    NavItem(icon: Icons.home, label: 'Home'),
    NavItem(icon: Icons.report, label: 'Laporan'),
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
      setState(() {});
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
        appBar: _currentIndex == 2 ||
                _currentIndex == 4 ||
                _currentIndex == 3 ||
                _currentIndex == 1 ||
                _currentIndex == 0
            ? null
            : AppBar(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                title: Text(_getAppBarTitle(), textAlign: TextAlign.center),
                centerTitle: true,
              ),
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            TugasPage(),
            KeuanganSantriPage(),
            DashboardMusyrifPage(),
            LaporanSantri(),
            profilmusryf(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
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
    return '';
  }
}

// Guru Quran dashboard implementation
class GuruQuranDashboard extends StatefulWidget {
  @override
  _GuruQuranDashboardState createState() => _GuruQuranDashboardState();
}

class _GuruQuranDashboardState extends State<GuruQuranDashboard>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  int _currentIndex = 2;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<NavItem> _navItems = [
    NavItem(icon: Icons.menu_book, label: 'Absensi'),
    NavItem(icon: Icons.calendar_today, label: 'Cek Santri'), 

    NavItem(icon: Icons.home, label: 'Home'),
    NavItem(icon: Icons.list, label: 'Kepesantrenan'),
    NavItem(icon: Icons.person, label: 'Profil'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
    });

    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profile_image');
    if (imagePath != null) {
      setState(() {});
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
        appBar: _currentIndex == 2 ||
                _currentIndex == 4 ||
                _currentIndex == 3 ||
                _currentIndex == 1 ||
                _currentIndex == 0
            ? null
            : AppBar(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                title: Text(_getAppBarTitle(), textAlign: TextAlign.center),
                centerTitle: true,
              ),
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            AbsensiPage(), // Replace with TahfidzPage()
            CekSantri(), 

            HomeQuran(), // Replace with DashboardGuruQuranPage()
            Kepesantrenan(),
            profilquran(),
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
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Absensi';
      case 1:
        return 'Jadwal';
      case 2:
        return 'Home';
      case 3:
        return 'Kepesantrenan';
      case 4:
        return 'Profil';
      default:
        return '';
    }
  }
}

// Petugas Keamanan dashboard implementation
class PetugasKeamananDashboard extends StatefulWidget {
  @override
  _PetugasKeamananDashboardState createState() =>
      _PetugasKeamananDashboardState();
}

class _PetugasKeamananDashboardState extends State<PetugasKeamananDashboard>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  int _currentIndex = 1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<NavItem> _navItems = [
    NavItem(icon: Icons.login, label: 'Masuk'),
    NavItem(icon: Icons.home, label: 'Home'),
    NavItem(icon: Icons.logout, label: 'Keluar'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
    });
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
        if (_currentIndex != 1) {
          setState(() {
            _currentIndex = 1;
            _pageController.jumpToPage(1);
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            MasukPage(
                izinList: []), // Pass an empty list or the appropriate value for 'izinList'
            HomePetugas(),
            KeluarPage(),
          ],
        ),
        bottomNavigationBar: SlideTransition(
          position: _slideAnimation,
          child: Container(
            height: 65, // Set fixed height
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
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Icon(_navItems[index].icon),
                  ),
                  label: _navItems[index].label,
                );
              }),
              currentIndex: _currentIndex,
              selectedItemColor: const Color(0xFF2E3F7F),
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              onTap: _onBottomNavTapped,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              selectedIconTheme: IconThemeData(size: 24),
              unselectedIconTheme: IconThemeData(size: 24),
              elevation: 0,
            ),
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
