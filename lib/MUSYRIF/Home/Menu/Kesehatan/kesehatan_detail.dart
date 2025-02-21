import 'package:flutter/material.dart';
import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Kesehatan/kesehatan.dart'; // Impor file yang berisi `kesehatanList`

class DetailKesehatan extends StatelessWidget {
  final String kamar;

  const DetailKesehatan({required this.kamar, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter data berdasarkan kamar yang dipilih
    final filteredList = kesehatanList.where((data) => data.kelas == kamar).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Kesehatan - $kamar"),
        backgroundColor: Colors.blueAccent,
      ),
      body: filteredList.isEmpty
          ? Center(child: Text("Tidak ada data kesehatan untuk $kamar"))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final data = filteredList[index];
                return Card(
                  child: ListTile(
                    title: Text(data.name),
                    subtitle: Text("Kelas: ${data.kelas}\nKeluhan: ${data.keluhan}"),
                  ),
                );
              },
            ),
    );
  }
}
