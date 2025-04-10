import 'dart:convert';

import 'package:flutter/material.dart';
import '../../SERVICE/Service_Musyrif/data_siswa.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'surat.dart'; // Import surah list
import 'popup.dart'; // Import the PopupInput widget

class Kepesantrenan extends StatefulWidget {
  const Kepesantrenan({super.key});

  @override
  State<Kepesantrenan> createState() => _KepesantrenanState();

  static Map<String, Map<String, Map<String, String>>> hafalanDataByDate = {};

  static List<Map<String, dynamic>> getTopScores(
      Map<String, Map<String, String>> hafalanData) {
    List<Map<String, dynamic>> scores = hafalanData.entries.map((entry) {
      return {
        'id': entry.key,
        'name': DataSiswa.getMockSiswa()
            .firstWhere((s) => s['id'] == entry.key)['name'],
        'surat': entry.value['surat'] ?? '',
        'progress': _convertSurahToProgress(entry.value['surat'] ?? ''),
      };
    }).toList();

    scores.sort((a, b) => b['progress'].compareTo(a['progress']));
    return scores.take(10).toList();
  }

  static int _convertSurahToProgress(String surah) {
    // Map surah names to their order in the Quran (Juz 30 to Juz 1)
    const surahOrder = {
      'An-Nas': 114,
      'Al-Falaq': 113,
      'Al-Ikhlas': 112,
      // ...add all surahs in reverse order...
      'Al-Baqarah': 2,
      'Al-Fatihah': 1,
    };

    return surahOrder[surah] ?? 0; // Default to 0 if surah is not found
  }

  static List<Map<String, dynamic>> getLeaderboardData(
      Map<String, Map<String, Map<String, String>>> hafalanDataByDate) {
    List<Map<String, dynamic>> allScores = [];

    hafalanDataByDate.forEach((date, hafalanData) {
      allScores.addAll(getTopScores(hafalanData));
    });

    allScores.sort((a, b) => b['progress'].compareTo(a['progress']));
    return allScores.take(10).toList();
  }
}

class _KepesantrenanState extends State<Kepesantrenan> {
  // Update theme colors to be slightly darker
  final Color primaryColor = const Color(0xFF0B3C91); // Darker blue for AppBar
  final Color secondaryColor = const Color(0xFF165AA3); // Slightly darker blue
  final Color accentColor = const Color(0xFF2E7BCF); // Slightly darker accent

  String selectedSession = 'Sesi 1';
  String selectedDate = DateTime.now().toString().split(' ')[0];
  String selectedLevel = 'SMP';

  final List<String> sessions = ['Sesi 1', 'Sesi 2', 'Sesi 3'];
  final List<String> dates = [
    DateTime.now().toString().split(' ')[0],
    DateTime.now().subtract(const Duration(days: 1)).toString().split(' ')[0],
    DateTime.now().subtract(const Duration(days: 2)).toString().split(' ')[0],
  ];
  final List<String> levels = ['SMP', 'SMA'];
  final List<String> grades = ['Mumtaz', 'Jayyid Jiddan', 'Jayyid', 'Maqbul'];

  int _currentPage = 0;
  Map<String, Map<String, String>> hafalanData = {};
  Set<String> selectedStudents = {};

  Map<String, Map<String, Map<String, String>>> hafalanDataByDate = {};

  late SharedPreferences _prefs;
  bool _dataInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    _prefs = await SharedPreferences.getInstance();

