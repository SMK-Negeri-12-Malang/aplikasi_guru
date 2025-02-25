import 'package:flutter/material.dart';

class CustomGradientAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;  // Add subtitle support
  final IconData icon;
  final double height;
  final Color textColor;
  final Color? iconColor;
  final double? titleSize;  // Add titleSize support
  final Widget child;

  const CustomGradientAppBar({
    Key? key,
    required this.title,
    this.subtitle,  // Optional subtitle
    required this.icon,
    this.height = 100.0,
    this.textColor = Colors.white,
    this.iconColor,
    this.titleSize,  // Optional titleSize
    required this.child,
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
                  fontSize: titleSize ?? 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: iconColor ?? textColor),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(icon, color: iconColor ?? textColor),
          onPressed: () {},
        ),
      ],
    );
  }
}
