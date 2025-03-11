import 'package:aplikasi_ortu/GURU/Detail_Tugas_Kelas/taskpage.dart';
import 'package:aplikasi_ortu/SERVICE/notification_service.dart';
import 'package:aplikasi_ortu/models/class_model.dart';
import 'package:aplikasi_ortu/models/jadwal_home.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_ortu/GURU/Berita/News_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'package:aplikasi_ortu/SERVICE/jadwal_dihome.dart';
import '../../SERVICE/class_service.dart';
import '../Berita/NewsDetailPage.dart';
import 'dart:ui';
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late PageController _pageController;
  late Future<void> _loadingFuture;
  List<Map<String, dynamic>> _newsList = [];
  String _name = '';
  String _email = '';
  String? _profileImagePath;
  List<Map<String, dynamic>> _deadlineNotifications = [];
  Map<String, List<Map<String, String>>> _jadwalMengajar = {};
  late Timer _scheduleTimer;
  int _currentScheduleIndex = 0;
  final NotificationService _notificationService = NotificationService();
  bool _showingDeadlines = false;
  final ScheduleService _scheduleService = ScheduleService();
  List<Schedule> _schedules = [];
  bool _isLoadingSchedules = true;
  final ClassService _classService = ClassService();
  List<ClassModel> _classList = [];
  bool _isLoadingClasses = true;
  late Timer _newsTimer;
  int _currentNewsIndex = 0;

  get news => null;

  @override
  void initState() {
    super.initState();
    _loadSavedNews();
    initializeDateFormatting('id_ID', null).then((_) {
      _loadProfileData();
    });
    _loadNotifications();
    _pageController = PageController();
    // Simulate loading delay
    _loadingFuture = Future.delayed(Duration(seconds: 3));

    // Initialize timer for schedule sliding
    _scheduleTimer = Timer.periodic(Duration(seconds: 8), (timer) {
      setState(() {
        List<Map<String, String>> jadwalBesok = _getJadwalMengajarBesok();
        if (jadwalBesok.isNotEmpty) {
          _currentScheduleIndex =
              (_currentScheduleIndex + 1) % jadwalBesok.length;
        }
      });
    });
    _loadSchedules();
    _fetchClasses();

    // Update timer to use actual schedules
    _scheduleTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          List<Schedule> jadwalHariIni = _getJadwalMengajarHariIni();
          if (jadwalHariIni.isNotEmpty) {
            _currentScheduleIndex =
                (_currentScheduleIndex + 1) % jadwalHariIni.length;
          }
        });
      }
    });

    // Initialize timer for news sliding
    _newsTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted && _newsList.isNotEmpty) {
        setState(() {
          _currentNewsIndex = (_currentNewsIndex + 1) % _newsList.length;
          _pageController.animateToPage(
            _currentNewsIndex,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  Future<void> _loadProfileData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Get login data from SharedPreferences that was stored during API login
      String? userName = prefs.getString('user_name');
      String? userEmail = prefs.getString('user_email');
      String? profileImagePath = prefs.getString('profile_image_path');

      setState(() {
        _name = userName ?? 'Loading...'; // Show loading if null
        _email = userEmail ?? 'Loading...'; // Show loading if null
        _profileImagePath = profileImagePath;
      });
    } catch (e) {
      print('Error loading profile data: $e');
      setState(() {
        _name = 'Error loading data';
        _email = 'Please try again';
      });
    }
  }

  Future<void> _reloadProfileData() async {
    await _loadProfileData();
  }

  Future<void> _loadNotifications() async {
    final notifications = await _notificationService.getNotifications();
    setState(() {
      _deadlineNotifications = notifications;
    });
  }

  Future<void> _loadSchedules() async {
    try {
      setState(() {
        _isLoadingSchedules = true;
      });
      final schedules = await _scheduleService.getSchedules();
      setState(() {
        _schedules = schedules;
        _isLoadingSchedules = false;
      });
    } catch (e) {
      print('Error loading schedules: $e');
      setState(() {
        _isLoadingSchedules = false;
      });
    }
  }

//tes push
  Future<void> _fetchClasses() async {
    try {
      final classes = await _classService.getClasses();
      setState(() {
        _classList = classes;
        _isLoadingClasses = false;
      });
    } catch (e) {
      print('Error fetching classes: $e');
      setState(() {
        _isLoadingClasses = false;
      });
    }
  }

  @override
  void dispose() {
    _scheduleTimer.cancel();
    _newsTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedNews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedNewsString = prefs.getString('saved_news');
      
      if (savedNewsString != null) {
        final List<dynamic> savedNews = json.decode(savedNewsString);
        setState(() {
          _newsList = savedNews.map((news) {
            try {
              final imagePath = news['imagePath'];
              final imageFile = File(imagePath);
              if (imageFile.existsSync()) {
                return {
                  'judul': news['judul'],
                  'deskripsi': news['deskripsi'],
                  'tempat': news['tempat'],
                  'tanggal': news['tanggal'],
                  'waktu': news['waktu'],
                  'image': imageFile,
                  'imagePath': imagePath,
                };
              }
            } catch (e) {
              print('Error loading image: $e');
            }
            return null;
          }).whereType<Map<String, dynamic>>().toList();
        });
      }
    } catch (e) {
      print('Error loading saved news: $e');
    }
  }

  Future<void> _saveNewsToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> storableNews = _newsList.map((news) {
        return {
          'judul': news['judul'],
          'deskripsi': news['deskripsi'],
          'tempat': news['tempat'],
          'tanggal': news['tanggal'],
          'waktu': news['waktu'],
          'imagePath': news['image'].path,
        };
      }).toList();
      
      await prefs.setString('saved_news', json.encode(storableNews));
    } catch (e) {
      print('Error saving news: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan berita: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addNews(Map<String, dynamic> news) {
    setState(() {
      _newsList.add(news);
    });
    _saveNewsToLocal(); // Save after adding new news
  }

  String _getHariBesok() {
    DateTime now = DateTime.now();
    DateTime tomorrow = now.add(Duration(days: 1));
    return DateFormat('EEEE', 'id_ID').format(tomorrow);
  }

  List<Map<String, String>> _getJadwalMengajarBesok() {
    String day = _getHariBesok();

    if (_jadwalMengajar.containsKey(day)) {
      return _jadwalMengajar[day]!;
    } else {
      return [];
    }
  }

  String _getHariIni() {
    return DateFormat('EEEE', 'id_ID').format(DateTime.now());
  }

  List<Schedule> _getJadwalMengajarHariIni() {
    String today = _getHariIni();
    return _schedules.where((schedule) => schedule.hari == today).toList();
  }

  Future<bool> _confirmDelete() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text('Hapus Notifikasi'),
              content:
                  Text('Apakah Anda yakin ingin menghapus notifikasi ini?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Hapus', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showDeleteSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Notifikasi berhasil dihapus'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications,
              color: const Color.fromARGB(255, 255, 255, 255)),
          onPressed: _showNotification,
        ),
        if (_deadlineNotifications.isNotEmpty)
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 0.5,
                ),
              ),
              constraints: BoxConstraints(
                minWidth: 10,
                minHeight: 10,
              ),
              child: _deadlineNotifications.length < 10
                  ? Container(
                      width: 4,
                      height: 4,
                    )
                  : Text(
                      '${_deadlineNotifications.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    return Dismissible(
      key: UniqueKey(), // Use UniqueKey for stable deletion
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _confirmDelete(),
      onDismissed: (direction) async {
        try {
          // Remove from service first
          await _notificationService.removeNotification(index);
          // Then update UI
          setState(() {
            _deadlineNotifications.removeAt(index);
            // Update parent state if bottom sheet is open
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(); // Close bottom sheet
              _showNotification(); // Reopen with updated data
            }
          });
          _showDeleteSuccessSnackbar();
        } catch (e) {
          print('Error deleting notification: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus notifikasi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 15, 74, 122),
            child: Icon(Icons.assignment, color: Colors.white),
          ),
          title: Text(
            notification['taskName'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kelas: ${notification['className']}'),
              Text(
                'Deadline: ${notification['deadline']}',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red[300]),
            onPressed: () async {
              if (await _confirmDelete()) {
                try {
                  // Remove from service first
                  await _notificationService.removeNotification(index);
                  // Then update UI
                  setState(() {
                    _deadlineNotifications.removeAt(index);
                    // Update parent state if bottom sheet is open
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop(); // Close bottom sheet
                      _showNotification(); // Reopen with updated data
                    }
                  });
                  _showDeleteSuccessSnackbar();
                } catch (e) {
                  print('Error deleting notification: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus notifikasi'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }

  void _showNotification() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.notifications,
                        color: const Color.fromARGB(255, 19, 82, 134),
                        size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Notifikasi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _deadlineNotifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Tidak ada notifikasi',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _deadlineNotifications.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationItem(
                              _deadlineNotifications[index], index);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void updateDeadlineNotifications(
      Map<String, dynamic> task, String className) async {
    final notification = {
      'taskName': task['name'],
      'className': className,
      'deadline': task['deadline'],
    };

    await _notificationService.addNotification(notification);
    await _loadNotifications();
  }

  Widget _buildScheduleCard() {
    List<Schedule> jadwalHariIni = _getJadwalMengajarHariIni();
    String hariIni = _getHariIni();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(5, 5), // Right and bottom shadow
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color:
                      const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
                  blurRadius: 15,
                  offset: Offset(-5, -5), // Left and top highlight
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12), // Increased padding
              child: Container(
                height: 200, // Increased height from 180 to 200
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  size: 20),
                              SizedBox(width: 8),
                              Text(
                                _showingDeadlines
                                    ? 'Deadline Tugas'
                                    : 'Jadwal Hari ${_getHariIni()}',
                                style: TextStyle(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        if (_deadlineNotifications.isNotEmpty)
                          TextButton.icon(
                            icon: Icon(Icons.warning_amber_rounded,
                                color: const Color.fromARGB(255, 41, 230, 88),
                                size: 15),
                            label: Text(
                              _showingDeadlines
                                  ? 'Lihat Jadwal'
                                  : 'Lihat Deadline',
                              style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      const Color.fromARGB(255, 41, 230, 88)),
                            ),
                            onPressed: () {
                              setState(() {
                                _showingDeadlines = !_showingDeadlines;
                              });
                            },
                          ),
                        if (!_showingDeadlines && jadwalHariIni.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '${_currentScheduleIndex + 1}/${jadwalHariIni.length}',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 241, 240, 240),
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 20), // Increased spacing
                    Expanded(
                      child: _showingDeadlines
                          ? _buildDeadlineList()
                          : _buildScheduleList(jadwalHariIni),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleList(List<Schedule> jadwalHariIni) {
    if (_isLoadingSchedules) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
        ),
      );
    }

    return jadwalHariIni.isEmpty
        ? Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(3, 3),
                  spreadRadius: 1,
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  color: const Color.fromARGB(255, 15, 66, 107),
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Tidak ada jadwal untuk hari ini',
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : PageView.builder(
            itemCount: jadwalHariIni.length,
            onPageChanged: (index) {
              setState(() {
                _currentScheduleIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(3, 3),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jadwalHariIni[index].namaPelajaran,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 11, 49, 105),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            jadwalHariIni[index].kelas,
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color.fromARGB(255, 13, 66, 126),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 19, 83, 146)!
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              jadwalHariIni[index].jam,
                              style: TextStyle(
                                fontSize: 13,
                                color: const Color.fromARGB(255, 24, 103, 182),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  List<Map<String, dynamic>> _getUpcomingDeadlines() {
    final now = DateTime.now();
    return _deadlineNotifications.where((notification) {
      try {
        final deadline = DateTime.parse(notification['deadline']);
        final difference = deadline.difference(now);
        return difference.inDays >= 0 && difference.inDays <= 3;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  Widget _buildDeadlineList() {
    final upcomingDeadlines = _getUpcomingDeadlines();

    return upcomingDeadlines.isEmpty
        ? Center(
            child: Text('Tidak ada deadline dalam 3 hari ke depan'),
          )
        : ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: upcomingDeadlines.length,
            itemBuilder: (context, index) {
              final notification = upcomingDeadlines[index];
              final deadline = DateTime.parse(notification['deadline']);
              final daysLeft = deadline.difference(DateTime.now()).inDays;

              return Container(
                width: 200,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: daysLeft == 0
                      ? const Color.fromARGB(255, 253, 253, 253)
                      : const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      notification['taskName'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Kelas: ${notification['className']}',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      daysLeft == 0
                          ? 'Deadline: Hari ini'
                          : 'Deadline: ${daysLeft} hari lagi',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color.fromARGB(255, 77, 185, 34),
                        fontWeight:
                            daysLeft == 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    _getJadwalMengajarBesok();
    return Scaffold(
      backgroundColor: Colors.transparent, // Changed to transparent
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
            onRefresh: _reloadProfileData,
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
                                        : AssetImage(
                                                'assets/profile_picture.png')
                                            as ImageProvider,
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                              _buildNotificationIcon(),
                            ],
                          ),
                        ),
                        _buildScheduleCard(),
                        // Remove the Stack and ClipPath here since we're using gradient background

                        // Rest of the content
                        Padding(
                          padding: EdgeInsets.only(
                            left: 15, // Padding kiri
                            right: 11,
                            top: 0, 
                            bottom: 5,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20),
                              // News section
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Berita',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              NewsPage(onNewsAdded: _addNews),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              // News card
                              FutureBuilder(
                                future: _loadingFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return _buildLoadingShimmer();
                                  }
                                  return _buildCardItem();
                                },
                              ),
                              SizedBox(height: 20),
                              // Class assignments section
                              Text('Penugasan Kelas',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              _isLoadingClasses
                                  ? Center(child: CircularProgressIndicator())
                                  : ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: _classList.length,
                                      itemBuilder: (context, index) {
                                        final classData = _classList[index];
                                        return Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: _buildClassButton(
                                            classData.kelas,
                                            () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      tugaskelas(
                                                    className: classData.kelas,
                                                    onTaskAdded:
                                                        (task, className) {
                                                      updateDeadlineNotifications(
                                                          task,
                                                          classData.kelas);
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                              SizedBox(height: 20), // Add bottom padding
                            ],
                          ),
                        ),
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

  Widget _buildLoadingShimmer() {
    return Container(
      height: 155,
      child: Center(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                color: Colors.white,
              ),
              SizedBox(height: 10),
              Container(
                width: 100,
                height: 20,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassButton(String title, VoidCallback onPressed) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => tugaskelas(
              className: title, // Pass class name here
              onTaskAdded: (task, className) {
                updateDeadlineNotifications(task, title);
              },
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6), // Reduced from 8
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16), // Reduced padding
              height: 85, // Reduced from 100
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10), // Reduced from 12
                    decoration: BoxDecoration(
                      color: Color(0xFF2E3F7F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.class_,
                      color: Color(0xFF2E3F7F),
                      size: 26, // Reduced from 30
                    ),
                  ),
                  SizedBox(width: 16), // Reduced from 20
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Color(0xFF2E3F7F),
                            fontSize: 16, // Reduced from 18
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4), // Reduced from 6
                        Text(
                          'Lihat detail tugas kelas',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13, // Reduced from 14
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF2E3F7F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF2E3F7F),
                      size: 18, // Reduced from 20
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardItem() {
    if (_newsList.isEmpty) {
      return Container(
        height: 155,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 50, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                'Tidak ada berita',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(  // Changed from SizedBox to Column
      children: [
        SizedBox(
          height: 155,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _newsList.length,
            onPageChanged: (index) {
              setState(() {
                _currentNewsIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final news = _newsList[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailPage(news: news),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2E3F7F),
                        Color.fromARGB(255, 117, 127, 170)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: Offset(0, 10),
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Row(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            margin: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                news['image'],
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    news['judul'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Expanded(
                                    child: Text(
                                      news['deskripsi'],
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    news['tanggal'],
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8), // Add spacing between card and dots
        Row(  // Moved dots outside the Stack
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _newsList.length,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == _currentNewsIndex
                    ? const Color(0xFF2E3F7F)  // Changed to match theme color
                    : const Color(0xFF2E3F7F).withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
