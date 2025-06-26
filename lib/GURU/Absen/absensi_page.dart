import 'package:aplikasi_guru/ANIMASI/animations.dart';
import 'package:aplikasi_guru/ANIMASI/widgets/animated_list_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aplikasi_guru/GURU/Absen/history_page.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class AbsensiKelasPage extends StatefulWidget {
  const AbsensiKelasPage({super.key});

  @override
  _AbsensiKelasPageState createState() => _AbsensiKelasPageState();
}

class _AbsensiKelasPageState extends State<AbsensiKelasPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  List<String> kelasList = [];
  Map<String, List<Map<String, dynamic>>> siswaData = {};
  Map<String, bool> attendanceSavedStatus = {};
  bool isLoading = true;

  String? selectedClass;
  int checkedCount = 0;
  int? selectedIndex;
  List<Map<String, dynamic>> savedAttendance = [];
  bool _isAttendanceSaved = false;
  bool _areAllChecked = false;

  // Add these new state variables
  DateTime selectedDate = DateTime.now();
  String? selectedSubject;
  final List<String> subjects = [
    'Matematika',
    'Bahasa Indonesia',
    'IPA',
    'IPS',
    'Bahasa Inggris'
  ];

  // Add these new variables
  String? lastSelectedClass;
  String? lastSelectedSubject;
  DateTime? lastSelectedDate;

  // Add new variables for attendance status
  final List<String> absenceTypes = ['Alpha', 'Izin', 'Sakit'];
  Map<String, String> studentAbsenceStatus = {};

  SharedPreferences? _prefs;

  
  String? tema;
  String? materi;
  String? rpp;

  
  final List<String> jamPelajaranList = [
    'Jam ke-1', 'Jam ke-2', 'Jam ke-3', 'Jam ke-4', 'Jam ke-5', 'Jam ke-6'
  ];
  String? selectedJamPelajaran;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _controller.forward();
    _fetchData();
    _initSharedPreferences();
    _clearOldChecks(); // Clear old checks on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTodayAttendance();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse('https://67ac42f05853dfff53d9e093.mockapi.io/siswa')
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        
        Set<String> classes = {};
        for (var student in data) {
          if (student['kelas'] != null) {
            classes.add(student['kelas'].toString());
          }
        }
        
        Map<String, List<Map<String, dynamic>>> groupedStudents = {};
        Map<String, bool> savedStatus = {};
        
        for (String className in classes) {
          groupedStudents[className] = [];
          savedStatus[className] = false;
         
          // Collect students for this class
          List<Map<String, dynamic>> classStudents = [];
          for (var student in data) {
            if (student['kelas'] == className) {
              classStudents.add({
                'name': student['name'],
                'id': student['id'],
                'absen': student['id'].toString().padLeft(2, '0'),
                'checked': false,
                'kelas': student['kelas'],
              });
            }
          }

          // Sort students by name
          classStudents.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
          groupedStudents[className] = classStudents;
        }
        
        List<String> sortedClasses = classes.toList()..sort();
        
        setState(() {
          kelasList = sortedClasses;
          siswaData = groupedStudents;
          attendanceSavedStatus = savedStatus;
          isLoading = false;
         
          if (sortedClasses.isNotEmpty) {
            selectedClass = sortedClasses[0];
            selectedIndex = 0;
            checkedCount = siswaData[selectedClass]!
                .where((siswa) => siswa['checked'])
                .length;
             
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _controller.forward();
            });
          }
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  void _toggleCheck(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      if (selectedClass != null) {
        siswaData[selectedClass]![index]['checked'] =
            !siswaData[selectedClass]![index]['checked'];
        checkedCount = siswaData[selectedClass]!
            .where((siswa) => siswa['checked'])
            .length;
      }
    });
  }

  void _toggleCheckAllStudents() {
    setState(() {
      if (selectedClass != null) {
        _areAllChecked = !_areAllChecked;
        for (var siswa in siswaData[selectedClass]!) {
          siswa['checked'] = _areAllChecked;
        }
        checkedCount = _areAllChecked ? siswaData[selectedClass]!.length : 0;
      }
    });
  }

  // Add this method to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        // Reset if date changes
        _resetAttendance();
      });
    }
  }

  // Add this method to reset attendance
  void _resetAttendance() {
    if (selectedClass != null) {
      setState(() {
        for (var siswa in siswaData[selectedClass]!) {
          siswa['checked'] = false;
          siswa['note'] = null;
          studentAbsenceStatus.remove(siswa['id']);
        }
        checkedCount = 0;
        _areAllChecked = false;
        attendanceSavedStatus[selectedClass!] = false;
      });
    }
  }

  // Add new method to check if attendance is already taken today
  Future<void> _checkTodayAttendance() async {
    if (selectedClass != null && selectedSubject != null) {
      bool hasAttendance = await _hasAttendanceForToday();
      bool isCheckedToday = await _isSubjectCheckedToday();
      
      setState(() {
        attendanceSavedStatus[selectedClass!] = hasAttendance || isCheckedToday;
      });
    }
  }

  // Modify _buildDateTimeSubjectSelector to check attendance on subject/class change
  Widget _buildDateTimeSubjectSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              // Dropdown Jam Pelajaran: 1.5/4 lebar, samakan tinggi dengan tombol di sebelahnya
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 48, // samakan dengan tinggi ElevatedButton
                  child: DropdownButtonFormField<String>(
                    value: selectedJamPelajaran,
                    decoration: InputDecoration(
                      labelText: 'Jam ke ',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    items: jamPelajaranList.map((String jam) {
                      return DropdownMenuItem(
                        value: jam,
                        child: Text(jam),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedJamPelajaran = newValue;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(width: 8),
              // Tombol Tema/Materi/RPP: 2.5/4 lebar
              Expanded(
                flex: 5,
                child: ElevatedButton.icon(
                  icon: (tema?.isNotEmpty == true || materi?.isNotEmpty == true || rpp?.isNotEmpty == true)
                    ? Icon(Icons.task_alt, color: Colors.white)
                    : Icon(Icons.note_add, color: Colors.white),
                  label: Text(
                    (tema?.isNotEmpty == true || materi?.isNotEmpty == true || rpp?.isNotEmpty == true)
                      ? 'Edit Tema/Materi/RPP'
                      : 'Isi Tema/Materi/RPP',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (tema?.isNotEmpty == true || materi?.isNotEmpty == true || rpp?.isNotEmpty == true)
                      ? Colors.green[700]
                      : const Color.fromARGB(255, 19, 91, 155),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    minimumSize: Size(0, 48), // samakan tinggi
                  ),
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        TextEditingController temaCtrl = TextEditingController(text: tema ?? '');
                        TextEditingController materiCtrl = TextEditingController(text: materi ?? '');
                        TextEditingController rppCtrl = TextEditingController(text: rpp ?? '');
                        return AlertDialog(
                          title: Text('Input Tema, Materi, RPP'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: temaCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'Tema',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: materiCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'Materi',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: rppCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'RPP',
                                    border: OutlineInputBorder(),
                                    alignLabelWithHint: true,
                                  ),
                                  minLines: 4,
                                  maxLines: 8,
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Batal'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  tema = temaCtrl.text;
                                  materi = materiCtrl.text;
                                  rpp = rppCtrl.text;
                                });
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 14, 74, 143),
                                foregroundColor: Colors.white,
                              ),
                              child: Text('Simpan'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedClass,
                  decoration: InputDecoration(
                    labelText: 'Pilih Kelas',
                    border: OutlineInputBorder(),
                  ),
                  items: kelasList.map((String kelas) {
                    return DropdownMenuItem(
                      value: kelas,
                      child: Text(kelas),
                    );
                  }).toList(),
                  onChanged: (String? newValue) async {
                    setState(() {
                      if (selectedClass != newValue) {
                        selectedClass = newValue;
                        _resetAttendance();
                      }
                    });
                    await _checkTodayAttendance();
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedSubject,
                  decoration: InputDecoration(
                    labelText: 'Mata Pelajaran',
                    border: OutlineInputBorder(),
                  ),
                  items: subjects.map((String subject) {
                    return DropdownMenuItem(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
                  onChanged: (String? newValue) async {
                    setState(() {
                      if (selectedSubject != newValue) {
                        selectedSubject = newValue;
                        _resetAttendance();
                      }
                    });
                    await _checkTodayAttendance();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Modify the _saveAttendance method
  void _saveAttendance() async {
    if (selectedClass == null || selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih kelas dan mata pelajaran terlebih dahulu'),
          backgroundColor: const Color.fromARGB(255, 229, 147, 53),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Tambahkan validasi tema, materi, rpp wajib diisi
    if ((tema == null || tema!.trim().isEmpty) ||
        (materi == null || materi!.trim().isEmpty) ||
        (rpp == null || rpp!.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tema, Materi, dan RPP wajib diisi sebelum menyimpan absensi!'),
          backgroundColor: const Color.fromARGB(255, 244, 155, 54),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validasi jam pelajaran juga wajib diisi
    if (selectedJamPelajaran == null || selectedJamPelajaran!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jam pelajaran wajib dipilih sebelum menyimpan absensi!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        int totalStudents = siswaData[selectedClass]?.length ?? 0;
        DateTime now = DateTime.now();
        String currentTime = DateFormat('HH:mm:ss').format(now);
        String currentDate = DateFormat('dd/MM/yyyy').format(now);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Konfirmasi Simpan Absensi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Detail Absensi:'),
              SizedBox(height: 8),
              Text('Kelas: $selectedClass'),
              Text('Mata Pelajaran: $selectedSubject'),
              Text('Jam Pelajaran: ${selectedJamPelajaran ?? "-"}'),
              Text('Tanggal: $currentDate'),
              Text('Waktu: $currentTime'),
              Text('Jumlah Hadir: $checkedCount dari $totalStudents siswa'),
              if (checkedCount < totalStudents) ...[
                Text(
                  'Tidak Hadir: ${totalStudents - checkedCount} siswa',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmSaveAttendance();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 17, 82, 136),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmSaveAttendance() async {
    try {
      setState(() => isLoading = true);

      String currentTime = DateFormat('HH:mm').format(DateTime.now());

      Map<String, dynamic> attendanceData = {
        'date': DateFormat('yyyy-MM-dd').format(selectedDate),
        'time': currentTime,
        'subject': selectedSubject,
        'class': selectedClass,
        'jamPelajaran': selectedJamPelajaran ?? '',
        'totalStudents': siswaData[selectedClass]!.length,
        'presentCount': checkedCount,
        'students': siswaData[selectedClass]!.map((student) => {
          'id': student['id'],
          'name': student['name'],
          'present': student['checked'],
          'status': student['checked'] ? 'Hadir' : studentAbsenceStatus[student['id']] ?? 'Alpha',
          'note': student['note'] ?? '',
        }).toList(),
        'savedAt': DateTime.now().toString(),
        'tema': tema ?? '',
        'materi': materi ?? '',
        'rpp': rpp ?? '',
      };

      await _saveToHistory(attendanceData);
      _resetAttendance();
      
      setState(() {
        isLoading = false;
        attendanceSavedStatus[selectedClass!] = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Absensi berhasil disimpan!'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan absensi: ${e.toString()}'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveToHistory(Map<String, dynamic> attendanceData) async {
    if (_prefs == null) return;

    List<String> history = _prefs!.getStringList('attendance_history') ?? [];
    history.add(jsonEncode(attendanceData));
    await _prefs!.setStringList('attendance_history', history);
  }

  void _showCheckedStudents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AbsensiHistoryPage(),
      ),
    );
  }

  // Add new method to check today's attendance
  Future<bool> _hasAttendanceForToday() async {
    if (_prefs == null) return false;
    
    List<String> history = _prefs!.getStringList('attendance_history') ?? [];
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    for (String item in history) {
      final attendance = json.decode(item) as Map<String, dynamic>;
      if (attendance['date'] == today && 
          attendance['subject'] == selectedSubject &&
          attendance['class'] == selectedClass) {
        return true;
      }
    }
    return false;
  }

  // Store today's checked subjects per class
  Future<void> _markSubjectAsChecked() async {
    if (_prefs == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final key = '${today}_${selectedClass}_${selectedSubject}';
    await _prefs!.setBool(key, true);
  }

  // Check if subject is already checked today
  Future<bool> _isSubjectCheckedToday() async {
    if (_prefs == null) return false;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final key = '${today}_${selectedClass}_${selectedSubject}';
    return _prefs!.getBool(key) ?? false;
  }

  // Add method to clear today's checks (call this at midnight or app start)
  Future<void> _clearOldChecks() async {
    if (_prefs == null) return;
    
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final allKeys = _prefs!.getKeys();
    
    for (String key in allKeys) {
      if (key.startsWith('${today}_')) continue;  // Keep today's records
      if (key.contains('_')) {  // Only remove our attendance check keys
        await _prefs!.remove(key);
      }
    }
  }

  double _getAppBarHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double statusBarHeight = mediaQuery.padding.top;
    final double screenHeight = mediaQuery.size.height;
    
    // Reduced height calculation
    final double responsiveHeight = screenHeight * 0.08; // Reduced from 0.1
    return statusBarHeight + responsiveHeight;
  }

  // Add these methods for responsive sizing
  double _getResponsiveIconSize(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * 0.05 > 30 ? 30 : screenWidth * 0.05 < 20 ? 20 : screenWidth * 0.05;
  }

  double _getResponsiveTextSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 400; // Base width
    return baseSize * (scaleFactor < 0.8 ? 0.8 : scaleFactor > 1.2 ? 1.2 : scaleFactor);
  }

  // Method to clear absence status for a student
  void _clearAbsenceStatus(String studentId) {
    setState(() {
      studentAbsenceStatus.remove(studentId);
      if (selectedClass != null) {
        final siswaList = siswaData[selectedClass!];
        if (siswaList != null) {
          for (var siswa in siswaList) {
            if (siswa['id'] == studentId) {
              siswa['note'] = null;
              break;
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          Container(
            height: 110,
            padding: EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Absensi Kelas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pilih kelas untuk mulai absensi',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AbsensiHistoryPage(),
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Riwayat',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          _buildDateTimeSubjectSelector(),
          SizedBox(height: 20),
          if (selectedClass != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Siswa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: attendanceSavedStatus[selectedClass!]! ? null : _toggleCheckAllStudents,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 19, 91, 155),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      _areAllChecked ? 'Batalkan Semua' : 'Centang Semua',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: siswaData[selectedClass]?.length ?? 0,
                itemBuilder: (context, index) {
                  var siswa = siswaData[selectedClass]![index];
                  return AnimatedListItem(
                    index: index,
                    controller: _controller,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: siswa['checked']
                            ? Colors.blue.shade50
                            : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: siswa['checked']
                                  ? Colors.blue.shade100
                                  : Colors.grey.shade100,
                              child: Text(
                                siswa['name'][0],
                                style: TextStyle(
                                  color: siswa['checked']
                                      ? Colors.blue.shade900
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ),
                            title: Text(
                              siswa['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: siswa['checked']
                                    ? Colors.blue.shade900
                                    : Colors.black87,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!siswa['checked']) ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: studentAbsenceStatus[siswa['id']],
                                          isDense: true, // Make the button more compact
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5, // Reduced vertical padding
                                            ),
                                            hintText: 'Pilih Status',
                                            hintStyle: TextStyle(fontSize: 13), // Smaller hint text
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: BorderSide(width: 1),
                                            ),
                                            constraints: BoxConstraints(
                                              maxHeight: 35, // Set maximum height
                                            ),
                                          ),
                                          items: absenceTypes.map((type) {
                                            return DropdownMenuItem(
                                              value: type,
                                              child: Text(
                                                type,
                                                style: TextStyle(fontSize: 13), // Smaller text
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (attendanceSavedStatus[selectedClass!] ?? false) ? null : (value) {
                                            setState(() {
                                              if (value != null) {
                                                studentAbsenceStatus[siswa['id']] = value;
                                                siswa['note'] = value;
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      if (studentAbsenceStatus[siswa['id']] != null && (attendanceSavedStatus[selectedClass!] ?? false) == false)
                                        IconButton(
                                          icon: Icon(Icons.clear, color: Colors.red),
                                          onPressed: () => _clearAbsenceStatus(siswa['id']),
                                        ),
                                    ],
                                  ),
                                ] 
                              ],
                            ),
                            trailing: Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: siswa['checked'],
                                onChanged: attendanceSavedStatus[selectedClass!]! ? null : (value) => _toggleCheck(index),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                activeColor: const Color.fromARGB(255, 17, 85, 153),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (!attendanceSavedStatus[selectedClass!]!) ...[
                    ElevatedButton(
                      onPressed: _saveAttendance,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        shadowColor: Colors.blue.shade200,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Simpan Absensi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (attendanceSavedStatus[selectedClass!]!) ...[
                    SizedBox(height: 16),
                    Column(
                      children: [
                        Text(
                          'Absensi untuk hari ini sudah diisi',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _showCheckedStudents,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 30, 111, 182),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.visibility, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Lihat Absensi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.class_outlined,
                      size: 50,
                      color: Colors.grey.shade700,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Pilih kelas terlebih dahulu',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}