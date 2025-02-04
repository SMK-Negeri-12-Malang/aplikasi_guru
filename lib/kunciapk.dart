import 'package:flutter/material.dart';

class AppLockPage extends StatefulWidget {
  @override
  _AppLockPageState createState() => _AppLockPageState();
}

class _AppLockPageState extends State<AppLockPage> {
  bool isAppLockEnabled = false;
  String selectedLockMethod = "PIN";

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
          'Kunci Aplikasi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Keamanan Aplikasi'),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 3,
              child: SwitchListTile(
                title: Text('Aktifkan Kunci Aplikasi'),
                subtitle: Text('Gunakan kunci untuk mengamankan aplikasi'),
                secondary: Icon(Icons.lock, color: Colors.blue),
                value: isAppLockEnabled,
                onChanged: (bool value) {
                  setState(() {
                    isAppLockEnabled = value;
                  });
                },
              ),
            ),
            if (isAppLockEnabled) ...[
              SizedBox(height: 16),
              _buildSectionTitle('Metode Kunci'),
              _buildLockOption('PIN', Icons.pin, selectedLockMethod == "PIN", () {
                setState(() {
                  selectedLockMethod = "PIN";
                });
              }),
              _buildLockOption('Sidik Jari (Fingerprint)', Icons.fingerprint, selectedLockMethod == "Fingerprint", () {
                setState(() {
                  selectedLockMethod = "Fingerprint";
                });
              }),
              _buildLockOption('Face ID', Icons.face, selectedLockMethod == "Face ID", () {
                setState(() {
                  selectedLockMethod = "Face ID";
                });
              }),
            ],
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

  Widget _buildLockOption(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: TextStyle(fontSize: 16)),
        trailing: isSelected ? Icon(Icons.check_circle, color: Colors.green) : null,
        onTap: onTap,
      ),
    );
  }
}
