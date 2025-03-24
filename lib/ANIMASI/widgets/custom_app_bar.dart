import 'package:flutter/material.dart';

class CustomGradientAppBar extends StatelessWidget {
  final String title;
  final String? subtitle; // Subtitle opsional
  final IconData icon;
  final double height;
  final Color textColor;
  final Color? iconColor;
  final double? titleSize; // Ukuran title opsional
  final Widget child;
  final bool showBackButton; // Menentukan apakah back button ditampilkan

  const CustomGradientAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.height = 50,
    this.textColor = Colors.white,
    this.iconColor,
    this.titleSize = 25,
    required this.child,
    this.showBackButton = true, // Defaultnya true agar ada tombol kembali
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: height,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: iconColor ?? Colors.white),
              onPressed: () => Navigator.pop(context),
            )
          : null, // Jika tidak diaktifkan, leading akan kosong
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
                  fontSize: titleSize ?? 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [], // Tidak ada ikon tambahan di kanan
    );
  }
}
