import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_guru/SERVICE/Service_Musyrif/data_siswa.dart';
import 'package:intl/intl.dart';
import 'package:aplikasi_guru/GURU_QURAN/Absensi/rekap_absensi_page.dart';
import 'package:aplikasi_guru/ANIMASI/animations.dart';
import 'package:aplikasi_guru/ANIMASI/widgets/animated_list_item.dart';

class AbsensiPage extends StatefulWidget {//
  const AbsensiPage({Key? key}) : super(key: key);

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Map<String, dynamic>> siswaList = [];
  Map<String, bool> absensiData = {}; // Data Absensi untuk setiap santri

  DateTime selectedDate = DateTime.now();
  String? selectedCategory;
  String? selectedSesi;
  String? selectedHalaqoh;
  String? selectedUstadz;

  final List<String> categories = ['Tahfidz', 'Tahsin'];
  final List<String> sesiList = ['Pagi', 'Siang', 'Malam'];

  // Mapping halaqoh to ustadz
  final Map<String, String> halaqohToUstadz = {
    'Halaqoh 1': 'Ust. Ahmad',
    'Halaqoh 2': 'Ust. Muhammad',
    'Halaqoh 3': 'Ust. Abdullah',
    'Halaqoh 4': 'Ust. Ibrahim',
    // Add more halaqoh-ustadz mappings
  };

  // Add new variables for absence types
  final List<String> absenceTypes = ['Alpha', 'Izin', 'Sakit'];
  Map<String, String> studentAbsenceStatus = {};

  bool _areAllChecked = false; // Add this variable

  // Search and filter variables
  String searchNama = '';
  final _namaController = TextEditingController();

