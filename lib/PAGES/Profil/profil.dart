import 'package:flutter/material.dart';

class ProfileDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.green,
                      child: Text(
                        'E',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Efendi Sudarmono',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('Guru Bahasa Thailand'),
                      ],
                    )
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Personal Section
              _buildListItem(
                context,
                icon: Icons.person,
                title: 'Personal',
                subtitle: 'Informasi pemilik akun',
                onTap: () {},
              ),

              // Daftar Anak Section
              _buildListItem(
                context,
                icon: Icons.people,
                title: 'Daftar Anak',
                subtitle: 'Pilih anak sebagai default',
                onTap: () {},
              ),

              // Ubah Password Section
              _buildListItem(
                context,
                icon: Icons.key,
                title: 'Ubah Password',
                subtitle: 'Pengaturan untuk merubah kata sandi',
                onTap: () {},
              ),

              SizedBox(height: 20),

              // Logout Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 160, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.5),
        margin: EdgeInsets.symmetric(vertical: 10),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          leading: Icon(icon, size: 40, color: const Color.fromARGB(255, 168, 171, 174)),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Text(subtitle),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }
}
