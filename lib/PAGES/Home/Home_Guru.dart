import 'package:aplikasi_ortu/PAGES/Detail_Tugas_Kelas/taskpage.dart';
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

  void _showJadwalMengajar(String hari) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Jadwal Mengajar - $hari'),
          content: SingleChildScrollView(
            child: Table(
              border: TableBorder.all(color: Colors.grey),
              children: [
                TableRow(
                  children: [
                    _buildTableCell('Jam'),
                    _buildTableCell('Mata Pelajaran'),
                  ],
                ),
                ..._jadwalMengajar[hari]!.map((jadwal) {
                  return TableRow(
                    children: [
                      _buildTableCell(jadwal['jam']!),
                      _buildTableCell(jadwal['mataPelajaran']!),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
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
            _buildJadwalMengajarButtons(),
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

  Widget _buildJadwalMengajarButtons() {
    return Column(
      children: _jadwalMengajar.keys.map((hari) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ElevatedButton(
            onPressed: () => _showJadwalMengajar(hari),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              hari,
              style: TextStyle(
                color: Colors.white, 
                fontSize: 16, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        );
      }).toList(),
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