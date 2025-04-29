import 'package:flutter/material.dart';

class DetailCekSantri extends StatelessWidget {
  final String studentName;
  final String room;
  final String className;
  final String studentId;
  final String session;
  final String type;
  final String ayatAwal;
  final String ayatAkhir;
  final String nilai;

  const DetailCekSantri({
    super.key,
    required this.studentName,
    required this.room,
    required this.className,
    required this.studentId,
    required this.session,
    required this.type,
    required this.ayatAwal,
    required this.ayatAkhir,
    required this.nilai,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: Column(
        children: [
          // Custom AppBar menggunakan Container dengan gradient
          Container(
            height: 130,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Center(
                      child: Text(
                        studentName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Untuk mengimbangi IconButton
                ],
              ),
            ),
          ),

          // Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildCard(
                    title: "Data Santri",
                    children: [
                      _buildInfoTile(Icons.person, "Nama", studentName),
                      _buildInfoTile(Icons.class_, "Kelas", className),
                      _buildInfoTile(Icons.meeting_room, "Ruang", room),
                      _buildInfoTile(Icons.badge, "No. Induk", studentId),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: "Detail Hafalan",
                    children: [
                      _buildInfoTile(Icons.access_time, "Sesi", session),
                      _buildInfoTile(Icons.bookmark, "Tipe", type),
                      _buildInfoTile(Icons.arrow_forward, "Ayat Awal", ayatAwal),
                      _buildInfoTile(Icons.arrow_back, "Ayat Akhir", ayatAkhir),
                      _buildInfoTile(Icons.grade, "Nilai", nilai),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2842),
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Color(0xFF1D2842)),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(value),
    );
  }
}
