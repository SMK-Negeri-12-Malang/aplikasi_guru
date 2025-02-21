import 'package:aplikasi_ortu/utils/animations.dart';
import 'package:aplikasi_ortu/utils/widgets/animated_list_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  bool _isEditing = false;

  late PageController _categoryPageController;
  int _currentCategoryPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _categoryPageController = PageController(viewportFraction: 0.85);
    _controller.forward();
    _fetchData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _categoryPageController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse('https://67ac42f05853dfff53d9e093.mockapi.io/siswa')
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        
        // Get unique class names
        Set<String> classes = {};
        for (var student in data) {
          if (student['kelas'] != null) {
            classes.add(student['kelas'].toString());
          }
        }
        
        // Initialize data structures
        Map<String, List<Map<String, dynamic>>> groupedStudents = {};
        Map<String, bool> savedStatus = {};
        
        // Group students by class
        for (String className in classes) {
          groupedStudents[className] = [];
          savedStatus[className] = false;
          
          // Add students to their respective classes
          for (var student in data) {
            if (student['kelas'] == className) {
              groupedStudents[className]!.add({
                'name': student['name'],
                'id': student['id'],
                'absen': student['id'].toString().padLeft(2, '0'),
                'checked': false,
                'kelas': student['kelas'],
              });
            }
          }
        }
        
        setState(() {
          kelasList = classes.toList()..sort();
          siswaData = groupedStudents;
          attendanceSavedStatus = savedStatus;
          isLoading = false;
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

  void _saveAttendance() {
    if (selectedClass != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text('Konfirmasi Simpan Absensi'),
            content: Text('Apakah Anda yakin ingin menyimpan absensi?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _confirmSaveAttendance();
                },
                child: Text('Simpan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 17, 82, 136),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void _confirmSaveAttendance() {
    HapticFeedback.mediumImpact();
    setState(() {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
      for (var siswa in siswaData[selectedClass]!) {
        if (siswa['checked']) {
          savedAttendance.add({
            'name': siswa['name'],
            'absen': siswa['absen'],
            'date': formattedDate,
          });
        }
      }
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
  }

  void _showCheckedStudents() {
    if (selectedClass != null) {
      List<Map<String, dynamic>> checkedStudents = siswaData[selectedClass]!
          .where((siswa) => siswa['checked'])
          .toList();
      List<Map<String, dynamic>> uncheckedStudents = siswaData[selectedClass]!
          .where((siswa) => !siswa['checked'])
          .toList();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.people, color: const Color.fromARGB(255, 13, 65, 124)),
              SizedBox(width: 8),
              Text('Daftar Kehadiran'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (checkedStudents.isNotEmpty) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'Hadir (${checkedStudents.length})',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: checkedStudents.length,
                            itemBuilder: (context, index) {
                              final student = checkedStudents[index];
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.green.shade100,
                                      radius: 20,
                                      child: Text(
                                        student['name'][0],
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student['name'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (student['note'] != null && student['note'].isNotEmpty)
                                            Text(
                                              'Ket: ${student['note']}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  if (uncheckedStudents.isNotEmpty) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.cancel, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Tidak Hadir (${uncheckedStudents.length})',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: uncheckedStudents.length,
                            itemBuilder: (context, index) {
                              final student = uncheckedStudents[index];
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.red.shade100,
                                      radius: 20,
                                      child: Text(
                                        student['name'][0],
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student['name'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (student['note'] != null && student['note'].isNotEmpty)
                                            Text(
                                              'Ket: ${student['note']}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup'),
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 16, 72, 129),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Widget _buildClassSelector() {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.15,
          child: PageView.builder(
            controller: _categoryPageController,
            itemCount: kelasList.length,
            onPageChanged: (index) {
              setState(() {
                _currentCategoryPage = index;
                selectedClass = kelasList[index];
                selectedIndex = index;
                checkedCount = siswaData[selectedClass]!
                    .where((siswa) => siswa['checked'])
                    .length;
              });
            },
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _categoryPageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_categoryPageController.position.haveDimensions) {
                    value = _categoryPageController.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.85, 1.0);
                  }
                  return Transform.scale(
                    scale: value,
                    child: _buildClassCard(index),
                  );
                },
              );
            },
          ),
        ),
        // Dot indicators moved below
        SizedBox(height: 16), // Space between card and indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            kelasList.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentCategoryPage == index
                    ? Colors.blue.shade700
                    : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassCard(int index) {
    String kelas = kelasList[index];
    bool isSelected = selectedIndex == index;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.5),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isSelected ? Colors.blue.shade300 : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.class_,
            color: isSelected ? Colors.blue.shade900 : Colors.blue.shade300,
            size: 28,
          ),
          SizedBox(height: 8),
          Text(
            kelas,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.blue.shade900 : Colors.blue.shade300,
            ),
          ),
          if (selectedClass == kelas)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              margin: EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                checkedCount == (siswaData[selectedClass]?.length ?? 0)
                    ? 'Hadir Semua ✓'
                    : 'Hadir: $checkedCount',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: isLoading
            ? AppAnimations.shimmerLoading(
                isLoading: true,
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppAnimations.fadeSlideIn(
              animation: _controller,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 22),
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
                      color: const Color.fromARGB(255, 10, 55, 122).withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Absensi Kelas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pilih kelas untuk mulai absensi',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 120,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: kelasList.length,
                itemBuilder: (context, index) {
                  String kelas = kelasList[index];
                  bool isSelected = selectedIndex == index;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        selectedClass = kelas;
                        selectedIndex = index;
                        checkedCount = siswaData[selectedClass]!
                            .where((siswa) => siswa['checked'])
                            .length;
                      });
                    },
                    child: AnimatedListItem(
                      index: index,
                      controller: _controller,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: MediaQuery.of(context).size.width * 0.7,
                        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.blue.shade100,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ]
                              : [],
                          border: Border.all(
                            color: isSelected
                                ? const Color.fromARGB(255, 18, 69, 110)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.class_,
                                  color: isSelected
                                      ? const Color.fromARGB(255, 18, 91, 199)
                                      : const Color.fromARGB(255, 78, 171, 247),
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  kelas,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.blue.shade900
                                        : Colors.blue.shade300,
                                  ),
                                ),
                              ],
                            ),
                            if (selectedClass == kelas) ...[
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  checkedCount == (siswaData[selectedClass]?.length ?? 0)
                                      ? 'Hadir Semua ✓'
                                      : 'Hadir: $checkedCount',
                                  style: TextStyle(
                                    color: const Color.fromARGB(255, 12, 71, 129),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
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
                        child: ListTile(
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
                          subtitle: _isEditing
                              ? TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Tambahkan keterangan',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      siswa['note'] = value;
                                    });
                                  },
                                )
                              : Text(
                                  siswa['note'] ?? '',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                          trailing: Transform.scale(
                            scale: 1.2,
                            child: Checkbox(
                              value: siswa['checked'],
                              onChanged: attendanceSavedStatus[selectedClass!]! && !_isEditing ? null : (value) => _toggleCheck(index),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              activeColor: const Color.fromARGB(255, 17, 85, 153),
                            ),
                          ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _showCheckedStudents,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              shadowColor: Colors.blue.shade200,
                            ),
                            child: Row(
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
                          ElevatedButton(
                            onPressed: _toggleEditing,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade600,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              shadowColor: Colors.orange.shade200,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  _isEditing ? 'Selesai Edit' : 'Edit Absensi',
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
                        color: const Color.fromARGB(255, 255, 255, 255),
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
      ),
    );
  }
}