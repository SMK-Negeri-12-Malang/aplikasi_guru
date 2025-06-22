import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RekapHarian extends StatefulWidget {
  const RekapHarian({super.key});

  @override
  State<RekapHarian> createState() => _RekapHarianState();
}

class _RekapHarianState extends State<RekapHarian> {
  final List<String> sessions = ["Pagi",  "Sore", "Malam"];
  final List<String> activities = [
    "Sholat Berjamaah",
    "Baca Al-Quran",
    "Puasa Sunnah",
    "Dzikir Pagi/Petang"
  ];
  List<String> santriList = [
    "Ahmad",
    "Ali",
    "Fatimah",
    "Zaid",
    "Hamzah",
    "Bilal"
  ];

  DateTime selectedDate = DateTime.now();
  String? selectedSession;
  String searchQuery = "";

  // Simulated data structure for checklist
  Map<String, Map<String, Map<String, bool>>> checklistData = {};

  Future<void> _loadHistoryData() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (selectedSession != null) {
      String dateKey = selectedDate.toString().split(' ')[0];
      String key = '${dateKey}_$selectedSession';
      
      // Load specific session data
      String? sessionData = prefs.getString(key);
      
      if (sessionData != null) {
        final data = json.decode(sessionData);
        setState(() {
          // Update santri list from saved data
          santriList = List<String>.from(data['santriList'] ?? []);
          
          // Update activities data
          checklistData = {};
          final activities = data['activities'] as Map<String, dynamic>;
          
          activities.forEach((santri, value) {
            if (!checklistData.containsKey(santri)) {
              checklistData[santri] = {};
            }
            checklistData[santri]![selectedSession!] = 
              Map<String, bool>.from(value as Map);
          });
        });
      } else {
        setState(() {
          checklistData = {};
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  @override
  Widget build(BuildContext context) {
    // Filter santri list based on search query
    final filteredSantriList = santriList.where((santri) =>
      santri.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: Container(
          padding: EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
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
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Riwayat Mutabaah",
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
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
                // Add search field
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: "Cari Nama Santri",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                selectedDate = date;
                                _loadHistoryData();
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFF2E3F7F)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('dd/MM/yyyy').format(selectedDate),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF2E3F7F),
                                  ),
                                ),
                                Icon(Icons.calendar_today, 
                                  color: Color(0xFF2E3F7F),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedSession,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF2E3F7F)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF2E3F7F)),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          hint: Text("Pilih Sesi"),
                          items: sessions.map((session) => 
                            DropdownMenuItem(
                              value: session,
                              child: Text(session),
                            )
                          ).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedSession = value;
                              _loadHistoryData();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: selectedSession == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Pilih sesi untuk melihat data',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : checklistData.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada data untuk sesi ini',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : Card(
                    margin: EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            Color(0xFF2E3F7F),
                          ),
                          columnSpacing: 20,
                          horizontalMargin: 20,
                          columns: [
                            DataColumn(
                              label: Text('Santri',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            ...activities.map((activity) => DataColumn(
                                  label: Text(activity,
                                      style: TextStyle(color: Colors.white)),
                                )),
                          ],
                          rows: filteredSantriList.map((santri) {
                            final sessionData = selectedSession != null
                                ? checklistData[santri]![selectedSession!]
                                : null;

                            return DataRow(
                              cells: [
                                DataCell(Text(santri)),
                                ...activities.map((activity) => DataCell(
                                      Center(
                                        child: Icon(
                                          sessionData?[activity] == true
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: sessionData?[activity] == true
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    )),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
