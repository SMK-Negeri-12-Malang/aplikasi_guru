import 'package:aplikasi_ortu/LOGIN/login.dart';
import 'package:aplikasi_ortu/PAGES/Detail_Kelas/detailkelasA.dart';
import 'package:aplikasi_ortu/PAGES/Detail_Kelas/detailkelasB.dart';
import 'package:aplikasi_ortu/PAGES/Detail_Kelas/detailkelasC.dart';
import 'package:aplikasi_ortu/PAGES/Drawer/Laporan_guru/laporan_guru.dart';
import 'package:aplikasi_ortu/PAGES/Drawer/Profil/profil_page.dart';
import 'package:aplikasi_ortu/PAGES/Drawer/Setting/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_ortu/PAGES/Berita/News_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late PageController _pageController;
  late Future<void> _loadingFuture;
  List<Map<String, dynamic>> _newsList = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Simulate loading delay
    _loadingFuture = Future.delayed(Duration(seconds: 2));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.blue[700],
                          ),
                          SizedBox(height: 10),
                          Text('Memuat berita...',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return _buildCardItem();
              },
            ),
            SizedBox(height: 20),
            Text('Jadwal Mengajar', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildScheduleTable(),
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
                          builder: (context) => DetailKelasA(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  _buildClassButton(
                    'Kelas B',
                    () {
                    
                    },
                  ),
                  SizedBox(height: 10),
                  _buildClassButton(
                    'Kelas C',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailKelasC(),
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

  Widget _buildScheduleTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      children: [
        _buildTableRow('Hari', 'Jam Ke-1', 'Jam Ke-2'),
        _buildTableRow('Senin', '07:00 - 09:00', '11:00 - 13:00'),
        _buildTableRow('Selasa', '08:00 - 10:00', '12:00 - 14:00'),
        _buildTableRow('Rabu', '07:00 - 09:00', '11:00 - 13:00'),
        _buildTableRow('Kamis', '08:00 - 10:00', '12:00 - 14:00'),
        _buildTableRow('Jumat', '07:00 - 09:00', '11:00 - 13:00'),
      ],
    );
  }

  TableRow _buildTableRow(String day, String time1, String time2) {
    return TableRow(
      children: [
        _buildTableCell(day),
        _buildTableCell(time1),
        _buildTableCell(time2),
      ],
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}