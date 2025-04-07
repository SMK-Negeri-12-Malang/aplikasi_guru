import 'package:flutter/material.dart';
import '../../SERVICE/Service_Musyrif/data_siswa.dart';
import 'package:intl/intl.dart'; // Add this import

class Kepesantrenan extends StatefulWidget {
  const Kepesantrenan({super.key});

  @override
  State<Kepesantrenan> createState() => _KepesantrenanState();
}

class _KepesantrenanState extends State<Kepesantrenan> {
  // Add theme colors
  final Color primaryColor = const Color(0xFF1E88E5);
  final Color secondaryColor = const Color(0xFFE3F2FD);
  final Color accentColor = const Color(0xFF64B5F6);

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
  Set<String> selectedStudents = {}; // Add this line back

  // Add new map to store data by date
  Map<String, Map<String, Map<String, String>>> hafalanDataByDate = {};

  List<Map<String, dynamic>> getFilteredStudents(String type) {
    final students = DataSiswa.getMockSiswa()
        .where((student) =>
            student['session'] == selectedSession &&
            student['level'] == selectedLevel)
        .toList();

    // Initialize data for current date if not exists
    if (!hafalanDataByDate.containsKey(selectedDate)) {
      hafalanDataByDate[selectedDate] = {};
    }

    // Set current hafalanData to selected date's data
    hafalanData = hafalanDataByDate[selectedDate]!;

    return students;
  }

  void _showInputDialog(Map<String, dynamic> student) {
    Map<String, String> existingData = hafalanData[student['id']] ??
        {
          'surat': '',
          'ayatAwal': '',
          'ayatAkhir': '',
          'nilai': grades[0], // Set default grade
        };

    String surat = existingData['surat'] ?? '';
    String ayatAwal = existingData['ayatAwal'] ?? '';
    String ayatAkhir = existingData['ayatAkhir'] ?? '';
    String nilai = existingData['nilai'] ?? grades[0];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Add StatefulBuilder to handle dropdown state
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Input Hafalan ${student['name']}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Surat'),
                      controller: TextEditingController(text: surat),
                      onChanged: (value) => surat = value,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Ayat Awal'),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: ayatAwal),
                      onChanged: (value) => ayatAwal = value,
                    ),
                    TextField(
                      decoration:
                          const InputDecoration(labelText: 'Ayat Akhir'),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: ayatAkhir),
                      onChanged: (value) => ayatAkhir = value,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: nilai,
                      decoration: InputDecoration(
                        labelText: 'Nilai',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      items: grades.map((String grade) {
                        return DropdownMenuItem<String>(
                          value: grade,
                          child: Text(grade),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() => nilai = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    this.setState(() {
                      hafalanData[student['id']] = {
                        'surat': surat,
                        'ayatAwal': ayatAwal,
                        'ayatAkhir': ayatAkhir,
                        'nilai': nilai,
                      };
                      // Update data for current date
                      hafalanDataByDate[selectedDate] = Map.from(hafalanData);
                      selectedStudents.add(student['id']);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
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
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 16,
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
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Kelas: ${student['kelas']}',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                    if (hasHafalan) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Surat ${studentHafalan['surat']} '
                          '(${studentHafalan['ayatAwal']}-${studentHafalan['ayatAkhir']})',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (hasHafalan) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 75),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: secondaryColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
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
                          _showInputDialog(student);
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
            onTap: () => _showInputDialog(student),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
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
                  margin:
                      const EdgeInsets.only(bottom: 16), // Add bottom margin
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
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2025),
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
          selectedStudents.clear();
        });
      }
    } catch (e) {
      print('Date picker error: $e');
    }
  }

  Widget _buildDropdown(List<String> items, String value, String hint) {
    if (hint == 'Tanggal') {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryColor.withOpacity(0.2)),
            ),
            child: DropdownButton<String>(
              value: value,
              underline: Container(),
              icon: Icon(Icons.arrow_drop_down, color: primaryColor),
              style:
                  TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
              items: [
                ...items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }),
                const DropdownMenuItem<String>(
                  value: 'more',
                  child: Text('Lihat Lainnya...'),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue == 'more') {
                  _showDatePicker();
                } else if (newValue != null) {
                  setState(() {
                    hafalanDataByDate[selectedDate] = Map.from(hafalanData);
                    selectedDate = newValue;
                    hafalanData = hafalanDataByDate[newValue] ?? {};
                    selectedStudents.clear();
                  });
                }
              },
            ),
          ),
        ],
      );
    }

    // Return original dropdown for other cases
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: Container(),
        icon: Icon(Icons.arrow_drop_down, color: primaryColor),
        style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              if (hint == 'Sesi') {
                selectedSession = newValue;
              } else if (hint == 'Tanggal') {
                // Save current data before changing date
                hafalanDataByDate[selectedDate] = Map.from(hafalanData);
                selectedDate = newValue;
                // Clear current data when changing date
                hafalanData = hafalanDataByDate[newValue] ?? {};
                selectedStudents.clear();
              } else if (hint == 'Tingkat') {
                selectedLevel = newValue;
              }
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
