import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RekapAbsensiPage extends StatefulWidget {
  final List<Map<String, dynamic>> dataSantri;
  const RekapAbsensiPage({super.key, required this.dataSantri});

  @override
  State<RekapAbsensiPage> createState() => _RekapAbsensiPageState();
}

class _RekapAbsensiPageState extends State<RekapAbsensiPage> {
  // Replace date range variables with single date
  DateTime? selectedDate;
  String? selectedClass;
  String? selectedSubject;
  List<Map<String, dynamic>> filteredData = [];

  String? selectedCategory;
  String? selectedSesi;
  String? selectedHalaqoh;
  String? selectedUstadz; // Add this variable

  final List<String> categories = ['Tahfidz', 'Tahsin'];
  final List<String> sesiList = ['Pagi', 'Siang', 'Malam'];
  final Map<String, String> halaqohToUstadz = {
    'Halaqoh 1': 'Ust. Ahmad',
    'Halaqoh 2': 'Ust. Muhammad',
    'Halaqoh 3': 'Ust. Abdullah',
    'Halaqoh 4': 'Ust. Ibrahim',
  };

  @override
  void initState() {
    super.initState();
    filteredData = widget.dataSantri;
  }

  Widget _buildFilters() {
    return SingleChildScrollView( // Add this wrapper
      child: Container(
        padding: EdgeInsets.all(12), // Reduced padding
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
            // Category and Date in same row with adjusted sizing
            Row(
              children: [
                Flexible( // Changed from Expanded to Flexible
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Pilih Kategori',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: [
                      DropdownMenuItem(value: null, child: Text('Semua Kategori')),
                      ...categories
                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                        selectedSesi = null;
                        selectedHalaqoh = null;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                Flexible( // Changed from Expanded to Flexible
                  child: DropdownButtonFormField<DateTime>(
                    value: selectedDate,
                    decoration: InputDecoration(
                      labelText: 'Pilih Tanggal',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: selectedDate != null
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  selectedDate = null;
                                  _applyFilters();
                                });
                              },
                            )
                          : Icon(Icons.calendar_today),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: selectedDate,
                        child: Text(
                          selectedDate == null
                              ? 'Pilih Tanggal'
                              : DateFormat('dd/MM/yyyy').format(selectedDate!),
                        ),
                      ),
                    ],
                    onChanged: (value) async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                          _applyFilters();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Conditional Sesi and Halaqoh Filters
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
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [
                        DropdownMenuItem(value: null, child: Text('Semua Sesi')),
                        ...sesiList
                            .map((sesi) => DropdownMenuItem(value: sesi, child: Text(sesi)))
                            .toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedSesi = value;
                          _applyFilters();
                        });
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
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [
                        DropdownMenuItem(value: null, child: Text('Semua Halaqoh')),
                        ...halaqohToUstadz.keys
                            .map((halaqoh) => DropdownMenuItem(value: halaqoh, child: Text(halaqoh)))
                            .toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedHalaqoh = value;
                          selectedUstadz = value != null ? halaqohToUstadz[value] : null;
                          _applyFilters();
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (selectedHalaqoh != null && selectedUstadz != null)
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

            // Update Halaqoh dropdown for Tahsin
            if (selectedCategory == 'Tahsin')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedHalaqoh,
                    decoration: InputDecoration(
                      labelText: 'Pilih Halaqoh',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: [
                      DropdownMenuItem(value: null, child: Text('Semua Halaqoh')),
                      ...halaqohToUstadz.keys
                          .map((halaqoh) => DropdownMenuItem(value: halaqoh, child: Text(halaqoh)))
                          .toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedHalaqoh = value;
                        selectedUstadz = value != null ? halaqohToUstadz[value] : null;
                        _applyFilters();
                      });
                    },
                  ),
                  if (selectedHalaqoh != null && selectedUstadz != null)
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
              ),

            // Clear Filters Button
            if (selectedDate != null ||
                selectedCategory != null ||
                selectedSesi != null ||
                selectedHalaqoh != null)
              Padding(
                padding: EdgeInsets.only(top: 12),
              ),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      filteredData = widget.dataSantri.where((data) {
        final date = DateTime.parse(data['date']);

        // Update date filter logic for single date
        bool matchesDate = selectedDate == null ||
            DateFormat('yyyy-MM-dd').format(date) ==
            DateFormat('yyyy-MM-dd').format(selectedDate!);

        bool matchesCategory = selectedCategory == null ||
            data['category'] == selectedCategory;

        bool matchesSesi = selectedSesi == null ||
            data['sesi'] == selectedSesi;

        bool matchesHalaqoh = selectedHalaqoh == null ||
            data['halaqoh'] == selectedHalaqoh;

        return matchesDate && matchesCategory && matchesSesi && matchesHalaqoh;
      }).toList();

      // Sort by date descending
      filteredData.sort((a, b) =>
          DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    });
  }

  @override
  Widget build(BuildContext context) {
    final hadir = filteredData.where((s) => s['isPresent']).toList();
    final tidakHadir = filteredData.where((s) => !s['isPresent']).toList();
    bool showData = selectedCategory != null || selectedDate != null;

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
                          'Lihat riwayat kehadiran santri',
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
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: _buildFilters(),
          ),
          Expanded(
            child: !showData 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Pilih filter untuk melihat data absensi',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Summary Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              "Hadir",
                              hadir.length,
                              Colors.white,
                              Colors.green.shade700,
                              Icons.check_circle_outline,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard( 
                              "Tidak Hadir",
                              tidakHadir.length,
                              Colors.white,
                              Colors.red.shade700,
                              Icons.cancel_outlined,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      
                      // Attendance Lists
                      if (hadir.isNotEmpty) ...[
                        _buildAttendanceSection(
                          "Santri Hadir",
                          hadir,
                          Colors.green.shade700,
                          true,
                        ),
                        SizedBox(height: 20),
                      ],
                      
                      if (tidakHadir.isNotEmpty)
                        _buildAttendanceSection(
                          "Santri Tidak Hadir",
                          tidakHadir,
                          Colors.red.shade700,
                          false,
                        ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, int count, Color bgColor, Color textColor, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withOpacity(0.3)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor.withOpacity(0.5),
            bgColor.withOpacity(0.2),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: textColor,
              size: 14, // Further reduced icon size
            ),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  color: textColor,
                  fontSize: 16, // Reduced font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: textColor.withOpacity(0.8),
                  fontSize: 11, // Reduced font size
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection(String title, List<Map<String, dynamic>> data, Color color, bool isPresent) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12), // Reduced padding
            child: Row(
              children: [
                Icon(
                  isPresent ? Icons.check_circle : Icons.cancel,
                  color: color,
                  size: 16, // Reduced icon size
                ),
                SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14, // Reduced font size
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          ...data.map((s) => Column(
            children: [
              ListTile(
                dense: true, // Makes ListTile more compact
                visualDensity: VisualDensity(vertical: -4), // Further reduces height
                title: Text(
                  s['name'],
                  style: TextStyle(
                    fontSize: 13, // Reduced font size
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: isPresent
                  ? Icon(Icons.check_circle, color: Colors.green, size: 16)
                  : Icon(Icons.cancel, color: Colors.red, size: 16),
              ),
              Divider(height: 1),
            ],
          )).toList(),
        ],
      ),
    );
  }
}
