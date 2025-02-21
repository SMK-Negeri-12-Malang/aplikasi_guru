import 'package:aplikasi_ortu/utils/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class AbsenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomGradientAppBar(
            title: 'Absensi',
            icon: Icons.event_note,
            child: Container(),
          ),
          // Your existing attendance content here as SliverToBoxAdapter
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                children: [
                  // Your existing attendance content
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
