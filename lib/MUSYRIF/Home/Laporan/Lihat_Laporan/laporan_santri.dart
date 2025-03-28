import 'package:flutter/material.dart';
import 'package:aplikasi_guru/MUSYRIF/Home/Laporan/Menu/Izin/izin_data.dart';
import 'package:aplikasi_guru/MUSYRIF/Home/Laporan/Menu/Kesehatan/kesehatan_data.dart';
import 'package:aplikasi_guru/MUSYRIF/Home/Laporan/Menu/Pelanggaran/pelanggaran_data.dart';


class LaporanSantri extends StatefulWidget {
  const LaporanSantri({super.key});

  @override
  _AbsensiKelasPageState createState() => _AbsensiKelasPageState();
}

class _AbsensiKelasPageState extends State<LaporanSantri> {
  final List<String> kamarList = ['Kamar A', 'Kamar B', 'Kamar C', 'Kamar D'];
  String selectedKamar = "Kamar A";
  PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.grey[100],
            expandedHeight: screenHeight * 0.10,
            pinned: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: FlexibleSpaceBar(
                centerTitle: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 8),
                    Text(
                      'Laporan Santri',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pilih Kamar",
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3F7F),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: screenHeight * 0.15,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: kamarList.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                                selectedKamar = kamarList[index];
                              });
                            },
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  
                                },
                                child: _buildRoomCard(
                                    index, selectedKamar == kamarList[index]),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_upward),
                            onPressed: () {
                              if (_currentPage > 0) {
                                _pageController.previousPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_downward),
                            onPressed: () {
                              if (_currentPage < kamarList.length - 1) {
                                _pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(width: 8),
                      
                      Container(
                        height: screenHeight * 0.15,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            kamarList.length,
                            (index) => Container(
                              margin: EdgeInsets.symmetric(vertical: 2),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index
                                    ? Color(0xFF2E3F7F)
                                    : Colors.grey[300],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  CategoryList(kamar: selectedKamar),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(int index, bool isSelected) {
    final screenWidth = MediaQuery.of(context).size.width;

    return TweenAnimationBuilder(
      tween: Tween<double>(
          begin: isSelected ? 0.0 : 0.3, end: isSelected ? 1.0 : 0.8),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..translate(0.0, isSelected ? 0.0 : 20.0)
            ..scale(value),
          alignment: Alignment.center,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSelected
                    ? [Color(0xFF2E3F7F), Color(0xFF4557A4)]
                    : [Colors.grey[300]!, Colors.grey[400]!],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? Color(0xFF2E3F7F).withOpacity(0.3)
                      : Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                kamarList[index],
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CategoryList extends StatelessWidget {
  final String kamar;
  const CategoryList({required this.kamar, Key? key}) : super(key: key);

  void _navigateToDetail(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCategoryCard(
            context,
            'Pelanggaran',
            Icons.warning_rounded,
            'Lihat detail pelanggaran santri',
            Colors.orange,
            LaporanDetail(kamar: kamar)),
        _buildCategoryCard(context, 'Izin', Icons.door_front_door_rounded,
            'Lihat perizinan santri', Colors.green, IzinDetail(kamar: kamar)),
        _buildCategoryCard(
            context,
            'Kesehatan',
            Icons.medical_services_rounded,
            'Lihat kesehatan santri',
            Colors.red,
            DetailKesehatan(kamar: kamar)),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon,
      String subtitle, Color iconColor, Widget page) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(context, page),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3F7F),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class RoomDetailPage extends StatelessWidget {
  final String roomName;
  const RoomDetailPage({required this.roomName, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(roomName),
      ),
      body: Center(
        child: Text('Details for $roomName'),
      ),
    );
  }
}
