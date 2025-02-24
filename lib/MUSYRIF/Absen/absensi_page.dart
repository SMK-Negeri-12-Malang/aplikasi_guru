import 'package:flutter/material.dart';
import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Izin/izin_detail.dart';
import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Kesehatan/kesehatan_detail.dart';
import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Laporan/laporan_detail.dart';

class AbsensiPageKamar extends StatefulWidget {
  const AbsensiPageKamar({super.key});

  @override
  _AbsensiKelasPageState createState() => _AbsensiKelasPageState();
}

class _AbsensiKelasPageState extends State<AbsensiPageKamar> {
  final List<String> kamarList = ['Kamar A', 'Kamar B', 'Kamar C', 'Kamar D'];
  String? selectedKamar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Absensi Kamar"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 4,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 140,
            child: PageView.builder(
              itemCount: kamarList.length,
              onPageChanged: (index) {
                setState(() {
                  selectedKamar = kamarList[index];
                });
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedKamar = kamarList[index];
                    });
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    color: Colors.blue.shade100,
                    child: Center(
                      child: Text(
                        kamarList[index],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (selectedKamar != null)
            Expanded(
              child: CategoryList(kamar: selectedKamar!),
            ),
        ],
      ),
    );
  }
}

class CategoryList extends StatelessWidget {
  final String kamar;
  const CategoryList({required this.kamar, Key? key}) : super(key: key);

  void _navigateToDetail(BuildContext context, String category) {
    Widget page;
    switch (category) {
      case 'Laporan':
        page = LaporanDetail(kamar: kamar);
        break;
      case 'Izin':
        page = IzinDetail(kamar: kamar);
        break;
      case 'Kesehatan':
        page = DetailKesehatan(kamar: kamar);
        break;
      default:
        return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildCategoryTile(context, 'Laporan', Icons.card_travel, Colors.blue),
        _buildCategoryTile(context, 'Izin', Icons.report, Colors.blue),
        _buildCategoryTile(context, 'Kesehatan', Icons.healing, Colors.blue),
      ],
    );
  }

  Widget _buildCategoryTile(BuildContext context, String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context, title),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: ListTile(
          leading: Icon(icon, color: color, size: 30),
          title: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade600),
        ),
      ),
    );
  }
}