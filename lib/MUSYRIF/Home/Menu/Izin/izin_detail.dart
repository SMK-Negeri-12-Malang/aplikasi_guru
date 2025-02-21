import 'package:flutter/material.dart';
//izin detail
class IzinDetail extends StatelessWidget {
  final String kamar;

  const IzinDetail({required this.kamar, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Izin - $kamar"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text("Data Izin dari $kamar"),
      ),
    );
  }
}
//
