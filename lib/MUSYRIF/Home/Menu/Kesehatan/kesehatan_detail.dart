import 'package:flutter/material.dart';
import 'package:aplikasi_guru/utils/widgets/custom_app_bar.dart';
import 'kesehatan.dart';

class DetailKesehatan extends StatelessWidget {
  final String kamar;
  const DetailKesehatan({required this.kamar, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredList = kesehatanList.where((data) => data.kamar == kamar).toList();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 233, 233, 233),
      body: CustomScrollView(
        slivers: [
          CustomGradientAppBar(
            title: 'Detail Kesehatan',
            subtitle: kamar,  // Added subtitle instead of concatenating with title
            titleSize: 18.0,  // Smaller title size
            icon: Icons.medical_services,
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
                            Icons.sick_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Belum ada data kesehatan\nuntuk $kamar.',
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
                      children: filteredList.map((data) => _buildKesehatanCard(data)).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKesehatanCard(KesehatanSantri data) {
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
                    data.name[0].toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3F7F),
                        ),
                      ),
                      Text(
                        data.kamar,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            Text(
              'Keluhan:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              data.keluhan,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}