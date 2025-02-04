import 'package:aplikasi_ortu/pages/kunciapk.dart';
import 'package:flutter/material.dart';

class SecurityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Keamanan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Keamanan Akun'),
            _buildSecurityCard(
              icon: Icons.lock,
              title: 'Ubah Kata Sandi',
              onTap: () {
                // Navigasi
              },
            ),
            _buildSecurityCard(
              icon: Icons.shield,
              title: 'Autentikasi Dua Faktor',
              onTap: () {
                // Navigasi ke halaman autentikasi dua faktor
              },
            ),
            _buildSecurityCard(
              icon: Icons.devices,
              title: 'Kelola Sesi Aktif',
              onTap: () {
                // Navigasi ke halaman sesi aktif
              },
            ),
            SizedBox(height: 20),
            _buildSectionTitle('Otorisasi & Akses'),
            _buildSecurityCard(
              icon: Icons.phonelink_lock,
              title: 'Kelola Perangkat Terhubung',
              onTap: () {
                // Navigasi ke halaman perangkat terhubung
              },
            ),
            _buildSecurityCard(
              icon: Icons.vpn_key,
              title: 'Kunci Aplikasi',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppLockPage()),
                );
              },
            ),
            SizedBox(height: 20),
            _buildSectionTitle('Privasi & Data'),
            _buildSecurityCard(
              icon: Icons.privacy_tip,
              title: 'Kelola Data Pribadi',
              onTap: () {
                // Navigasi ke halaman kelola data pribadi
              },
            ),
            _buildSecurityCard(
              icon: Icons.delete_forever,
              title: 'Hapus Akun',
              onTap: () {
                // Navigasi ke halaman hapus akun
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildSecurityCard({required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: TextStyle(fontSize: 16)),
        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