  // Dropdown options (ambil dari data siswa)
  List<String> kelasOptions = [];
  List<String> halaqohOptions = [];
  List<String> ustadzOptions = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _controller.forward();
    siswaList = DataSiswa.getMockSiswa();
    _initDropdownOptions();
    // Remove _loadAbsensi() call since we don't want to auto-load previous checks
  }

  void _initDropdownOptions() {
    final kelasSet = <String>{};
    final halaqohSet = <String>{};
    final ustadzSet = <String>{};
    for (var s in siswaList) {
      if (s['kelas'] != null && s['kelas'].toString().trim().isNotEmpty) kelasSet.add(s['kelas']);
      if (s['halaqoh'] != null && s['halaqoh'].toString().trim().isNotEmpty) halaqohSet.add(s['halaqoh']);
      if (s['penanggungJawab'] != null && s['penanggungJawab'].toString().trim().isNotEmpty) ustadzSet.add(s['penanggungJawab']);
    }
    kelasOptions = kelasSet.toList()..sort();
    halaqohOptions = halaqohSet.toList()..sort();
    ustadzOptions = ustadzSet.toList()..sort();
  }

  // Mengambil data absensi yang sudah ada sebelumnya
  Future<void> _loadAbsensi() async {
    final prefs = await SharedPreferences.getInstance();
    final absensiJson = prefs.getString('attendanceData');
    if (absensiJson != null) {
      List<dynamic> data = json.decode(absensiJson);
      final absensi = {
        for (var siswa in data) siswa['id']: siswa['isPresent'] ?? false
      };
      setState(() {
        absensiData = absensi.cast<String, bool>();
      });
    }
  }

  // Update toggle check method to be more explicit
  void _toggleCheckAll() {
    setState(() {
      _areAllChecked = !_areAllChecked;
      // Clear all existing checks first
      absensiData.clear();
      if (_areAllChecked) {
        // Only set checks if explicitly choosing "Pilih Semua"
        for (var siswa in siswaList) {
          absensiData[siswa['id']] = true;
        }
      }
    });
  }

  // Update individual check method
  Future<void> _updateAbsensi(String id, bool isChecked) async {
    setState(() {
      absensiData[id] = isChecked;
      // Update _areAllChecked based on current state
      _areAllChecked = siswaList.every((siswa) => absensiData[siswa['id']] == true);
    });
  }

  List<Map<String, dynamic>> attendanceHistory = [];

  Future<void> _saveAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Create attendance record
    List<Map<String, dynamic>> todayAttendance = siswaList.map((siswa) {
      final idSantri = siswa['id'];
      return {
        'id': idSantri,
        'name': siswa['name'],
        'kelas': siswa['kelas'],
        'isPresent': absensiData[idSantri] ?? false,
        'date': DateTime.now().toIso8601String(),
        'category': selectedCategory,
        'sesi': selectedSesi,
        'halaqoh': selectedHalaqoh,
        'ustadz': selectedUstadz,
      };
    }).toList();

    // Get existing history or initialize empty list
    String? historyJson = prefs.getString('attendanceHistory');
    if (historyJson != null) {
      attendanceHistory = List<Map<String, dynamic>>.from(
        json.decode(historyJson).map((x) => Map<String, dynamic>.from(x))
      );
    }

    // Add new attendance
    attendanceHistory.addAll(todayAttendance);
    
    // Save updated history
    await prefs.setString('attendanceHistory', json.encode(attendanceHistory));

    // Clear all checkboxes after saving
    setState(() {
      absensiData.clear();
      studentAbsenceStatus.clear();
      siswaList.forEach((siswa) {
        siswa['note'] = null;
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Absensi berhasil disimpan'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Add method to clear absence status
  void _clearAbsenceStatus(String studentId) {
    setState(() {
      studentAbsenceStatus.remove(studentId);
      // Clear note for student
      final siswa = siswaList.firstWhere((s) => s['id'] == studentId, orElse: () => {});
      if (siswa.isNotEmpty) {
        siswa['note'] = null;
      }
    });
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          // Category Dropdown (Tahfidz/Tahsin)
          DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: InputDecoration(
              labelText: 'Pilih Kategori',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: categories.map((category) => 
              DropdownMenuItem(value: category, child: Text(category))
            ).toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
                // Reset other selections
                selectedSesi = null;
                selectedHalaqoh = null;
                selectedUstadz = null;
              });
            },
          ),
          SizedBox(height: 12),

          // Conditional filters based on category
          if (selectedCategory != null) ...[
            // For Tahfidz, show both Sesi and Halaqoh
            if (selectedCategory == 'Tahfidz') ...[
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedSesi,
                      decoration: InputDecoration(
                        labelText: 'Pilih Sesi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: sesiList.map((sesi) => 
                        DropdownMenuItem(value: sesi, child: Text(sesi))
                      ).toList(),
                      onChanged: (value) {
                        setState(() => selectedSesi = value);
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedHalaqoh,
                      decoration: InputDecoration(
                        labelText: 'Pilih Halaqoh',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: halaqohToUstadz.keys.map((halaqoh) => 
                        DropdownMenuItem(value: halaqoh, child: Text(halaqoh))
                      ).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedHalaqoh = value;
                          selectedUstadz = halaqohToUstadz[value];
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (selectedUstadz != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Ustadz: $selectedUstadz',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3F7F),
                    ),
                  ),
                ),
            ],
            
            // For Tahsin, show only Halaqoh
            if (selectedCategory == 'Tahsin')
              DropdownButtonFormField<String>(
                value: selectedHalaqoh,
                decoration: InputDecoration(
                  labelText: 'Pilih Halaqoh',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: halaqohToUstadz.keys.map((halaqoh) => 
                  DropdownMenuItem(value: halaqoh, child: Text(halaqoh))
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedHalaqoh = value;
                    selectedUstadz = halaqohToUstadz[value];
                  });
                },
              ),
          ],
        ],
      ),
    );
  }

  void _resetFilter() {
    setState(() {
      selectedCategory = null;
      selectedSesi = null;
      selectedHalaqoh = null;
      selectedUstadz = null;
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: categories
                        .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedCategory = val;
                        selectedSesi = null;
                        selectedHalaqoh = null;
                        selectedUstadz = null;
                      });
                      setModalState(() {}); // update modal
                    },
                    isExpanded: true,
                  ),
                  const SizedBox(height: 12),
                  if (selectedCategory == 'Tahfidz')
                    DropdownButtonFormField<String>(
                      value: selectedSesi,
                      decoration: InputDecoration(
                        labelText: 'Sesi',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: sesiList
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedSesi = val;
                        });
                        setModalState(() {});
                      },
                      isExpanded: true,
                    ),
                  if (selectedCategory != null) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedHalaqoh,
                      decoration: InputDecoration(
                        labelText: 'Halaqoh',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: halaqohOptions
                          .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedHalaqoh = val;
                          // Otomatis pilih ustadz jika hanya satu ustadz di halaqoh tsb
                          if (val != null) {
                            final ustadzSet = siswaList
                                .where((s) => s['halaqoh'] == val)
                                .map((s) => s['penanggungJawab']?.toString() ?? '')
                                .toSet();
                            if (ustadzSet.length == 1) {
                              selectedUstadz = ustadzSet.first;
                            }
                          }
                        });
                        setModalState(() {});
                      },
                      isExpanded: true,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedUstadz,
                      decoration: InputDecoration(
                        labelText: 'Penanggung Jawab',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: ustadzOptions
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedUstadz = val;
                        });
                        setModalState(() {});
                      },
                      isExpanded: true,
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _resetFilter();
                            Navigator.pop(context);
                          },
                          child: Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2E3F7F),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {});
                            Navigator.pop(context);
                          },
                          child: Text('Terapkan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> get filteredSiswaList {
    return siswaList.where((siswa) {
      final matchesNama = searchNama.isEmpty ||
          (siswa['name']?.toString().toLowerCase().contains(searchNama.toLowerCase()) ?? false);
      final matchesCategory = selectedCategory == null ||
          (selectedCategory == 'Tahfidz' && siswa['category'] == 'Tahfidz') ||
          (selectedCategory == 'Tahsin' && siswa['category'] == 'Tahsin');
      final matchesSesi = selectedSesi == null || siswa['sesi'] == selectedSesi;
      final matchesHalaqoh = selectedHalaqoh == null || siswa['halaqoh'] == selectedHalaqoh;
      final matchesUstadz = selectedUstadz == null || siswa['penanggungJawab'] == selectedUstadz;
      return matchesNama && matchesCategory && matchesSesi && matchesHalaqoh && matchesUstadz;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            height: 110,
            width: double.infinity,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Absensi Santri',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pilih halaqoh untuk mulai absensi',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          // Shopee-style search bar + filter icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _namaController,
                    decoration: InputDecoration(
                      hintText: 'Cari Nama',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                    ),
                    onChanged: (val) {
                      setState(() {
                        searchNama = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _showFilterSheet,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(Icons.filter_alt, color: Color(0xFF2E3F7F)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Santri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                ElevatedButton(
                  onPressed: _toggleCheckAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E3F7F),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_areAllChecked ? Icons.close : Icons.check, size: 20),
                      SizedBox(width: 4),
                      Text(
                        _areAllChecked ? 'Batal Semua' : 'Pilih Semua',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSiswaList.length,
              padding: EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final siswa = filteredSiswaList[index];
                final id = siswa['id'];
                return AnimatedListItem(
                  index: index,
                  controller: _controller,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: absensiData[id] == true ? Colors.blue.shade50 : Colors.white,
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
                        backgroundColor: absensiData[id] == true
                            ? Colors.blue.shade100
                            : Colors.grey.shade100,
                        child: Text(
                          siswa['name'][0],
                          style: TextStyle(
                            color: absensiData[id] == true
                                ? Colors.blue.shade900
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      title: Text(
                        siswa['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: absensiData[id] == true
                              ? Colors.blue.shade900
                              : Colors.black87,
                        ),
                      ),
                      trailing: Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: absensiData[id] ?? false,
                          onChanged: (value) => _updateAbsensi(id, value!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          activeColor: const Color(0xFF2E3F7F),
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
            child: Row(
              children: [
                // Riwayat Absen Button (3/4 width)
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final historyJson = prefs.getString('attendanceHistory');
                      final attendanceData = historyJson != null 
                        ? List<Map<String, dynamic>>.from(
                            json.decode(historyJson).map((x) => Map<String, dynamic>.from(x))
                          )
                        : <Map<String, dynamic>>[];
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RekapAbsensiPage(
                            dataSantri: attendanceData,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 14, 94, 163),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Rikap Absensi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // Simpan Button (1/4 width)
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: selectedCategory != null && selectedHalaqoh != null 
                      ? _saveAttendance 
                      : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: Colors.green.shade200,
                    ),
                    child: Icon(Icons.save_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
