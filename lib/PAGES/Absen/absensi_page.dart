import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class AbsensiKelasPage extends StatefulWidget {
  const AbsensiKelasPage({super.key});

  @override
  _AbsensiKelasPageState createState() => _AbsensiKelasPageState();
}

class _AbsensiKelasPageState extends State<AbsensiKelasPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<String> kelasList = ['Kelas A', 'Kelas B', 'Kelas C', 'Kelas D'];
  final Map<String, List<Map<String, dynamic>>> siswaData = {
    'Kelas A': [
      {'name': 'Paul Walker', 'absen': '01', 'checked': false},
      {'name': 'John Doe', 'absen': '02', 'checked': false},
    ],
    'Kelas B': [
      {'name': 'Jane Doe', 'absen': '01', 'checked': false},
      {'name': 'Max Payne', 'absen': '02', 'checked': false},
    ],
    'Kelas C': [
      {'name': 'Alice Brown', 'absen': '01', 'checked': false},
      {'name': 'Bob Smith', 'absen': '02', 'checked': false},
    ],
    'Kelas D': [
      {'name': 'Charlie Green', 'absen': '01', 'checked': false},
      {'name': 'Emma White', 'absen': '02', 'checked': false},
    ],
  };

  final Map<String, bool> attendanceSavedStatus = {
    'Kelas A': false,
    'Kelas B': false,
    'Kelas C': false,
    'Kelas D': false,
  };

  String? selectedClass;
  int checkedCount = 0;
  int? selectedIndex;
  List<Map<String, dynamic>> savedAttendance = [];
  bool _areAllChecked = false;
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
                  backgroundColor: Colors.blue,
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
    if (savedAttendance.isNotEmpty || selectedClass != null) {
      List<Map<String, dynamic>> checkedStudents = savedAttendance;
      List<Map<String, dynamic>> uncheckedStudents = siswaData[selectedClass]!
          .where((siswa) => !siswa['checked'])
          .toList();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.people, color: Colors.blue.shade800),
              SizedBox(width: 8),
              Text('Siswa yang telah absen'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Hadir',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        itemCount: checkedStudents.length,
                        separatorBuilder: (context, index) => Divider(height: 1),
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                checkedStudents[index]['name'][0],
                                style: TextStyle(color: Colors.blue.shade800),
                              ),
                            ),
                            title: Text(
                              checkedStudents[index]['name'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Absen: ${checkedStudents[index]['absen']} - ${checkedStudents[index]['date']}',
                                  style: TextStyle(fontSize: 12),
                                ),
                                if (checkedStudents[index]['note'] != null)
                                  Text(
                                    'Keterangan: ${checkedStudents[index]['note']}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Tidak Hadir',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        itemCount: uncheckedStudents.length,
                        separatorBuilder: (context, index) => Divider(height: 1),
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.shade100,
                              child: Text(
                                uncheckedStudents[index]['name'][0],
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ),
                            title: Text(
                              uncheckedStudents[index]['name'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Absen: ${uncheckedStudents[index]['absen']}',
                                  style: TextStyle(fontSize: 12),
                                ),
                                if (uncheckedStudents[index]['note'] != null)
                                  Text(
                                    'Keterangan: ${uncheckedStudents[index]['note']}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
            ),
          ),
          actions: [
            TextButton.icon(
              icon: Icon(Icons.close),
              label: Text('Tutup'),
              onPressed: () => Navigator.pop(context),
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
                      margin:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                checkedCount ==
                                        (siswaData[selectedClass]?.length ??
                                            0)
                                    ? 'Hadir Semua ✓'
                                    : 'Hadir: $checkedCount',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
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
                        backgroundColor: Colors.blue.shade600,
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
                    return AnimatedContainer(
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
                            activeColor: Colors.blue.shade700,
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