import 'package:flutter/material.dart';

class AbsensiKelasPage extends StatefulWidget {
  const AbsensiKelasPage({super.key});

  @override
  _AbsensiKelasPageState createState() => _AbsensiKelasPageState();
}

class _AbsensiKelasPageState extends State<AbsensiKelasPage> {
  final List<String> kelasList = ['Kelas A', 'Kelas B', 'Kelas C', 'Kelas D'];
  final Map<String, List<Map<String, dynamic>>> siswaData = {
    'Kelas A': [
      {'name': 'Paul Walker', 'absen': '01', 'checked': false},
      {'name': 'John Doe', 'absen': '02', 'checked': false},
    ],
    'Kelas B': [
      {'name': 'Jane Doe', 'absen': '01', 'checked': false},
      {'name': 'Max Payne', 'absen': '02', 'checked': false},
    ],
    'Kelas C': [
      {'name': 'Alice Brown', 'absen': '01', 'checked': false},
      {'name': 'Bob Smith', 'absen': '02', 'checked': false},
    ],
    'Kelas D': [
      {'name': 'Charlie Green', 'absen': '01', 'checked': false},
      {'name': 'Emma White', 'absen': '02', 'checked': false},
    ],
  };

  String? selectedClass;
  int checkedCount = 0;

  void _toggleCheck(int index) {
    setState(() {
      if (selectedClass != null) {
        siswaData[selectedClass]![index]['checked'] =
            !siswaData[selectedClass]![index]['checked'];
        checkedCount = siswaData[selectedClass]!
            .where((siswa) => siswa['checked'])
            .length;
      }
    });
  }

  void _addSiswa() {
    if (selectedClass != null) {
      TextEditingController nameController = TextEditingController();
      TextEditingController absenController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Tambah Siswa Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nama Siswa'),
              ),
              TextField(
                controller: absenController,
                decoration: InputDecoration(labelText: 'Nomor Absen'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  siswaData[selectedClass]!.add({
                    'name': nameController.text,
                    'absen': absenController.text,
                    'checked': false,
                  });
                });
                Navigator.pop(context);
              },
              child: Text('Tambah'),
            ),
          ],
        ),
      );
    }
  }

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
                      checkedCount = siswaData[selectedClass]!
                          .where((siswa) => siswa['checked'])
                          .length;
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            kelas,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (selectedClass == kelas)
                            Text(
                              checkedCount == (siswaData[selectedClass]?.length ?? 0)
                                  ? 'Hadir Semua'
                                  : 'Hadir: $checkedCount',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          if (selectedClass == null) ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 100,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Pilih kelas untuk melihat daftar siswa',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Siswa di $selectedClass',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.blue.shade900),
                    onPressed: _addSiswa,
                  ),
                ],
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
                      title: Text(siswa['name']!, style: TextStyle(color: Colors.white)),
                      subtitle: Text('Absen: ${siswa['absen']}', style: TextStyle(color: Colors.white70)),
                      trailing: Checkbox(
                        value: siswa['checked'],
                        onChanged: (value) {
                          _toggleCheck(index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
