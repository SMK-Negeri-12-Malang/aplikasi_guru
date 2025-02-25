import 'package:flutter/material.dart';
import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Izin/izin_detail.dart';
import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Kesehatan/kesehatan_detail.dart';
import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Laporan/laporan_detail.dart';
import 'package:aplikasi_ortu/utils/widgets/custom_app_bar.dart';

class AbsensiPageKamar extends StatefulWidget {
  const AbsensiPageKamar({super.key});

  @override
  _AbsensiKelasPageState createState() => _AbsensiKelasPageState();
}

class _AbsensiKelasPageState extends State<AbsensiPageKamar> {
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
      backgroundColor: Color.fromARGB(255, 233, 233, 233),
      body: CustomScrollView(
        slivers: [
          CustomGradientAppBar(
            title: 'Laporan Santri',
            icon: Icons.assignment,
            
            textColor: Colors.white,
            child: Container(),
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
                              return _buildRoomCard(index, selectedKamar == kamarList[index]);
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          kamarList.length,
                          (index) => Container(
                            margin: EdgeInsets.symmetric(vertical: 4),
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
      tween: Tween<double>(begin: isSelected ? 0.0 : 0.3, end: isSelected ? 1.0 : 0.8),
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
          LaporanDetail(kamar: kamar)
        ),
        _buildCategoryCard(
          context,
          'Izin',
          Icons.door_front_door_rounded,
          'Lihat perizinan santri',
          Colors.green,
          IzinDetail(kamar: kamar)
        ),
        _buildCategoryCard(
          context,
          'Kesehatan',
          Icons.medical_services_rounded,
          'Lihat kesehatan santri',
          Colors.red,
          DetailKesehatan(kamar: kamar)
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, 
    String title, 
    IconData icon, 
    String subtitle,
    Color iconColor,
    Widget page
  ) {
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
