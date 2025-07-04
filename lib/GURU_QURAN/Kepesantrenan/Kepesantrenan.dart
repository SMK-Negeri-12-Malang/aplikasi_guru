import 'dart:convert';
import 'package:flutter/material.dart';
import '../../SERVICE/Service_Musyrif/data_siswa.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'popup.dart';

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

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      separatorBuilder: (_, __) => SizedBox(height: 10),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final key =
            '${student['id']}_${_currentPage == 0 ? 'Tahfidz' : 'Tahsin'}';
        final data = hafalanData[key] ?? {};
        final ayatAwal = data['ayatAwal'] ?? '-';
        final ayatAkhir = data['ayatAkhir'] ?? '-';
        final nilai = data['nilai'] ?? '-';

        final initials = (student['name'] ?? '')
            .toString()
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase();

        Color badgeColor;
        Color badgeText;
        switch (nilai) {
          case 'Mumtaz':
            badgeColor = Colors.green.shade100;
            badgeText = Colors.green.shade800;
            break;
          case 'Jayyid Jiddan':
            badgeColor = Colors.blue.shade100;
            badgeText = Colors.blue.shade800;
            break;
          case 'Jayyid':
            badgeColor = Colors.orange.shade100;
            badgeText = Colors.orange.shade800;
            break;
          case 'Maqbul':
            badgeColor = Colors.red.shade100;
            badgeText = Colors.red.shade800;
            break;
          default:
            badgeColor = Colors.grey.shade200;
            badgeText = Colors.grey.shade700;
        }

        return InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _showInputDialog(student),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  primaryColor.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.10),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: badgeColor,
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: primaryColor.withOpacity(0.13),
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama dan badge nilai
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                student['name'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  fontSize: 16.5,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                nilai,
                                style: TextStyle(
                                  color: badgeText,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        // Kelas dan sesi
                        Row(
                          children: [
                            Icon(Icons.class_, size: 15, color: Colors.blue.shade700),
                            SizedBox(width: 4),
                            Text(
                              student['kelas'] ?? '-',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.event_note, size: 15, color: Colors.orange.shade700),
                            SizedBox(width: 4),
                            Text(
                              selectedSession,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        // Ayat Awal/Akhir
                        Row(
                          children: [
                            Icon(Icons.bookmark, size: 15, color: Colors.purple.shade400),
                            SizedBox(width: 4),
                            Text(
                              'Awal: ',
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                            ),
                            Text(
                              ayatAwal,
                              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.bookmark_border, size: 15, color: Colors.purple.shade400),
                            SizedBox(width: 4),
                            Text(
                              'Akhir: ',
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                            ),
                            Text(
                              ayatAkhir,
                              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Edit icon
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(7),
                      child: Icon(Icons.edit, color: primaryColor, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: Column(
        children: [
          // Header
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
                padding: const EdgeInsets.only(top: 1.0),
                child: Center(
                  child: Text(
                    'Kepesantrenan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Filter panel
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.10),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  value: selectedSession,
                  underline: SizedBox(),
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
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
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: primaryColor),
                        const SizedBox(width: 6),
                        Text(
                          selectedDate,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: selectedLevel,
                  underline: SizedBox(),
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
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
          // Tahfidz/Tahsin switch + Add button in one row, 3/4 and 1/4
          Row(
            children: [
              // Switch Card (3/4)
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.only(left: 16, top: 6, bottom: 6, right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.10),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _currentPage == 0 ? primaryColor : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextButton(
                            onPressed: () => setState(() => _currentPage = 0),
                            child: Text(
                              'Tahfidz',
                              style: TextStyle(
                                color: _currentPage == 0 ? Colors.white : primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _currentPage == 1 ? primaryColor : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextButton(
                            onPressed: () => setState(() => _currentPage = 1),
                            child: Text(
                              'Tahsin',
                              style: TextStyle(
                                color: _currentPage == 1 ? Colors.white : primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Add Button Card (1/4)
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.only(right: 16, top: 6, bottom: 6, left: 0),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.10),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Material(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => InputHafalanDialog(
                              namaSantri: '',
                              ayatAwal: '',
                              ayatAkhir: '',
                              nilaiAwal: grades[0],
                              nilaiList: grades,
                              onSimpan: (ayatAwal, ayatAkhir, nilai) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Data hafalan berhasil ditambahkan')),
                                );
                              },
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 38,
                          width: 38,
                          child: Icon(Icons.add, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Student list
          Expanded(child: _buildStudentList()),
        ],
      ),
    );
  }
}

