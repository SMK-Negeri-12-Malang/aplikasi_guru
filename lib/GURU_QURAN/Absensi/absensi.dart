import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbsensiPage extends StatefulWidget {
  @override
  _AbsensiPageState createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  List<Map<String, dynamic>> attendanceData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final attendanceJson = prefs.getString('attendanceData');
    if (attendanceJson != null) {
      setState(() {
        attendanceData = List<Map<String, dynamic>>.from(json.decode(attendanceJson));
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendanceData', json.encode(attendanceData));
  }

  void _updateAttendance(int index, bool value) {
    setState(() {
      attendanceData[index]['isPresent'] = value;
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Halaman Absensi"),
      ),
      body: ListView.builder(
        itemCount: attendanceData.length,
        itemBuilder: (context, index) {
          final student = attendanceData[index];
          return Card(
            child: ListTile(
              title: Text(student['name']),
              subtitle: Text("Kelas: ${student['class']}"),
              trailing: Checkbox(
                value: student['isPresent'],
                onChanged: (value) {
                  _updateAttendance(index, value ?? false);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
