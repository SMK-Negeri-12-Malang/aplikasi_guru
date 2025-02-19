import 'package:flutter/material.dart';

class AbsenDetailPage extends StatelessWidget {
  final Map<String, dynamic> siswa;
  final String kelas;

  const AbsenDetailPage({
    Key? key,
    required this.siswa,
    required this.kelas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Absensi'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Siswa',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('Nama'),
                      subtitle: Text(siswa['name']),
                      leading: Icon(Icons.person, color: Colors.blue.shade900),
                    ),
                    ListTile(
                      title: Text('Kelas'),
                      subtitle: Text(kelas),
                      leading: Icon(Icons.class_, color: Colors.blue.shade900),
                    ),
                    ListTile(
                      title: Text('Nomor Absen'),
                      subtitle: Text(siswa['absen']),
                      leading: Icon(Icons.numbers, color: Colors.blue.shade900),
                    ),
                    if (siswa['note'] != null)
                      ListTile(
                        title: Text('Keterangan'),
                        subtitle: Text(siswa['note']),
                        leading: Icon(Icons.note, color: Colors.blue.shade900),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}