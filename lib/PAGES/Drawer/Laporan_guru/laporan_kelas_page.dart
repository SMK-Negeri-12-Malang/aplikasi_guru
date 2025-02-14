import 'dart:io';
import 'package:flutter/material.dart';

class LaporanKelasPage extends StatelessWidget {
  final String kelas;
  final List<Map<String, dynamic>> reports;

  LaporanKelasPage({required this.kelas, required this.reports});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan $kelas'),
        backgroundColor: Colors.blue[700],
      ),
      body: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          Color containerColor;
          if (report['poin'] < 10) {
            containerColor = Colors.green[100]!;
          } else if (report['poin'] <= 50) {
            containerColor = Colors.orange[100]!;
          } else {
            containerColor = Colors.red[100]!;
          }
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: containerColor,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Image.file(
                report['image'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(report['Nama']),
              subtitle: Text('Tanggal: ${report['tanggal']} - Waktu: ${report['waktu']} - Poin: ${report['poin']}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPelanggaranPage(report: report),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DetailPelanggaranPage extends StatefulWidget {
  final Map<String, dynamic> report;

  DetailPelanggaranPage({required this.report});

  @override
  _DetailPelanggaranPageState createState() => _DetailPelanggaranPageState();
}

class _DetailPelanggaranPageState extends State<DetailPelanggaranPage> {
  late TextEditingController _poinController;

  @override
  void initState() {
    super.initState();
    _poinController = TextEditingController(text: widget.report['poin'].toString());
  }

  @override
  void dispose() {
    _poinController.dispose();
    super.dispose();
  }

  void _editPoin() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Poin'),
          content: TextField(
            controller: _poinController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Masukkan poin baru',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.report['poin'] = int.parse(_poinController.text);
                });
                Navigator.pop(context);
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> deskripsiList = widget.report['deskripsi'].split('\n');

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pelanggaran'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editPoin,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nama: ${widget.report['Nama']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('Kelas: ${widget.report['kelas']}', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text('Poin: ${widget.report['poin']}', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: deskripsiList.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Deskripsi:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Text(deskripsiList[index], style: TextStyle(fontSize: 14)),
                        SizedBox(height: 10),
                        Text('Tanggal: ${widget.report['tanggal']}', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        Text('Waktu: ${widget.report['waktu']}', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        Image.file(
                          widget.report['image'],
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
