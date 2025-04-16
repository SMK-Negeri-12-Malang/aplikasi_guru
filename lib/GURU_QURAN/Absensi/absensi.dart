import 'package:flutter/material.dart';
import 'rekap_absensi_page.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  final List<Map<String, dynamic>> _santriList = [
    {'id': 1, 'name': 'Ahmad', 'kelas': '7A', 'isPresent': false},
    {'id': 2, 'name': 'Bilal', 'kelas': '7B', 'isPresent': false},
    {'id': 3, 'name': 'Cahya', 'kelas': '8A', 'isPresent': false},
  ];

  bool _showRekapButton = false;
  double _rotationAngle = 0;

  void _toggleAbsen(int id, bool? value) {
    setState(() {
      final santri = _santriList.firstWhere((s) => s['id'] == id);
      santri['isPresent'] = value ?? false;
    });
  }

  void _toggleFabMenu() {
    setState(() {
      _showRekapButton = !_showRekapButton;
      _rotationAngle += 0.5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Absensi Santri",
        style:TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Daftar Absensi Santri",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _santriList.length,
                itemBuilder: (context, index) {
                  final santri = _santriList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                santri['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("Kelas: ${santri['kelas']}"),
                            ],
                          ),
                          Checkbox(
                            value: santri['isPresent'],
                            onChanged: (value) =>
                                _toggleAbsen(santri['id'], value),
                            activeColor: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          AnimatedSlide(
            offset: _showRekapButton ? const Offset(0, 0) : const Offset(1.5, 0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: _showRekapButton ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.only(right: 70),
                child: FloatingActionButton(
                  heroTag: 'rekap',
                  mini: true,
                  backgroundColor: Colors.grey,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RekapAbsensiPage(dataSantri: _santriList),
                      ),
                    );
                  },
                  child: const Icon(Icons.list_alt),
                ),
              ),
            ),
          ),
          AnimatedRotation(
            duration: const Duration(milliseconds: 300),
            turns: _rotationAngle,
            child: FloatingActionButton(
              heroTag: 'menu',
              backgroundColor: Colors.green,
              onPressed: _toggleFabMenu,
              child: const Icon(Icons.more_vert,              ),
            ),
          ),
        ],
      ),
    );
  }
}
