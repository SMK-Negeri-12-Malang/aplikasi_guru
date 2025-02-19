import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Kesehatan/kesehatan.dart';
import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Laporan/laporan.dart';
import 'package:flutter/material.dart';
import 'perizinan.dart';


class MenuPage extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const MenuPage({Key? key, required this.items}) : super(key: key);

  void _onButtonPressed(BuildContext context, String buttonType) {
    Widget? targetPage;

    switch (buttonType) {
      case "Laporan":
        targetPage = Laporan(onNewsAdded: (news) {
          // Handle the news added event
        });
        break;
      case "Perizinan":
        targetPage = PerizinanPage();
        break;
      case "Kesehatan":
        targetPage = Kesehatan();
        break;
      default:
        targetPage = null;
    }

    if (targetPage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetPage!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 3, // 3 kolom
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.0,
        children: items.map((item) {
          return GestureDetector(
            onTap: () => _onButtonPressed(context, item["label"]),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(item["icon"], size: 30, color: Colors.blue.shade700),
                ),
                const SizedBox(height: 8),
                Text(
                  item["label"],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
