import 'package:aplikasi_guru/MUSYRIF/Home/Laporan/Menu/Izin/izin_detail.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_guru/ANIMASI/widgets/custom_app_bar.dart';
import 'izin.dart';

class IzinDetail extends StatefulWidget {
  final String kamar;

  const IzinDetail({required this.kamar, Key? key}) : super(key: key);

  @override
  _IzinDetailState createState() => _IzinDetailState();
}

class _IzinDetailState extends State<IzinDetail> {
  @override
  Widget build(BuildContext context) {
    final filteredList = izinList
        .where((data) =>
            data.kamar == widget.kamar && !data.kamar.contains('Kelas'))
        .toList();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 233, 233, 233),
      body: CustomScrollView(
        slivers: [
          CustomGradientAppBar(
            title: 'Detail Izin',
            subtitle: widget
                .kamar, // Added subtitle instead of concatenating with title
            titleSize: 18.0, // Smaller title size
            icon: Icons.assignment_ind,
            height: 100.0,
            textColor: Colors.white,
            iconColor: Colors.white,
            child: Container(),
          ),
          SliverToBoxAdapter(
            child: filteredList.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Belum ada data izin yang masuk\nuntuk ${widget.kamar}.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      children: filteredList
                          .map((data) => _buildIzinCard(data))
                          .toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildIzinCard(IzinModel data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IzinDetailPage(data: data),
          ),
        );
      },
      child: Container(
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
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFF2E3F7F),
                    child: Text(
                      data.nama[0].toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.nama,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3F7F),
                          ),
                        ),
                        Text(
                          data.tanggal,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(height: 24),
              _buildInfoRow(Icons.room, 'Kamar', data.kamar),
              _buildInfoRow(Icons.group, 'Halaqo', data.halaqo),
              _buildInfoRow(Icons.person, 'Musyrif', data.musyrif),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
