import 'package:aplikasi_ortu/PAGES/Berita/NewsDetailPage.dart';
import 'package:aplikasi_ortu/PAGES/Detail_Tugas_Kelas/taskpage.dart';
import 'package:aplikasi_ortu/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_ortu/PAGES/Berita/News_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'package:aplikasi_ortu/models/schedule_model.dart';
import 'package:aplikasi_ortu/services/schedule_service.dart';
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

  @override
  void initState() {
    super.initState();
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
          _currentScheduleIndex = (_currentScheduleIndex + 1) % jadwalBesok.length;
        }
      });
    });
    _loadSchedules();
    _loadNews(); // Add this line to load saved news
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

  Future<void> _loadNews() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? newsJsonList = prefs.getStringList('news_list');
      
      if (newsJsonList != null) {
        setState(() {
          _newsList = newsJsonList.map((newsJson) {
            Map<String, dynamic> newsMap = json.decode(newsJson);
            // Convert the stored image path back to File
            newsMap['image'] = File(newsMap['image']);
            return newsMap;
          }).toList();
        });
      }
    } catch (e) {
      print('Error loading news: $e');
    }
  }

  Future<void> _saveNews() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> newsJsonList = _newsList.map((news) {
        // Convert File to path string for storage
        Map<String, dynamic> newsMap = Map.from(news);
        newsMap['image'] = (news['image'] as File).path;
        return json.encode(newsMap);
      }).toList();
      
      await prefs.setStringList('news_list', newsJsonList);
    } catch (e) {
      print('Error saving news: $e');
    }
  }

  @override
  void dispose() {
    _scheduleTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _addNews(Map<String, dynamic> news) {
    setState(() {
      _newsList.add(news);
      _saveNews(); // Save news whenever a new item is added
    });
  }

  void _showJadwalMengajar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            if (_isLoadingSchedules) {
              return Center(child: CircularProgressIndicator());
            }
            
            // Group schedules by day
            Map<String, List<Schedule>> schedulesByDay = {};
            for (var schedule in _schedules) {
              if (!schedulesByDay.containsKey(schedule.hari)) {
                schedulesByDay[schedule.hari] = [];
              }
              schedulesByDay[schedule.hari]!.add(schedule);
            }

            return Container(
              padding: EdgeInsets.all(16),
              child: ListView(
                controller: scrollController,
                children: schedulesByDay.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),
                      ),
                      ...entry.value.map((schedule) {
                        return ListTile(
                          title: Text(schedule.nama_jadwal),
                          subtitle: Text(schedule.jam),
                        );
                      }).toList(),
                      Divider(),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
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
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.notifications, color: Colors.blue, size: 24),
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
                          final notification = _deadlineNotifications[index];
                          return Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Icon(
                                  Icons.assignment,
                                  color: Colors.white,
                                ),
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
                                icon: Icon(Icons.close),
                                onPressed: () async {
                                  await _notificationService.removeNotification(index);
                                  await _loadNotifications();
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void updateDeadlineNotifications(Map<String, dynamic> task, String className) async {
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
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _showingDeadlines ? 'Deadline Tugas' : 'Jadwal Hari $hariIni',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (_deadlineNotifications.isNotEmpty)
                    TextButton.icon(
                      icon: Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 20),
                      label: Text(
                        _showingDeadlines ? 'Lihat Jadwal' : 'Lihat Deadline',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                      onPressed: () {
                        setState(() {
                          _showingDeadlines = !_showingDeadlines;
                        });
                      },
                    ),
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: _showingDeadlines 
                    ? _buildDeadlineList()
                    : _buildScheduleList(jadwalHariIni),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleList(List<Schedule> jadwalHariIni) {
    if (_isLoadingSchedules) {
      return Center(child: CircularProgressIndicator());
    }

    return jadwalHariIni.isEmpty
        ? Center(
            child: Text('Tidak ada jadwal untuk hari ini'),
          )
        : AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Container(
              key: ValueKey<int>(_currentScheduleIndex),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.book, color: Colors.blue, size: 40),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          jadwalHariIni[_currentScheduleIndex].nama_jadwal,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          jadwalHariIni[_currentScheduleIndex].jam,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_currentScheduleIndex + 1}/${jadwalHariIni.length}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
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
                  color: daysLeft == 0 ? Colors.red[200] : Colors.red[100],
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
                        color: Colors.red[700],
                        fontWeight: daysLeft == 0 ? FontWeight.bold : FontWeight.normal,
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: RefreshIndicator(
        onRefresh: _reloadProfileData,
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: AppBarClipper(),
                  child: Container(
                    color: Colors.blue,
                    height: 230,
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 50, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.white,
                                    backgroundImage: _profileImagePath != null
                                        ? FileImage(File(_profileImagePath!))
                                        : AssetImage('assets/profile_picture.png') as ImageProvider,
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _name,
                                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        _email,
                                        style: TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.notifications, color: const Color.fromARGB(255, 255, 255, 255)),
                                onPressed: _showNotification,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildScheduleCard(),
                  ],
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Berita',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewsPage(onNewsAdded: _addNews),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    FutureBuilder(
                      future: _loadingFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
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
                        return _buildCardItem();
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _showJadwalMengajar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Lihat Jadwal Mengajar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Kelas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          _buildClassButton(
                            'Kelas A',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => tugaskelas(
                                    onTaskAdded: (task, className) {
                                      updateDeadlineNotifications(task, className);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 10),
                          _buildClassButton(
                            'Kelas B',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => tugaskelas(
                                    onTaskAdded: (task, className) {
                                      updateDeadlineNotifications(task, className);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 10),
                          _buildClassButton(
                            'Kelas C',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => tugaskelas(
                                    onTaskAdded: (task, className) {
                                      updateDeadlineNotifications(task, className);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassButton(String title, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold
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

    return SizedBox(
      height: 155,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _newsList.length,
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
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2)
                  ),
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        news['image'],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          news['judul'],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5),
                        Text(
                          news['tanggal'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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