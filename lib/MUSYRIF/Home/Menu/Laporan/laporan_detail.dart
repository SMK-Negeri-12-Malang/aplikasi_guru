import 'package:flutter/material.dart';
import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Laporan/laporan.dart'; // Impor file yang berisi `laporanList`

class LaporanDetail extends StatelessWidget {
  final String kamar;

  LaporanDetail({required this.kamar});

  @override
  Widget build(BuildContext context) {
    final filteredLaporan = laporanList.where((laporan) => laporan.kamar == kamar).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Laporan Pelanggaran - $kamar"),
        backgroundColor: Colors.blueAccent,
      ),
      body: filteredLaporan.isEmpty
          ? Center(
              child: Text(
                "Belum ada laporan untuk $kamar.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredLaporan.length,
              itemBuilder: (context, index) {
                final data = filteredLaporan[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      data.nama,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        "Kamar: ${data.kamar}\n"
                        "Pelanggaran: ${data.pelanggaran}\n"
                        "Tanggal: ${data.tanggal}\n"
                        "Poin: ${data.poin}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
