import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AbsensiHistoryPage extends StatefulWidget {
  @override
  _AbsensiHistoryPageState createState() => _AbsensiHistoryPageState();
}

class _AbsensiHistoryPageState extends State<AbsensiHistoryPage> {
  DateTime? selectedDate;
  String? selectedClass;
  String? selectedSubject;
  List<Map<String, dynamic>> historyData = [];

  // Add lists for filters
  final List<String> subjects = [
    'Matematika',
    'Bahasa Indonesia',
    'IPA',
    'IPS',
    'Bahasa Inggris'
  ];
  List<String> classes = [];

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('attendance_history') ?? [];
    
    setState(() {
      historyData = history
        .map((item) => json.decode(item) as Map<String, dynamic>)
        .toList()
        ..sort((a, b) => DateTime.parse(b['date'])  // Sort by most recent
            .compareTo(DateTime.parse(a['date'])));
      
      // Extract unique classes from history
      classes = historyData
        .map((item) => item['class'].toString())
        .toSet()
        .toList()
        ..sort();
    });
  }

  List<Map<String, dynamic>> _getFilteredHistory() {
    return historyData.where((item) {
      final matchesDate = selectedDate == null || 
        item['date'] == DateFormat('yyyy-MM-dd').format(selectedDate!);
      final matchesClass = selectedClass == null || 
        item['class'] == selectedClass;
      final matchesSubject = selectedSubject == null || 
        item['subject'] == selectedSubject;
      return matchesDate && matchesClass && matchesSubject;
    }).toList();
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Date Filter
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                  icon: Icon(Icons.calendar_today),
                  label: Text(selectedDate == null 
                    ? 'Pilih Tanggal'
                    : DateFormat('dd/MM/yyyy').format(selectedDate!)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue[900],
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (selectedDate != null)
                IconButton(
                  onPressed: () => setState(() => selectedDate = null),
                  icon: Icon(Icons.clear),
                ),
            ],
          ),
          SizedBox(height: 12),
          // Class and Subject Filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedClass,
                  decoration: InputDecoration(
                    labelText: 'Filter Kelas',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Semua Kelas'),
                    ),
                    ...classes.map((kelas) => DropdownMenuItem(
                      value: kelas,
                      child: Text(kelas),
                    )).toList(),
                  ],
                  onChanged: (value) => setState(() => selectedClass = value),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedSubject,
                  decoration: InputDecoration(
                    labelText: 'Filter Mapel',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Semua Mapel'),
                    ),
                    ...subjects.map((subject) => DropdownMenuItem(
                      value: subject,
                      child: Text(subject),
                    )).toList(),
                  ],
                  onChanged: (value) => setState(() => selectedSubject = value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editStudentStatus(Map<String, dynamic> item, Map<String, dynamic> student) async {
    String? selectedStatus = student['status'] == 'Hadir' ? null : student['status'];
    String? note = student['note'];
    bool isEditing = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: const Color(0xFF2E3F7F)),
              SizedBox(width: 8),
              Text('Edit Status ${student['name']}'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelStyle: TextStyle(color: const Color(0xFF2E3F7F)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: const Color(0xFF2E3F7F)),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: null, child: Text('Hadir')),
                  ...['Alpha', 'Izin', 'Sakit'].map((type) => 
                    DropdownMenuItem(value: type, child: Text(type))
                  ),
                ],
                onChanged: (value) => setDialogState(() {
                  selectedStatus = value;
                  isEditing = true;
                }),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Keterangan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelStyle: TextStyle(color: const Color(0xFF2E3F7F)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: const Color(0xFF2E3F7F)),
                  ),
                ),
                controller: TextEditingController(text: note),
                onChanged: (value) {
                  note = value;
                  isEditing = true;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: isEditing ? () async {
                // Update student status
                student['present'] = selectedStatus == null;
                student['status'] = selectedStatus ?? 'Hadir';
                student['note'] = note ?? '';

                // Update presentCount
                item['presentCount'] = (item['students'] as List)
                    .where((s) => s['present'])
                    .length;

                await _updateHistory();
                Navigator.pop(context);
                setState(() {});

                // Show success message with custom SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status Berhasil Diperbarui',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Status: ${selectedStatus ?? "Hadir"}',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF2E3F7F),
                    duration: Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.all(10),
                  ),
                );
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E3F7F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.save),
                  SizedBox(width: 8),
                  Text('Simpan'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'attendance_history',
      historyData.map((item) => jsonEncode(item)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredHistory = _getFilteredHistory();
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, 
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Riwayat Absensi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Lihat riwayat kehadiran siswa',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildFilters(),
          Expanded(
            child: filteredHistory.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada data absensi',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: filteredHistory.length,
                  itemBuilder: (context, index) {
                    final item = filteredHistory[index];
                    final presentCount = item['presentCount'];
                    final totalStudents = item['totalStudents'];
                    final absentCount = totalStudents - presentCount;

                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          '${item['subject']} - ${item['class']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${item['date']} - ${item['time']}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Hadir ($presentCount dari $totalStudents Siswa)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(255, 31, 148, 35),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: const Color.fromARGB(255, 32, 79, 117)),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Ketuk nama siswa untuk mengedit status'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Divider(),
                                // Present students list
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: (item['students'] as List)
                                      .where((s) => s['present'])
                                      .length,
                                  itemBuilder: (context, idx) {
                                    final student = (item['students'] as List)
                                        .where((s) => s['present'])
                                        .toList()[idx];
                                    return ListTile(
                                      dense: true,
                                      title: Text(student['name']),
                                      onTap: () => _editStudentStatus(item, student),
                                    );
                                  },
                                ),
                                if (absentCount > 0) ...[
                                  Text(
                                    'Tidak Hadir ($absentCount Siswa)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  Divider(),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: (item['students'] as List)
                                        .where((s) => !s['present'])
                                        .length,
                                    itemBuilder: (context, idx) {
                                      final student = (item['students'] as List)
                                          .where((s) => !s['present'])
                                          .toList()[idx];
                                      return ListTile(
                                        dense: true,
                                        title: Text(student['name']),
                                        subtitle: Text(
                                          'Status: ${student["status"]}${student["note"].isNotEmpty ? '\nKeterangan: ${student["note"]}' : ''}',
                                          style: TextStyle(color: Colors.red.shade700),
                                        ),
                                        onTap: () => _editStudentStatus(item, student),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
