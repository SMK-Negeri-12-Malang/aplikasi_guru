import 'package:aplikasi_ortu/MUSYRIF/Detail_Kamar/taskpage.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_ortu/PAGES/Berita/News_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DashboardMusyrifPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardMusyrifPage> {
  late PageController _pageController;
  late Future<void> _loadingFuture;
  List<Map<String, dynamic>> _newsList = [];
  String _name = 'User';
  String _email = 'Teknologi Informasi';
  String? _profileImagePath;
  bool _isFirstLoad = true; // Add this line

  final Map<String, List<Map<String, String>>> _jadwalMengajar = {
    'Senin': [
      {'jam': '07:00 - 09:00', 'mataPelajaran': 'Matematika'},
      {'jam': '09:00 - 11:00', 'mataPelajaran': 'Fisika'},
      {'jam': '11:00 - 13:00', 'mataPelajaran': 'Bahasa Indonesia'},
    ],
    'Selasa': [
      {'jam': '08:00 - 10:00', 'mataPelajaran': 'IPA'},
      {'jam': '10:00 - 12:00', 'mataPelajaran': 'Kimia'},
      {'jam': '12:00 - 14:00', 'mataPelajaran': 'IPS'},
    ],
    'Rabu': [
      {'jam': '07:00 - 09:00', 'mataPelajaran': 'Bahasa Inggris'},
      {'jam': '09:00 - 11:00', 'mataPelajaran': 'Biologi'},
      {'jam': '11:00 - 13:00', 'mataPelajaran': 'Seni Budaya'},
    ],
    'Kamis': [
      {'jam': '08:00 - 10:00', 'mataPelajaran': 'Pendidikan Jasmani'},
      {'jam': '10:00 - 12:00', 'mataPelajaran': 'Matematika'},
      {'jam': '12:00 - 14:00', 'mataPelajaran': 'Prakarya'},
    ],
    'Jumat': [
      {'jam': '07:00 - 09:00', 'mataPelajaran': 'Agama'},
      {'jam': '09:00 - 11:00', 'mataPelajaran': 'Sejarah'},
      {'jam': '11:00 - 13:00', 'mataPelajaran': 'Pendidikan Kewarganegaraan'},
    ],
  };

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      _loadProfileData();
    });
    _loadUserRole(); // Add this line
    _pageController = PageController();
    // Simulate loading delay only on first load
    if (_isFirstLoad) {
      _loadingFuture = Future.delayed(Duration(seconds: 5));
    } else {
      _loadingFuture = Future.value();
    }
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('profile_name') ?? _name;
      _email = prefs.getString('profile_email') ?? _email;
      _profileImagePath = prefs.getString('profile_image_path');
    });
  }

  Future<void> _loadUserRole() async {
    setState(() {
    });
  }

  Future<void> _reloadProfileData() async {
    await _loadProfileData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _addNews(Map<String, dynamic> news) {
    setState(() {
      _newsList.add(news);
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
            return Container(
              padding: EdgeInsets.all(16),
              child: ListView(
                controller: scrollController,
                children: _jadwalMengajar.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ...entry.value.map((jadwal) {
                        return ListTile(
                          title: Text(jadwal['mataPelajaran']!),
                          subtitle: Text(jadwal['jam']!),
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

  void _showNotification() {
    List<Map<String, String>> jadwalBesok = _getJadwalMengajarBesok();
    String jadwalText = jadwalBesok.isNotEmpty
        ? jadwalBesok.map((item) => '${item['jam']} - ${item['mataPelajaran']}').join('\n')
        : 'Tidak ada jadwal mengajar besok';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(jadwalText)),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> jadwalBesok = _getJadwalMengajarBesok();
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
                                icon: Icon(Icons.notifications, color: Colors.white),
                                onPressed: _showNotification,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          height: 150, // Perbesar tinggi container
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jadwal Hari ${_getHariBesok()}',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Expanded(
                                child: _isFirstLoad // Add this condition
                                    ? FutureBuilder(
                                        future: _loadingFuture,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return Center(
                                              child: CircularProgressIndicator(), // Add loading animation
                                            );
                                          }
                                          _isFirstLoad = false; // Set to false after first load
                                          return _buildJadwalList(jadwalBesok);
                                        },
                                      )
                                    : _buildJadwalList(jadwalBesok),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
                    Text('Kamar', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          _buildClassButton(
                            'Kamar A',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TaskPage(
                                    roomName: 'Kamar A',
                                    students: [], // Add appropriate list of students
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 10),
                          _buildClassButton(
                            'Kamar B',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TaskPage(
                                    roomName: 'Kamar B',
                                    students: [], // Add appropriate list of students
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 10),
                          _buildClassButton(
                            'Kamar C',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TaskPage(
                                    roomName: 'Kamar C',
                                    students: [], // Add appropriate list of students
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 10),
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

  Widget _buildJadwalList(List<Map<String, String>> jadwalBesok) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: jadwalBesok.length,
      itemBuilder: (context, index) {
        final jadwal = jadwalBesok[index];
        return Container(
          width: 120,
          margin: EdgeInsets.only(right: 10),
          padding: EdgeInsets.all(8),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.book, color: Colors.blue, size: 30),
              SizedBox(height: 5),
              Text(
                jadwal['mataPelajaran']!,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Text(
                jadwal['jam']!,
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news['judul'],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        )
                      ),
                      SizedBox(height: 5),
                      Text(
                        news['tanggal'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12
                        )
                      ),
                    ],
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