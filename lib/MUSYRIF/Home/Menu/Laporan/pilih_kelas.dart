import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Laporan/laporan.dart';
import 'package:aplikasi_ortu/MUSYRIF/Home/Menu/Laporan/report_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'detaillaporan.dart';

class PilihKelasPage extends StatelessWidget {
  final List<String> _kelasList = ['Kelas 1', 'Kelas 2', 'Kelas 3', 'Kelas 4', 'Kelas 5', 'Kelas 6'];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReportProvider(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 236, 236, 236),
        appBar: AppBar(
          centerTitle: true,
          title: Text('Pilih Kelas', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blueAccent,
          actions: [
            IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => laporan(onNewsAdded: (report) {
                      Provider.of<ReportProvider>(context, listen: false).addReport(report);
                    }),
                  ),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<ReportProvider>(
            builder: (context, reportProvider, child) {
              return ListView.builder(
                itemCount: _kelasList.length,
                itemBuilder: (context, index) {
                  final kelas = _kelasList[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.school, color: Colors.white),
                      ),
                      title: Text(
                        kelas,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${reportProvider.reportsPerKelas[kelas]?.length ?? 0} laporan',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Detaillaporan(kelas: kelas, reports: reportProvider.reportsPerKelas[kelas] ?? []),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