    String? savedData = _prefs.getString('hafalanDataByDate');
    if (savedData != null) {
      try {
        final Map<String, dynamic> decodedData = json.decode(savedData);
        final Map<String, Map<String, Map<String, String>>> convertedData = {};

        decodedData.forEach((date, studentData) {
          convertedData[date] = {};
          (studentData as Map<String, dynamic>).forEach((studentId, data) {
            convertedData[date]![studentId] =
                Map<String, String>.from(data as Map);
          });
        });

        setState(() {
          Kepesantrenan.hafalanDataByDate = convertedData;
          hafalanDataByDate = convertedData;
          hafalanData = hafalanDataByDate[selectedDate] ?? {};
          _updateSelectedStudents();
          _dataInitialized = true;
        });
      } catch (e) {
        print('Error loading saved data: $e');
      }
    }
  }

  Future<void> _saveData() async {
    try {
      await _prefs.setString(
          'hafalanDataByDate', json.encode(hafalanDataByDate));
      Kepesantrenan.hafalanDataByDate = hafalanDataByDate;
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  @override
  void dispose() {
    _saveData();
    super.dispose();
  }

  List<Map<String, dynamic>> getFilteredStudents(String type) {
    final students = DataSiswa.getMockSiswa()
        .where((student) =>
            student['session'] == selectedSession &&
            student['level'] == selectedLevel)
        .toList();

    if (!hafalanDataByDate.containsKey(selectedDate)) {
      hafalanDataByDate[selectedDate] = {};
    }

    hafalanData = hafalanDataByDate[selectedDate]!;

    _updateSelectedStudents();

    return students;
  }

  void _updateSelectedStudents() {
    selectedStudents.clear();
    hafalanData.forEach((studentId, data) {
      if (data['surat']?.isNotEmpty == true) {
        selectedStudents.add(studentId);
      }
    });
  }

  Widget buildStudentList(String type) {
    final students = getFilteredStudents(type);
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final studentHafalan = hafalanData[student['id']];
        final hasHafalan =
            studentHafalan != null && studentHafalan['surat']!.isNotEmpty;
        final isSelected = selectedStudents.contains(student['id']);

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            title: Text(
              student['name'],
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Kelas: ${student['kelas']}',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                    if (hasHafalan) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: secondaryColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Surat ${studentHafalan['surat']} '
                            '(${studentHafalan['ayatAwal']}-${studentHafalan['ayatAkhir']})',
                            style: TextStyle(
                              fontSize: 13,
                              color: accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (hasHafalan) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 90),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: secondaryColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Nilai: ${studentHafalan['nilai']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            trailing: Container(
              width: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: isSelected,
                      activeColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (bool? value) {
                        if (value == true) {
                          _showPopupDialog(student);
                        } else {
                          setState(() {
                            selectedStudents.remove(student['id']);
                          });
                        }
                      },
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: primaryColor,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPopupDialog(Map<String, dynamic> student) {
    final studentHafalan = hafalanData[student['id']] ??
        {
          'surat': '',
          'ayatAwal': '',
          'ayatAkhir': '',
          'nilai': grades[0],
        };

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (BuildContext context) {
        return PopupInput(
          initialSurat: studentHafalan['surat'] ?? '',
          initialAyatAwal: studentHafalan['ayatAwal'] ?? '',
          initialAyatAkhir: studentHafalan['ayatAkhir'] ?? '',
          initialNilai: studentHafalan['nilai'] ?? grades[0],
          grades: grades,
          onSave: (surat, ayatAwal, ayatAkhir, nilai) {
            setState(() {
              hafalanData[student['id']] = {
                'surat': surat,
                'ayatAwal': ayatAwal,
                'ayatAkhir': ayatAkhir,
                'nilai': nilai,
              };
              hafalanDataByDate[selectedDate] = Map.from(hafalanData);
              Kepesantrenan.hafalanDataByDate = hafalanDataByDate;
              selectedStudents.add(student['id']);
            });
            _saveData();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor, // Use updated darker primary color
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        toolbarHeight: 100, // Make AppBar taller
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Kepesantrenan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Program Tahfidz & Tahsin',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor.withOpacity(0.1), Colors.white],
          ),
        ),
        child: Column(
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
                  _buildDropdown(sessions, selectedSession, 'Sesi'),
                  _buildDropdown(dates, selectedDate, 'Tanggal'),
                  _buildDropdown(levels, selectedLevel, 'Tingkat'),
                ],
              ),
            ),
            Column(
              children: [
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
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 2; i++)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _currentPage
                                ? primaryColor
                                : primaryColor.withOpacity(0.3),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child:
                    buildStudentList(_currentPage == 0 ? 'Tahfidz' : 'Tahsin'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() async {
    try {
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
          hafalanData = hafalanDataByDate[newDate] ?? {};
          _updateSelectedStudents();
        });
        _saveData();
      }
    } catch (e) {
      print('Date picker error: $e');
    }
  }

  Widget _buildDropdown(List<String> items, String value, String hint) {
    // For date field, show a clickable container instead of dropdown
    if (hint == 'Tanggal') {
      return InkWell(
        onTap: _showDatePicker,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primaryColor.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.calendar_today, color: Colors.white, size: 16)
            ],
          ),
        ),
      );
    }

    // Original dropdown for other fields
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: Container(),
        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        dropdownColor: secondaryColor,
        isDense: true,
        menuMaxHeight: 300,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: const TextStyle(color: Colors.white)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              if (hint == 'Sesi') {
                selectedSession = newValue;
              } else if (hint == 'Tingkat') {
                selectedLevel = newValue;
              }

              // Save current data to shared preferences whenever any setting changes
              _saveData();
            });
          }
        },
      ),
    );
  }

  Widget _buildPageViewItem(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, accentColor],
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
}
