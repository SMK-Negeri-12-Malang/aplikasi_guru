import 'package:flutter/material.dart';

class AbsensiKelasPage extends StatelessWidget {
  const AbsensiKelasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Kelas'),
        backgroundColor: Colors.blue.shade300,
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
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
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
                    title: const Text('Paul Walker', style: TextStyle(color: Colors.white)),
                    subtitle: const Text('Absen: 01', style: TextStyle(color: Colors.white70)),
                    trailing: IconButton(
                      icon: const Icon(Icons.check, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
