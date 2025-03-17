import 'package:flutter/material.dart';

class HistoryTugas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History Tugas'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Tanggal: 2023-10-01'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Sesi: Pagi'),
                Text('Kategori: Matematika'),
                Text('Santri: Ahmad'),
                Text('Nilai: 90'),
              ],
            ),
          ),
          Divider(),
          ListTile(
            title: Text('Tanggal: 2023-10-02'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Sesi: Siang'),
                Text('Kategori: Bahasa Inggris'),
                Text('Santri: Budi'),
                Text('Nilai: 85'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
