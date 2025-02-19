import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Gallery/gallery_list.dart';
import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Kesehatan/kesehatan.dart';
import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Laporan/laporan.dart';
import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Perijinan/perijinan.dart';
import 'package:aplikasi_ortu/MUSYRIF/Home/Models/gallery_item.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Menu/pengaturan.dart';
import 'package:aplikasi_ortu/MUSYRIF/Home/Models/news_item.dart';
import 'Models/activity_item.dart';

class DashboardMusyrifPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardMusyrifPage> {
  String _name = 'User';
  String _email = 'Teknologi Informasi';
  String? _profileImagePath;

  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<NewsItem> _newsItems = [
    NewsItem(
      title: "Berita 1",
      imageUrl: "https://picsum.photos/800/400",
      description: "Deskripsi berita 1",
    ),
    NewsItem(
      title: "Berita 2",
      imageUrl: "https://picsum.photos/800/401",
      description: "Deskripsi berita 2",
    ),
    NewsItem(
      title: "Berita 3",
      imageUrl: "https://picsum.photos/800/402",
      description: "Deskripsi berita 3",
    ),
  ];

  final List<GalleryItem> _galleryItems = [
    GalleryItem(
      imageUrl: "https://picsum.photos/800/400",
      title: "Kegiatan Santri",
      description: "Dokumentasi kegiatan santri di pondok",
      date: "2024-01-20",
    ),
    GalleryItem(
      imageUrl: "https://picsum.photos/800/401",
      title: "Acara Pondok",
      description: "Dokumentasi acara pondok pesantren",
      date: "2024-01-19",
    ),
    GalleryItem(
      imageUrl: "https://picsum.photos/800/402",
      title: "Pembelajaran",
      description: "Aktivitas pembelajaran santri",
      date: "2024-01-18",
    ),
  ];

  final List<ActivityItem> _activityItems = [
    ActivityItem(
      title: "Kegiatan Pagi",
      description: "Membaca Al-Quran bersama",
      date: "2024-01-20",
      status: "Selesai",
      imageUrl: "https://picsum.photos/800/400",
    ),
    ActivityItem(
      title: "Kegiatan Siang",
      description: "Pembelajaran Kitab Kuning",
      date: "2024-01-20",
      status: "Berlangsung",
      imageUrl: "https://picsum.photos/800/401",
    ),
    ActivityItem(
      title: "Kegiatan Malam",
      description: "Belajar bersama",
      date: "2024-01-20",
      status: "Mendatang",
      imageUrl: "https://picsum.photos/800/402",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _startAutoScroll();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? 'User';  // changed key to user_name
      _email = prefs.getString('user_email') ?? 'Teknologi Informasi';  // changed key to user_email
      _profileImagePath = prefs.getString('profile_image_path');
    });
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _newsItems.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
      _startAutoScroll();
    });
  }

  // Fungsi untuk pindah halaman berdasarkan nama button
  void _onButtonPressed(String buttonType) {
    print("Button pressed: $buttonType");
    switch (buttonType) {
      case 'Laporan':
        Navigator.push(context, MaterialPageRoute(builder: (context) => Laporan(onNewsAdded: (news) {
          // Handle the news added
        })));
        break;
      case 'Perizinan':
        Navigator.push(context, MaterialPageRoute(builder: (context) => AttendancePage()));
        break;
      case 'Kesehatan':
        Navigator.push(context, MaterialPageRoute(builder: (context) => Kesehatan()));
        break;
      case 'Pengaturan':
        Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanPage()));
        break;
      default:
        print('Unknown button type');
    }
  }

  Widget _buildNewsCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _newsItems.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      Image.network(
                        _newsItems[index].imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Text(
                            _newsItems[index].title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _newsItems.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? Colors.blue.shade700
                    : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGallerySection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255), // Add grey background
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Galeri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GalleryListPage(
                          galleryItems: _galleryItems,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _galleryItems.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      _galleryItems[index].imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aktivitas Terkini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to activity list page
                  },
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _activityItems.length > 3 ? 3 : _activityItems.length,
            itemBuilder: (context, index) {
              final activity = _activityItems[index];
              return Container(
                height: 120,
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Row(
                    children: [
                      // Image section
                      SizedBox(
                        width: 120,
                        child: Image.network(
                          activity.imageUrl,
                          fit: BoxFit.cover,
                          height: double.infinity,
                        ),
                      ),
                      // Content section
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    activity.description,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    activity.date,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(activity.status),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      activity.status,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green;
      case 'berlangsung':
        return Colors.blue;
      case 'mendatang':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 233, 233),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: _profileImagePath != null
                              ? NetworkImage(_profileImagePath!)
                              : AssetImage('assets/default_profile.png') as ImageProvider,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _email,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          centerTitle: true,
          elevation: 10.0,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNewsCarousel(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildMenuCard(Icons.report, 'Laporan'),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildMenuCard(Icons.card_travel, 'Perizinan'),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildMenuCard(Icons.healing, 'Kesehatan'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildGallerySection(), // Add this line
                  _buildActivitySection(), // Add this line
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(IconData icon, String label) {
    return GestureDetector(
      onTap: () => _onButtonPressed(label),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade100,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.blue.shade50,
              child: Icon(icon, size: 25, color: Colors.blue.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
