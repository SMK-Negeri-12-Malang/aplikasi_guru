import 'dart:convert';
import 'package:flutter/material.dart';
import '../../SERVICE/Service_Musyrif/data_siswa.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Kepesantrenan extends StatefulWidget {
  const Kepesantrenan({super.key});

  @override
  State<Kepesantrenan> createState() => _KepesantrenanState();
}

class _KepesantrenanState extends State<Kepesantrenan> {
  final Color primaryColor = const Color(0xFF1D2842);
  final List<String> sessions = ['Sesi 1', 'Sesi 2', 'Sesi 3'];
  final List<String> levels = ['SMP', 'SMA'];
  final List<String> grades = ['Mumtaz', 'Jayyid Jiddan', 'Jayyid', 'Maqbul'];

  String selectedSession = 'Sesi 1';
  String selectedDate = DateTime.now().toString().split(' ')[0];
  String selectedLevel = 'SMP';

  final List<String> dates = [
    DateTime.now().toString().split(' ')[0],
    DateTime.now().subtract(const Duration(days: 1)).toString().split(' ')[0],
    DateTime.now().subtract(const Duration(days: 2)).toString().split(' ')[0],
  ];

  int _currentPage = 0; // 0 for Tahfidz, 1 for Tahsin
  Map<String, Map<String, String>> tahfidzData = {};
  Map<String, Map<String, String>> tahsinData = {};
  Map<String, Map<String, Map<String, String>>> tahfidzDataByDate = {};
  Map<String, Map<String, Map<String, String>>> tahsinDataByDate = {};
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _loadLastSelectedPreferences();
  }

  Future<void> _loadSavedData() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTahfidzData = _prefs.getString('tahfidzDataByDate');
    final savedTahsinData = _prefs.getString('tahsinDataByDate');

    if (savedTahfidzData != null) {
      tahfidzDataByDate = Map<String, Map<String, Map<String, String>>>.from(
        json.decode(savedTahfidzData).map((key, value) => MapEntry(
            key,
            Map<String, Map<String, String>>.from(value
                .map((k, v) => MapEntry(k, Map<String, String>.from(v)))))),
      );
    }

    if (savedTahsinData != null) {
      tahsinDataByDate = Map<String, Map<String, Map<String, String>>>.from(
        json.decode(savedTahsinData).map((key, value) => MapEntry(
            key,
            Map<String, Map<String, String>>.from(value
                .map((k, v) => MapEntry(k, Map<String, String>.from(v)))))),
      );
    }

    setState(() {
      tahfidzData = tahfidzDataByDate[selectedDate] ?? {};
      tahsinData = tahsinDataByDate[selectedDate] ?? {};
    });
  }

  Future<void> _loadLastSelectedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedSession = prefs.getString('lastSelectedSession') ?? 'Sesi 1';
      selectedLevel = prefs.getString('lastSelectedLevel') ?? 'SMP';
    });
  }

  Future<void> _saveLastSelectedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastSelectedSession', selectedSession);
    await prefs.setString('lastSelectedLevel', selectedLevel);
  }

  Future<void> _saveData() async {
    if (_currentPage == 0) {
      tahfidzDataByDate[selectedDate] = Map.from(tahfidzData);
      await _prefs.setString(
          'tahfidzDataByDate', json.encode(tahfidzDataByDate));
    } else {
      tahsinDataByDate[selectedDate] = Map.from(tahsinData);
      await _prefs.setString('tahsinDataByDate', json.encode(tahsinDataByDate));
    }

    // Save evaluated students' data for CekSantri
    final evaluatedStudents = [
      ...tahfidzData.entries.map((entry) {
        final studentId = entry.key;
        final studentData = entry.value;
        final studentInfo =
            DataSiswa.getMockSiswa().firstWhere((s) => s['id'] == studentId);
        return {
          'id': studentId,
          'name': studentInfo['name'],
          'className': studentInfo['kelas'],
          'session': selectedSession,
          'surat': studentData['surat'],
          'nilai': studentData['nilai'],
          'level': selectedLevel,
          'type': 'Tahfidz',
        };
      }),
      ...tahsinData.entries.map((entry) {
        final studentId = entry.key;
        final studentData = entry.value;
        final studentInfo =
            DataSiswa.getMockSiswa().firstWhere((s) => s['id'] == studentId);
        return {
          'id': studentId,
          'name': studentInfo['name'],
          'className': studentInfo['kelas'],
          'session': selectedSession,
          'surat': studentData['surat'],
          'nilai': studentData['nilai'],
          'level': selectedLevel,
          'type': 'Tahsin',
        };
      }),
    ];

    await _prefs.setString('evaluatedStudents', json.encode(evaluatedStudents));
  }

  void _showInputDialog(Map<String, dynamic> student) {
    final data =
        (_currentPage == 0 ? tahfidzData : tahsinData)[student['id']] ??
            {'surat': '', 'nilai': grades[0]};
    String surat = data['surat'] ?? '';
    String nilai = data['nilai'] ?? grades[0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Input Hafalan ${student['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Surat'),
              controller: TextEditingController(text: surat),
              onChanged: (value) => surat = value,
            ),
            DropdownButtonFormField<String>(
              value: nilai,
              decoration: const InputDecoration(labelText: 'Nilai'),
              items: grades
                  .map((grade) =>
                      DropdownMenuItem(value: grade, child: Text(grade)))
                  .toList(),
              onChanged: (value) => nilai = value ?? grades[0],
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          TextButton(
            onPressed: () {
              setState(() {
                if (_currentPage == 0) {
                  tahfidzData[student['id']] = {'surat': surat, 'nilai': nilai};
                } else {
                  tahsinData[student['id']] = {'surat': surat, 'nilai': nilai};
                }
              });
              _saveData();
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(selectedDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: primaryColor,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      String newDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        if (!dates.contains(newDate)) {
          dates.insert(0, newDate);
          if (dates.length > 3) dates.removeLast();
        }
        selectedDate = newDate;
        tahfidzData = tahfidzDataByDate[selectedDate] ?? {};
        tahsinData = tahsinDataByDate[selectedDate] ?? {};
      });
      _saveData();
    }
  }

  Widget _buildStudentList() {
    final students = DataSiswa.getMockSiswa()
        .where((s) =>
            s['session'] == selectedSession && s['level'] == selectedLevel)
        .toList();

    final currentData = _currentPage == 0 ? tahfidzData : tahsinData;

    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final data = currentData[student['id']];
        final hasHafalan = data != null && data['surat']!.isNotEmpty;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showInputDialog(student), // Add ripple animation
            borderRadius: BorderRadius.circular(12),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  selectedLevel == 'SMP' || selectedLevel == 'SMA'
                      ? '${student['name']} ${student['kelas']}'
                      : student['name'],
                ),
                subtitle: hasHafalan
                    ? Text('Surat: ${data['surat']}, Nilai: ${data['nilai']}')
                    : const Text('Belum ada hafalan'),
                trailing: Icon(Icons.edit, color: Colors.grey),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageViewItem(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            const Text('Kepesantrenan', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  value: selectedSession,
                  items: sessions
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) => setState(() {
                    selectedSession = value!;
                    tahfidzData = tahfidzDataByDate[selectedDate] ?? {};
                    tahsinData = tahsinDataByDate[selectedDate] ?? {};
                    _saveLastSelectedPreferences();
                  }),
                ),
                InkWell(
                  onTap: _showDatePicker,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(selectedDate,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Icon(Icons.calendar_today, size: 16),
                      ],
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: selectedLevel,
                  items: levels
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (value) => setState(() {
                    selectedLevel = value!;
                    tahfidzData = tahfidzDataByDate[selectedDate] ?? {};
                    tahsinData = tahsinDataByDate[selectedDate] ?? {};
                    _saveLastSelectedPreferences();
                  }),
                ),
              ],
            ),
          ),
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: PageView(
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildPageViewItem('Tahfidz', Icons.menu_book),
                _buildPageViewItem('Tahsin', Icons.record_voice_over),
              ],
            ),
          ),
          Expanded(child: _buildStudentList()),
        ],
      ),
    );
  }
}
