import 'package:aplikasi_ortu/MUSYRIF/Absen/detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AbsensiPageKamar extends StatefulWidget {
  const AbsensiPageKamar({super.key});

  @override
  _AbsensiKelasPageState createState() => _AbsensiKelasPageState();
}

class _AbsensiKelasPageState extends State<AbsensiPageKamar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<String> kelasList = ['Kamar A', 'Kamar B', 'Kamar C', 'Kamar D'];
  final Map<String, List<Map<String, dynamic>>> siswaData = {
    'Kamar A': [
      {'name': 'Laporan', 'absen': '01', 'checked': false},
      {'name': 'Izin', 'absen': '02', 'checked': false},
      {'name': 'Sakit', 'absen': '03', 'checked': false},
    ],
    'Kamar B': [
      {'name': 'Laporan', 'absen': '01', 'checked': false},
      {'name': 'Izin', 'absen': '02', 'checked': false},
      {'name': 'Sakit', 'absen': '03', 'checked': false},
    ],
    'Kamar C': [
      {'name': 'Laporan', 'absen': '01', 'checked': false},
      {'name': 'Izin', 'absen': '02', 'checked': false},
      {'name': 'Sakit', 'absen': '03', 'checked': false},
    ],
    'Kamar D': [
      {'name': 'Laporan', 'absen': '01', 'checked': false},
      {'name': 'Izin', 'absen': '02', 'checked': false},
      {'name': 'Sakit', 'absen': '03', 'checked': false},
    ],
  };

  final Map<String, bool> attendanceSavedStatus = {
    'Kamar A': false,
    'Kamar B': false,
    'Kamar C': false,
    'Kamar D': false,
  };

  String? selectedClass;
  int checkedCount = 0;
  int? selectedIndex;
  List<Map<String, dynamic>> savedAttendance = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }







  void _navigateToDetail(Map<String, dynamic> siswa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AbsenDetailPage(
          siswa: siswa,
          kelas: selectedClass!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: FadeTransition(
        opacity: _animation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade900.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              ? Colors.blue.shade300
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
                                    ? Colors.blue.shade900
                                    : Colors.blue.shade300,
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
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            if (selectedClass != null) ...[
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: siswaData[selectedClass]?.length ?? 0,
                  itemBuilder: (context, index) {
                    var siswa = siswaData[selectedClass]![index];
                    return GestureDetector(
                      onTap: () => _navigateToDetail(siswa),
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
                        ),
                      ),
                    );
                  },
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