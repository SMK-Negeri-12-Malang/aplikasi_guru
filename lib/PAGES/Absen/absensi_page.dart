import 'package:flutter/material.dart';

class AbsensiKelasPage extends StatefulWidget {
  const AbsensiKelasPage({super.key});

  @override
  _AbsensiKelasPageState createState() => _AbsensiKelasPageState();
}

class _AbsensiKelasPageState extends State<AbsensiKelasPage> {
  // Contoh data kelas
  final List<String> kelasList = ['Kelas A', 'Kelas B', 'Kelas C', 'Kelas D'];

  // Contoh data siswa untuk setiap kelas
  final Map<String, List<Map<String, String>>> siswaData = {
    'Kelas A': [
      {'name': 'Paul Walker', 'absen': '01'},
      {'name': 'John Doe', 'absen': '02'},
    ],
    'Kelas B': [
      {'name': 'Jane Doe', 'absen': '01'},
      {'name': 'Max Payne', 'absen': '02'},
    ],
    'Kelas C': [
      {'name': 'Alice Brown', 'absen': '01'},
      {'name': 'Bob Smith', 'absen': '02'},
    ],
    'Kelas D': [
      {'name': 'Charlie Green', 'absen': '01'},
      {'name': 'Emma White', 'absen': '02'},
    ],
  };

  // Menyimpan kelas yang sedang dipilih
  String? selectedClass;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Absensi Kelas'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0, top: 8.0, bottom: 4.0),
            child: Text(
              'List Kelas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: kelasList.length,
              itemBuilder: (context, index) {
                String kelas = kelasList[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedClass = kelas;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        kelas,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          if (selectedClass != null) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Siswa di $selectedClass',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: siswaData[selectedClass]?.length ?? 0,
                itemBuilder: (context, index) {
                  var siswa = siswaData[selectedClass]![index];
                  return Card(
                    color: Colors.blue.shade300,
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Colors.blue.shade900),
                      ),
                      title: Text(siswa['name']!, style: TextStyle(color: Colors.white)),
                      subtitle: Text('Absen: ${siswa['absen']}', style: TextStyle(color: Colors.white70)),
                      trailing: IconButton(
                        icon: const Icon(Icons.check, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Pilih kelas untuk melihat daftar siswa',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
