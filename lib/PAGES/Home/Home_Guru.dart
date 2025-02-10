import 'package:aplikasi_ortu/PAGES/Detail_Tugas_Kelas/taskpage.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_ortu/PAGES/Berita/News_page.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late PageController _pageController;
  late Future<void> _loadingFuture;
  List<Map<String, dynamic>> _newsList = [];
  String _name = 'User';
  String _email = 'Teknologi Informasi';
  String? _profileImagePath;

  final Map<String, List<Map<String, String>>> _jadwalMengajar = {
    'Senin': [
      {'jam': '07:00 - 09:00', 'mataPelajaran': 'Matematika'},
      {'jam': '11:00 - 13:00', 'mataPelajaran': 'Bahasa Indonesia'},
    ],
    'Selasa': [
      {'jam': '08:00 - 10:00', 'mataPelajaran': 'IPA'},
      {'jam': '12:00 - 14:00', 'mataPelajaran': 'IPS'},
    ],
    'Rabu': [
      {'jam': '07:00 - 09:00', 'mataPelajaran': 'Bahasa Inggris'},
      {'jam': '11:00 - 13:00', 'mataPelajaran': 'Seni Budaya'},
    ],
    'Kamis': [
      {'jam': '08:00 - 10:00', 'mataPelajaran': 'Pendidikan Jasmani'},
      {'jam': '12:00 - 14:00', 'mataPelajaran': 'Prakarya'},
    ],
    'Jumat': [
      {'jam': '07:00 - 09:00', 'mataPelajaran': 'Agama'},
      {'jam': '11:00 - 13:00', 'mataPelajaran': 'Pendidikan Kewarganegaraan'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _pageController = PageController();
    // Simulate loading delay
    _loadingFuture = Future.delayed(Duration(seconds: 5));
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('profile_name') ?? _name;
      _email = prefs.getString('profile_email') ?? _email;
      _profileImagePath = prefs.getString('profile_image_path');
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

  void _showNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tidak ada notifikasi baru')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildCircularIndicator('Matematika', 0.75),
                            _buildCircularIndicator('Bahasa Indonesia', 0.50),
                            _buildCircularIndicator('IPA', 0.30),
                          ],
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
                                    roomName: 'Kelas A',
                                    students: [], // Add appropriate list of students
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
                                    roomName: 'Kelas B',
                                    students: [], // Add appropriate list of students
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
                                    roomName: 'Kelas C',
                                    students: [], // Add appropriate list of students
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

  Widget _buildCircularIndicator(String label, double percentage) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 50.0,
          lineWidth: 10.0,
          percent: percentage,
          center: new Text("${(percentage * 100).toInt()}%"),
          progressColor: Colors.blue,
          backgroundColor: Colors.grey[200]!,
          animation: true,
          animationDuration: 1200,
        ),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 16)),
      ],
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
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}