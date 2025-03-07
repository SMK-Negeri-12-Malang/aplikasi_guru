import 'package:aplikasi_ortu/MUSYRIF/Tugas/tabel_history.dart';
import 'package:aplikasi_ortu/utils/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'tabel_tugas.dart';

class Tugas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TugasSantriPage(),
    );
  }
}

class TugasSantriPage extends StatefulWidget {
  @override
  _TugasSantriPageState createState() => _TugasSantriPageState();
}

class _TugasSantriPageState extends State<TugasSantriPage> {
  String selectedKamar = "Mutabaah";
  List<String> kamarList = ["Mutabaah", "Tahsin", "Tahfidz"];
  
  PageController _pageController = PageController(
    viewportFraction: 0.75,
    initialPage: 0,
  );
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
            title: 'Tugas Santri',
            icon: Icons.task_sharp,
            textColor: Colors.white,
            child: Container(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pilih Tugas",
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3F7F),
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.history,
                        color: Color.fromARGB(255, 255, 255, 255),
                        ),
                        label: Text('History',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2E3F7F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryPage(
                                kategori: selectedKamar,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    height: screenHeight * 0.15,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: kamarList.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                          selectedKamar = kamarList[index];
                          // Navigate to ActivityTablePage when category is selected
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ActivityTablePage(
                                kategori: selectedKamar, studentName: '', date: '', sesi: '',
                              ),
                            ),
                          );
                        });
                      },
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double value = 1.0;
                            if (_pageController.position.haveDimensions) {
                              value = _pageController.page! - index;
                              value = (1 - (value.abs() * 0.3)).clamp(0.85, 1.0);
                            }
                            return Transform.scale(
                              scale: value,
                              child: _buildRoomCard(
                                index,
                                selectedKamar == kamarList[index],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      kamarList.length,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(int index, bool isSelected) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.02,
      ),
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
    );
  }
}
