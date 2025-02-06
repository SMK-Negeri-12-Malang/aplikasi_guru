import 'package:aplikasi_ortu/PAGES/Detail_Kelas/detailkelasA.dart';
import 'package:aplikasi_ortu/PAGES/Detail_Kelas/detailkelasB.dart';
import 'package:aplikasi_ortu/PAGES/Detail_Kelas/detailkelasC.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late PageController _pageController;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Berita', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            _buildCardItem(),
            SizedBox(height: 20),
            Text('Presentase Mengajar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildProgressSection(),
            SizedBox(height: 20),
            Text('Jadwal Mengajar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            //container button
            Container(
              //color: Colors.blueAccent,
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>DetailKelasA(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  Colors.blue[700],
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Kelas A',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailKelasB(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  Colors.blue[700],
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Kelas B',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailKelasC(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  Colors.blue[700],
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Kelas C',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                //
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem() {
    return SizedBox(
      height: 155,
      child: PageView.builder(
        controller: _pageController,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
              ],
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/image.png',
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
                    Text('Yoga',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 5),
                    Text('Ah mantap', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPercentageProgress('Kelas A', 70),
          _buildPercentageProgress('Kelas B', 85),
          _buildPercentageProgress('Kelas C', 90),
        ],
      ),
    );
  }

  Widget _buildPercentageProgress(String title, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text('${percentage.toStringAsFixed(0)}%',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 10,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(const Color.fromARGB(255, 255, 255, 255)),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
