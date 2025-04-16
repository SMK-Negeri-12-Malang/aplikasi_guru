import 'package:flutter/material.dart';

class RekapAbsensiPage extends StatelessWidget {
  final List<Map<String, dynamic>> dataSantri;

  const RekapAbsensiPage({super.key, required this.dataSantri});

  @override
  Widget build(BuildContext context) {
    final hadir = dataSantri.where((s) => s['isPresent']).toList();
    final tidakHadir = dataSantri.where((s) => !s['isPresent']).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rekap Absensi"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("✅ Santri Hadir",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...hadir.map((s) => Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(s['name']),
                      subtitle: Text("Kelas: ${s['kelas']}"),
                    ),
                  )),
              const SizedBox(height: 16),
              const Text("❌ Santri Tidak Hadir",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...tidakHadir.map((s) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.cancel, color: Colors.red),
                      title: Text(s['name']),
                      subtitle: Text("Kelas: ${s['kelas']}"),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
