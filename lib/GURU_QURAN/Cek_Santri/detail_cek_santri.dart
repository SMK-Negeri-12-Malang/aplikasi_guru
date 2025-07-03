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

  // Tambahan detail
  final String jalan;
  final String rtrw;
  final String kota;
  final String telepon;
  final String namaAyah;
  final String teleponAyah;
  final String namaIbu;
  final String teleponIbu;
  final String namaWali;
  final String teleponWali;
  final String halaqoh;
  final String tahfidzTerakhir;
  final String virtualAccount;
  final String vaUangSaku;
  final List<dynamic> dataTahfidz;

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
    required this.jalan,
    required this.rtrw,
    required this.kota,
    required this.telepon,
    required this.namaAyah,
    required this.teleponAyah,
    required this.namaIbu,
    required this.teleponIbu,
    required this.namaWali,
    required this.teleponWali,
    required this.halaqoh,
    required this.tahfidzTerakhir,
    required this.virtualAccount,
    required this.vaUangSaku,
    required this.dataTahfidz,
  });

  @override
  Widget build(BuildContext context) {
    final initials = studentName.isNotEmpty
        ? studentName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '?';

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
          // Avatar besar
          Container(
            margin: const EdgeInsets.only(top: 18, bottom: 8),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Color(0xFF2E3F7F),
              child: Text(
                initials,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
            ),
          ),
          // Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // --- Data Pribadi ---
                  _buildCard(
                    title: "Data Pribadi",
                    children: [
                      _buildInfoTile(Icons.person, "Nama", studentName),
                      _buildInfoTile(Icons.badge, "No. Induk (NIS)", studentId),
                      _buildInfoTile(Icons.class_, "Kelas", className),
                      _buildInfoTile(Icons.meeting_room, "Ruang", room),
                      _buildInfoTile(Icons.group, "Halaqoh", halaqoh),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // --- Kontak & Alamat ---
                  _buildCard(
                    title: "Kontak & Alamat",
                    children: [
                      _buildInfoTile(Icons.location_on, "Jalan", jalan),
                      _buildInfoTile(Icons.home, "RT/RW", rtrw),
                      _buildInfoTile(Icons.location_city, "Kota/Kabupaten", kota),
                      _buildInfoTile(Icons.phone, "Telepon", telepon),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // --- Orang Tua & Wali ---
                  _buildCard(
                    title: "Orang Tua & Wali",
                    children: [
                      _buildInfoTile(Icons.person_outline, "Nama Ayah", namaAyah),
                      _buildInfoTile(Icons.phone_android, "No. Telepon Ayah", teleponAyah),
                      _buildInfoTile(Icons.person_outline, "Nama Ibu", namaIbu),
                      _buildInfoTile(Icons.phone_android, "No. Telepon Ibu", teleponIbu),
                      _buildInfoTile(Icons.person_outline, "Nama Wali", namaWali),
                      _buildInfoTile(Icons.phone_android, "No. Telepon Wali", teleponWali),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // --- Keuangan ---
                  _buildCard(
                    title: "Keuangan",
                    children: [
                      _buildInfoTile(Icons.credit_card, "Virtual Account", virtualAccount),
                      _buildInfoTile(Icons.account_balance_wallet, "VA Uang Saku", vaUangSaku),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // --- Tahfidz Terakhir ---
                  _buildCard(
                    title: "Tahfidz Terakhir",
                    children: [
                      _buildInfoTile(Icons.book, "Tahfidz Terakhir", tahfidzTerakhir),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Divider(thickness: 1.2, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  // --- Detail Hafalan ---
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
                  const SizedBox(height: 18),
                  Divider(thickness: 1.2, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  // --- Riwayat Tahfidz ---
                  _buildTahfidzTable(dataTahfidz),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF2E3F7F)),
                SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2842),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFF2E3F7F), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 15, color: Colors.black87),
                children: [
                  TextSpan(
                    text: "$title: ",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTahfidzTable(List<dynamic> data) {
    if (data.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text("Belum ada data tahfidz."),
        ),
      );
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Color(0xFF2E3F7F).withOpacity(0.08)),
          columns: const [
            DataColumn(label: Text('Tanggal')),
            DataColumn(label: Text('Sesi')),
            DataColumn(label: Text('Surat')),
            DataColumn(label: Text('Ayat Awal')),
            DataColumn(label: Text('Ayat Akhir')),
            DataColumn(label: Text('Jml Baris')),
            DataColumn(label: Text('Nilai')),
            DataColumn(label: Text('Ustadz')),
            DataColumn(label: Text('Status')),
          ],
          rows: data.map<DataRow>((item) {
            return DataRow(
              cells: [
                DataCell(Text(item['tanggal'] ?? '-', style: TextStyle(fontSize: 13))),
                DataCell(Text(item['sesi'] ?? '-', style: TextStyle(fontSize: 13))),
                DataCell(Text(item['surat'] ?? '-', style: TextStyle(fontSize: 13))),
                DataCell(Text(item['ayatAwal'] ?? '-', style: TextStyle(fontSize: 13))),
                DataCell(Text(item['ayatAkhir'] ?? '-', style: TextStyle(fontSize: 13))),
                DataCell(Text(item['jumlahBaris']?.toString() ?? '-', style: TextStyle(fontSize: 13))),
                DataCell(Text(item['nilai'] ?? '-', style: TextStyle(fontSize: 13))),
                DataCell(Text(item['ustadz'] ?? '-', style: TextStyle(fontSize: 13))),
                DataCell(Text(item['status'] ?? '-', style: TextStyle(fontSize: 13))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
