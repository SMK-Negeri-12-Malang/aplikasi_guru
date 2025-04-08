import 'package:aplikasi_guru/GURU_QURAN/Home/Galeri/galeri.dart';
import 'package:aplikasi_guru/GURU_QURAN/Home/Berita/berita.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_guru/GURU_QURAN/Home/Tabel_Santri/santri_table.dart';
import 'package:aplikasi_guru/MODELS/models/santri_data.dart' as models;

class HomeQuran extends StatefulWidget {
  final String? name;
  final String? email;
  
  const HomeQuran({
    super.key, 
    this.name,
    this.email,
  });

  @override
  State<HomeQuran> createState() => _HomeQuranState();
}

class _HomeQuranState extends State<HomeQuran> {
  late String _name;
  late String _email;
  String? _profileImagePath;
  late SharedPreferences _prefs;
  bool _isPrefsLoaded = false;

  int _currentYearIndex = 2; 
  
  final List<Map<String, dynamic>> _academicYears = [
    {
      'period': '2022-2023',
      'startYear': '2022',
      'endYear': '2023',
      'hafalanProgress': 0.0,  
      'kehadiranProgress': 0.0, 
      'hafalanPresent': 0,
      'hafalanAbsent': 0,
      'hafalanTotal': 0,
      'kehadiranPresent': 0,
      'kehadiranAbsent': 0,
      'kehadiranTotal': 0,
    },
    {
      'period': '2023-2024',
      'startYear': '2023',
      'endYear': '2024',
      'hafalanProgress': 0.0,
      'kehadiranProgress': 0.0,
      'hafalanPresent': 0,
      'hafalanAbsent': 0,
      'hafalanTotal': 0,
      'kehadiranPresent': 0,
      'kehadiranAbsent': 0,
      'kehadiranTotal': 0,
    },
    {
      'period': '2024-2025',
      'startYear': '2024',
      'endYear': '2025',
      'hafalanProgress': 0.0,
      'kehadiranProgress': 0.0,
      'hafalanPresent': 0,
      'hafalanAbsent': 0,
      'hafalanTotal': 0,
      'kehadiranPresent': 0,
      'kehadiranAbsent': 0,
      'kehadiranTotal': 0,
    },
    {
      'period': '2025-2026',
      'startYear': '2025',
      'endYear': '2026',
      'hafalanProgress': 0.0,
      'kehadiranProgress': 0.0,
      'hafalanPresent': 0,
      'hafalanAbsent': 0,
      'hafalanTotal': 0,
      'kehadiranPresent': 0,
      'kehadiranAbsent': 0,
      'kehadiranTotal': 0,
    },
    {
      'period': '2026-2027',
      'startYear': '2026',
      'endYear': '2027',
      'hafalanProgress': 0.0,
      'kehadiranProgress': 0.0,
      'hafalanPresent': 0,
      'hafalanAbsent': 0,
      'hafalanTotal': 0,
      'kehadiranPresent': 0,
      'kehadiranAbsent': 0,
      'kehadiranTotal': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _name = widget.name ?? "User Name";
    _email = widget.email ?? "user@example.com";
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _isPrefsLoaded = true;
    _loadSavedAcademicYearData();
    _loadSantriData();
  }

  void _loadSavedAcademicYearData() {
    if (!_isPrefsLoaded) return;

    for (int i = 0; i < _academicYears.length; i++) {
      String period = _academicYears[i]['period'];
      String key = 'academic_year_$period';
      
      if (_prefs.containsKey(key)) {
        String? jsonData = _prefs.getString(key);
        if (jsonData != null) {
          Map<String, dynamic> savedData = json.decode(jsonData);
          setState(() {
            _academicYears[i] = {..._academicYears[i], ...savedData};
          });
        }
      }
    }

    // Load current year index
    int? savedIndex = _prefs.getInt('current_year_index');
    if (savedIndex != null && savedIndex >= 0 && savedIndex < _academicYears.length) {
      setState(() {
        _currentYearIndex = savedIndex;
      });
    }
  }

  Future<void> _saveAcademicYearData(int index) async {
    if (!_isPrefsLoaded) return;
    
    String period = _academicYears[index]['period'];
    String key = 'academic_year_$period';
    
    await _prefs.setString(key, json.encode(_academicYears[index]));
    await _prefs.setInt('current_year_index', _currentYearIndex);
  }

  Future<void> _loadSantriData() async {
    if (!_isPrefsLoaded) return;
    
    for (var i = 0; i < _academicYears.length; i++) {
      var year = _academicYears[i];
      final santriList = models.SantriDataProvider.getSantriForYear(year['period']);
      if (santriList.isNotEmpty) {
        int totalSantri = santriList.length;
        
        int hafalanPresent = totalSantri;
        int kehadiranPresent = totalSantri;
        
        setState(() {
          year['hafalanTotal'] = totalSantri;
          year['hafalanPresent'] = hafalanPresent;
          year['hafalanAbsent'] = totalSantri - hafalanPresent;
          year['hafalanProgress'] = hafalanPresent / totalSantri;
          
          year['kehadiranTotal'] = totalSantri;
          year['kehadiranPresent'] = kehadiranPresent;
          year['kehadiranAbsent'] = totalSantri - kehadiranPresent;
          year['kehadiranProgress'] = kehadiranPresent / totalSantri;
        });
        
        _saveAcademicYearData(i);
      }
    }
  }

  Future<void> _reloadProfileData() async {
    await Future.delayed(Duration(seconds: 1)); 
    await _loadSantriData();
    setState(() {
    });
  }

  void _navigateYear(int direction) {
    setState(() {
      int newIndex = _currentYearIndex + direction;
      if (newIndex >= 0 && newIndex < _academicYears.length) {
        _currentYearIndex = newIndex;
        _prefs.setInt('current_year_index', _currentYearIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = _academicYears[_currentYearIndex];
    
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2E3F7F),
              const Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _reloadProfileData,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: 50, left: 20, right: 20, bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.white,
                                    backgroundImage: _profileImagePath != null
                                        ? FileImage(File(_profileImagePath!))
                                        : AssetImage(
                                                'assets/profile_picture.png')
                                            as ImageProvider,
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _name,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        _email,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Kehadiran Tahfidz",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E3F7F),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.arrow_back_ios, size: 18),
                                        color: _currentYearIndex > 0 
                                            ? Color(0xFF2E3F7F) 
                                            : Colors.grey[400],
                                        onPressed: _currentYearIndex > 0 
                                            ? () => _navigateYear(-1) 
                                            : null,
                                        constraints: BoxConstraints(),
                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                        splashRadius: 20,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            currentYear['startYear'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2E3F7F),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            '-',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.green,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            currentYear['endYear'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2E3F7F),
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.arrow_forward_ios, size: 18),
                                        color: _currentYearIndex < _academicYears.length - 1 
                                            ? Color(0xFF2E3F7F) 
                                            : Colors.grey[400],
                                        onPressed: _currentYearIndex < _academicYears.length - 1 
                                            ? () => _navigateYear(1) 
                                            : null,
                                        constraints: BoxConstraints(),
                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                        splashRadius: 20,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildEnhancedProgressIndicator(
                                        value: currentYear['hafalanProgress'],
                                        color: Colors.blue,
                                        label: 'Hafalan',
                                        presentCount: currentYear['hafalanPresent'],
                                        absentCount: currentYear['hafalanAbsent'],
                                        totalCount: currentYear['hafalanTotal'],
                                      ),
                                      _buildEnhancedProgressIndicator(
                                        value: currentYear['kehadiranProgress'],
                                        color: Colors.green,
                                        label: 'Kehadiran',
                                        presentCount: currentYear['kehadiranPresent'],
                                        absentCount: currentYear['kehadiranAbsent'],
                                        totalCount: currentYear['kehadiranTotal'],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: GalleryView(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: NewsView(newsItems: newsItems),
                        ),
                        SizedBox(height: 20), 
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildEnhancedProgressIndicator({
    required double value,
    required Color color,
    required String label,
    required int presentCount,
    required int absentCount,
    required int totalCount,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SantriTablePage(
              academicYear: _academicYears[_currentYearIndex]['period'],
              category: label,
              progress: value,
              color: color,
              onDataUpdate: (updatedProgress, present, total) {
                setState(() {
                  if (label == 'Hafalan') {
                    _academicYears[_currentYearIndex]['hafalanProgress'] = updatedProgress;
                    _academicYears[_currentYearIndex]['hafalanPresent'] = present;
                    _academicYears[_currentYearIndex]['hafalanTotal'] = total;
                    _academicYears[_currentYearIndex]['hafalanAbsent'] = total - present;
                  } else if (label == 'Kehadiran') {
                    _academicYears[_currentYearIndex]['kehadiranProgress'] = updatedProgress;
                    _academicYears[_currentYearIndex]['kehadiranPresent'] = present;
                    _academicYears[_currentYearIndex]['kehadiranTotal'] = total;
                    _academicYears[_currentYearIndex]['kehadiranAbsent'] = total - present;
                  }
                  _saveAcademicYearData(_currentYearIndex);
                });
                
                print('Updated $label: $present/$total (${(updatedProgress * 100).toStringAsFixed(1)}%)');
              },
            ),
          ),
        ).then((_) {
          setState(() {});
        });
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 85,
                  width: 85,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(value * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          '$presentCount/$totalCount',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Lihat Detail',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}