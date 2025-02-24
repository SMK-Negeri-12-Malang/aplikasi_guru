import 'package:flutter/material.dart';
import 'izin.dart'; // Import izin.dart untuk mengakses izinList

class IzinDetail extends StatelessWidget {
  final String kamar;

  const IzinDetail({required this.kamar, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter data berdasarkan kamar yang dipilih
    final filteredList = izinList.where((data) => data.kamar == kamar).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Izin - $kamar'),
        backgroundColor: Colors.blueAccent,
      ),
      body: filteredList.isEmpty
          ? Center(
              child: Text(
                'Belum ada data izin yang masuk untuk $kamar.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final data = filteredList[index];
                return Card(
                  child: ListTile(
                    title: Text(data.nama, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kamar: ${data.kamar}'),
                        Text('Halaqo: ${data.halaqo}'),
                        Text('Musyrif: ${data.musyrif}'),
                        Text('Tanggal: ${data.tanggal}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}