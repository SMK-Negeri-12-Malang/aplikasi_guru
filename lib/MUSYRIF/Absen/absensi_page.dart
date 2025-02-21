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

  void _navigateToCategoryPage(String kamar) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryPage(kamar: kamar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Absensi Kamar"),
        backgroundColor: Colors.blueAccent,
      ),
      body: PageView.builder(
        itemCount: kamarList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _navigateToCategoryPage(kamarList[index]),
            child: Card(
              margin: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  kamarList[index],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryPage extends StatelessWidget {
  final String kamar;
  const CategoryPage({required this.kamar, Key? key}) : super(key: key);

  void _navigateToDetail(BuildContext context, String category) {
    Widget page;
    switch (category) {
      case 'Laporan':
        page = LaporanDetail( kamar: kamar);
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Kategori - $kamar"),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildCategoryTile(context, 'Laporan', Icons.description),
          _buildCategoryTile(context, 'Izin', Icons.assignment_turned_in),
          _buildCategoryTile(context, 'Kesehatan', Icons.local_hospital),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context, title),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: Icon(icon, color: Colors.blue.shade900, size: 30),
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
