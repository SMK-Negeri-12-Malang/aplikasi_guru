import 'package:aplikasi_ortu/pages/keamanan.dart';
import 'package:aplikasi_ortu/pages/privacy.dart';
import 'package:aplikasi_ortu/pages/profil.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
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
          'Pengaturan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Pengaturan Akun'),
            _buildSettingCard(
              icon: Icons.person,
              title: 'Ubah Profil',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
            ),
            _buildSettingCard(
              icon: Icons.security,
              title: 'Keamanan',
              onTap: () {
                    Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecurityPage()),
                );
              },
            ),
            _buildSettingCard(
              icon: Icons.privacy_tip,
              title: 'Privasi',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
                );
              },
            ),
            SizedBox(height: 20),
            _buildSectionTitle('Pengaturan Aplikasi'),
            _buildSettingCard(
              icon: Icons.brush,
              title: 'Tampilan',
              onTap: () {
                // Navigasi ke halaman tampilan
              },
            ),
            _buildSettingCard(
              icon: Icons.notifications,
              title: 'Notifikasi',
              onTap: () {
                // Navigasi ke halaman notifikasi
              },
            ),
            _buildSettingCard(
              icon: Icons.language,
              title: 'Bahasa',
              onTap: () {
                // Navigasi ke halaman bahasa
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

  Widget _buildSettingCard({required IconData icon, required String title, required VoidCallback onTap}) {
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
