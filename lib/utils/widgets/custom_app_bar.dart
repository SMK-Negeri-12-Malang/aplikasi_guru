import 'package:flutter/material.dart';

class CustomGradientAppBar extends StatelessWidget {
  final String title;
  final String? subtitle; // Optional subtitle
  final IconData icon;
  final double height;
  final Color textColor;
  final Color? iconColor;
  final double? titleSize; // Optional titleSize
  final Widget child;

  const CustomGradientAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.height = 50,
    this.textColor = Colors.white,
    this.iconColor,
    this.titleSize = 25, // Optional titleSize
    required this.child, required bool showBackButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: height,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E3F7F),
              Color(0xFF4557A4),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          centerTitle: true,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: titleSize ?? 24.0, // Ukuran title diperbesar
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.0, // Subtitle sedikit diperbesar
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(1), // Memberikan padding agar lebih besar
        child: IconButton(
          iconSize: 30.0, // Ukuran ikon diperbesar
          icon: Icon(Icons.arrow_back_ios, color: iconColor ?? textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(1), // Memberikan padding agar lebih besar
          child: IconButton(
            iconSize: 30.0, // Ukuran ikon diperbesar
            icon: Icon(icon, color: iconColor ?? textColor),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}