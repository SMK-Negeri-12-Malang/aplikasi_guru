import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class GradePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomGradientAppBar(
            title: 'Penilaian',
            icon: Icons.grade,
            child: Container(),
          ),
          // Your existing grade content here as SliverToBoxAdapter
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                children: [
                  // Your existing grade content
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
