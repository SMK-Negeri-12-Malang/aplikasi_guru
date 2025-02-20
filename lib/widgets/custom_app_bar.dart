import 'package:flutter/material.dart';

class CustomGradientAppBar extends StatelessWidget {
  final String title;
  final double height;
  final Widget? child;
  final IconData icon;
  final Color textColor;

  CustomGradientAppBar({
    required this.title,
    this.height = 180.0,
    this.child,
    this.icon = Icons.school, // Default icon
    this.textColor = Colors.white, // Add text color parameter
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SliverAppBar(
      expandedHeight: height,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: textColor, // Use the text color parameter
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Icon(
                icon,
                size: screenWidth * 0.06,
                color: textColor, // Match icon color with text
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
