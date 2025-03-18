import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryTugas extends StatelessWidget {
  String getCurrentDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    String currentDate = getCurrentDate();

    return Scaffold(
      appBar: AppBar(
        title: Text('History Tugas'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Tanggal: $currentDate'),
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
            title: Text('Tanggal: $currentDate'),
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
