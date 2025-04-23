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
  final Color primaryColor = const Color(0xFF2E3F7F);
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

  int _currentPage = 0;
  Map<String, Map<String, String>> hafalanData = {};
  Map<String, Map<String, Map<String, String>>> hafalanDataByDate = {};
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _loadLastSelectedPreferences();
  }

  Future<void> _loadSavedData() async {
    _prefs = await SharedPreferences.getInstance();
    final savedData = _prefs.getString('hafalanDataByDate');
    if (savedData != null) {
      hafalanDataByDate = Map<String, Map<String, Map<String, String>>>.from(
        json.decode(savedData).map((key, value) => MapEntry(
            key,
            Map<String, Map<String, String>>.from(value
                .map((k, v) => MapEntry(k, Map<String, String>.from(v)))))),
      );
      setState(() {
        hafalanData = hafalanDataByDate[selectedDate] ?? {};
      });
    }
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
    await _prefs.setString('hafalanDataByDate', json.encode(hafalanDataByDate));

    final evaluatedStudents = hafalanData.entries.map((entry) {
      final studentId = entry.key.split('_')[0];
      final type = entry.key.split('_')[1];
      final studentData = entry.value;
      return {
        'id': studentId,
        'name': DataSiswa.getMockSiswa().firstWhere((s) => s['id'] == studentId,
                orElse: () => {})['name'] ??
            '',
        'className': DataSiswa.getMockSiswa().firstWhere(
                (s) => s['id'] == studentId,
                orElse: () => {})['kelas'] ??
            '',
        'session': selectedSession,
        'type': type,
        'ayatAwal': studentData['ayatAwal'] ?? '',
        'ayatAkhir': studentData['ayatAkhir'] ?? '',
        'nilai': studentData['nilai'] ?? '',
      };
    }).toList();

    await _prefs.setString('evaluatedStudents', json.encode(evaluatedStudents));
  }

  void _showInputDialog(Map<String, dynamic> student) {
    final key = '${student['id']}_${_currentPage == 0 ? 'Tahfidz' : 'Tahsin'}';
    final data = hafalanData[key] ?? {
      'ayatAwal': '',
      'ayatAkhir': '',
      'nilai': grades[0],
    };
    String ayatAwal = data['ayatAwal'] ?? '';
    String ayatAkhir = data['ayatAkhir'] ?? '';
    String nilai = data['nilai'] ?? grades[0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            'Input Hafalan ${student['name']} (${_currentPage == 0 ? 'Tahfidz' : 'Tahsin'})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Ayat Awal'),
              controller: TextEditingController(text: ayatAwal),
              onChanged: (value) => ayatAwal = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Ayat Akhir'),
              controller: TextEditingController(text: ayatAkhir),
              onChanged: (value) => ayatAkhir = value,
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
                hafalanData[key] = {
                  'ayatAwal': ayatAwal,
                  'ayatAkhir': ayatAkhir,
                  'nilai': nilai,
                };
                hafalanDataByDate[selectedDate] = Map.from(hafalanData);
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
        hafalanData = hafalanDataByDate[selectedDate] ?? {};
      });
      _saveData();
    }
  }

  Widget _buildStudentList() {
    final students = DataSiswa.getMockSiswa()
        .where((s) =>
            s['session'] == selectedSession && s['level'] == selectedLevel)
        .toList();

    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final key =
            '${student['id']}_${_currentPage == 0 ? 'Tahfidz' : 'Tahsin'}';
        final data = hafalanData[key] ?? {};
        final ayatAwal = data['ayatAwal'] ?? '-';
        final ayatAkhir = data['ayatAkhir'] ?? '-';
        final nilai = data['nilai'] ?? '-';

        return GestureDetector(
          onTap: () => _showInputDialog(student),
          child: Card(
            child: ListTile(
              title: Text(
                selectedLevel == 'SMP' || selectedLevel == 'SMA'
                    ? '${student['name'] ?? ''} ${student['kelas'] ?? ''}'
                    : student['name'] ?? '',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ayat Awal: $ayatAwal'),
                  Text('Ayat Akhir: $ayatAkhir'),
                  Text('Nilai: $nilai'),
                ],
              ),
              trailing: const Icon(Icons.edit, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 1.0), // Add padding to move the title down
                child: Center(
                  child: Text(
                    'Kepesantrenan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Filter panel
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
                    hafalanData = hafalanDataByDate[selectedDate] ?? {};
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
                    hafalanData = hafalanDataByDate[selectedDate] ?? {};
                    _saveLastSelectedPreferences();
                  }),
                ),
              ],
            ),
          ),
          // Tahfidz/Tahsin switch
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(8),
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
                ElevatedButton(
                  onPressed: () => setState(() => _currentPage = 0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _currentPage == 0 ? primaryColor : Colors.grey[300],
                  ),
                  child: const Text('Tahfidz',
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _currentPage = 1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _currentPage == 1 ? primaryColor : Colors.grey[300],
                  ),
                  child: const Text('Tahsin',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          // Student list
          Expanded(child: _buildStudentList()),
        ],
      ),
    );
  }
}
