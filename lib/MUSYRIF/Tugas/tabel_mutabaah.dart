import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TabelMutabaah extends StatefulWidget {
  final String session;
  final DateTime selectedDate;
  final String searchQuery;
  final Function(bool) onSaveComplete;

  const TabelMutabaah({
    Key? key,
    required this.session,
    required this.selectedDate,
    required this.searchQuery,
    required this.onSaveComplete,
  }) : super(key: key);

  @override
  TabelMutabaahState createState() => TabelMutabaahState();
}

class TabelMutabaahState extends State<TabelMutabaah> {
  final List<String> activities = [
    'Sholat Berjamaah',
    'Baca Al-Quran',
    'Puasa Sunnah',
    'Dzikir Pagi/Petang'
  ];

  Map<String, Map<String, bool>> santriActivities = {};
  SharedPreferences? _prefs;

  final List<String> santriList = [
    'Ahmad Abdullah',
    'Bilal Rahman',
    'Daffa Malik',
    'Ezzat Faisal',
    'Fahri Haidar',
    'Gibran Aziz',
    'Hamza Yusuf',
    'Ibrahim Khalil',
    'Jamal Hasan',
    'Karim Mahmud',
    'Luqman Hakim',
    'Muhammad Amin',
    'Nabil Rashid',
    'Omar Farooq',
    'Qasim Anwar',
    'Rashid Ahmad',
    'Saif Ali',
    'Tariq Ziad',
    'Umar Malik',
    'Zain Abbas'
  ];

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _initializeSantriActivities();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSavedData();
  }

  void _initializeSantriActivities() {
    for (String santri in santriList) {
      if (!santriActivities.containsKey(santri)) {
        santriActivities[santri] = {};
        for (String activity in activities) {
          santriActivities[santri]![activity] = false;
        }
      }
    }
  }

  Future<void> _loadSavedData() async {
    if (_prefs == null) return;

    String dateKey = widget.selectedDate.toString().split(' ')[0];
    String key = '${dateKey}_${widget.session}';
    
    String? savedData = _prefs!.getString(key);
    if (savedData != null) {
      final data = json.decode(savedData);
      setState(() {
        santriActivities = Map<String, Map<String, bool>>.from(
          data['activities'].map((key, value) => MapEntry(
            key.toString(),
            Map<String, bool>.from(value),
          )),
        );
      });
    } else {
      _initializeSantriActivities(); // Reset if no data found
    }
  }

  // Make sure saveMutabaahData is properly defined
  Future<void> saveMutabaahData() async {
    if (_prefs == null) return;

    String dateKey = widget.selectedDate.toString().split(' ')[0];
    String key = '${dateKey}_${widget.session}';

    Map<String, dynamic> mutabaahData = {
      'date': dateKey,
      'session': widget.session,
      'activities': santriActivities,
      'timestamp': DateTime.now().toString(),
      'santriList': santriList, // Add this to save the list of santri
    };

    // Save current session data
    await _prefs!.setString(key, json.encode(mutabaahData));

    // Update history list
    List<Map<String, dynamic>> history = 
      json.decode(_prefs!.getString('mutabaah_history') ?? '[]')
      .cast<Map<String, dynamic>>();

    // Remove existing entry for same date and session if exists
    history.removeWhere((item) => 
      item['date'] == dateKey && item['session'] == widget.session
    );

    // Add new entry
    history.add(mutabaahData);

    // Sort by date and session
    history.sort((a, b) {
      int dateCompare = DateTime.parse(b['date'])
          .compareTo(DateTime.parse(a['date']));
      if (dateCompare == 0) {
        return b['session'].compareTo(a['session']);
      }
      return dateCompare;
    });

    await _prefs!.setString('mutabaah_history', json.encode(history));
    widget.onSaveComplete(true);
  }

  @override
  Widget build(BuildContext context) {
    // Filter santri based on search query
    final filteredSantri = santriActivities.keys
        .where((santri) => santri.toLowerCase().contains(widget.searchQuery.toLowerCase()))
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFF2E3F7F)),
          columns: [
            DataColumn(
              label: Text('Nama Santri',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            ...activities.map((activity) => DataColumn(
                  label: Text(activity,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )),
          ],
          rows: filteredSantri.map((santri) {
            return DataRow(
              cells: [
                DataCell(Text(santri)),
                ...activities.map((activity) {
                  bool isChecked = santriActivities[santri]?[activity] ?? false;
                  return DataCell(
                    Center(
                      child: Checkbox(
                        value: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            santriActivities[santri]?[activity] = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF2E3F7F),
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
