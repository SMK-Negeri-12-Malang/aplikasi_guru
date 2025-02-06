import 'package:flutter/material.dart';

class TampilanPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<TampilanPage> {
  bool _isDarkTheme = false;

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: _isDarkTheme ? Colors.grey[900] : Colors.blue[300],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        color: _isDarkTheme ? Colors.black : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change Theme',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isDarkTheme ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _toggleTheme,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isDarkTheme ? Colors.grey[700] : Colors.blue[400],
                foregroundColor: Colors.white,
              ),
              child: Text(
                _isDarkTheme ? 'Switch to Light Theme' : 'Switch to Dark Theme',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
