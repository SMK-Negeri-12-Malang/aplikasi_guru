import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pengaturan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        //elevation: 4,
        //shape: RoundedRectangleBorder(
          //borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        //),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Pengaturan Akun'),
            _buildSettingTile(
              icon: Icons.person,
              title: 'Ubah Profil',
              color: Colors.blueAccent,
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.security,
              title: 'Keamanan',
              color: Colors.redAccent,
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.privacy_tip,
              title: 'Privasi',
              color: Colors.green,
              onTap: () {},
            ),
            SizedBox(height: 20),
            _buildSectionTitle('Pengaturan Aplikasi'),
            _buildSettingTile(
              icon: Icons.brush,
              title: 'Tampilan',
              color: Colors.purple,
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.notifications,
              title: 'Notifikasi',
              color: Colors.orange,
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.language,
              title: 'Bahasa',
              color: Colors.teal,
              onTap: () {},
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

  Widget _buildSettingTile({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
