import 'package:aplikasi_guru/GURU_QURAN/Home/Galeri/galeri.dart';
import 'package:aplikasi_guru/GURU_QURAN/Home/Berita/berita.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_guru/GURU_QURAN/Home/Tabel_Santri/santri_table.dart';
import 'package:aplikasi_guru/MODELS/models/santri_data.dart' as models;
import 'package:aplikasi_guru/GURU_QURAN/Home/Leaderboard/leaderboard.dart';

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
  PageController _pageController = PageController();
  int _pageIndex = 0;

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
        
        // Load saved attendance data from shared preferences
        final hafalanKey = '${year['period']}_Hafalan_attendance';
        final kehadiranKey = '${year['period']}_Kehadiran_attendance';
        
        final prefs = await SharedPreferences.getInstance();
        final hafalanData = prefs.getString(hafalanKey);
        final kehadiranData = prefs.getString(kehadiranKey);
        
        int hafalanPresent = totalSantri;
        int kehadiranPresent = totalSantri;
        
        // Calculate actual present students from saved data
        if (hafalanData != null) {
          Map<String, dynamic> hafalanMap = json.decode(hafalanData);
          hafalanPresent = hafalanMap.values.where((value) => value == true).length;
        }
        
        if (kehadiranData != null) {
          Map<String, dynamic> kehadiranMap = json.decode(kehadiranData);
          kehadiranPresent = kehadiranMap.values.where((value) => value == true).length;
        }
        
        setState(() {
          year['hafalanTotal'] = totalSantri;
          year['hafalanPresent'] = hafalanPresent;
          year['hafalanAbsent'] = totalSantri - hafalanPresent;
          year['hafalanProgress'] = totalSantri > 0 ? hafalanPresent / totalSantri : 0.0;
          
          year['kehadiranTotal'] = totalSantri;
          year['kehadiranPresent'] = kehadiranPresent;
          year['kehadiranAbsent'] = totalSantri - kehadiranPresent;
          year['kehadiranProgress'] = totalSantri > 0 ? kehadiranPresent / totalSantri : 0.0;
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


  @override
  Widget build(BuildContext context) {
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
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back_ios, size: 16),
                                        onPressed: _currentYearIndex > 0
                                            ? () {
                                                setState(() {
                                                  _currentYearIndex--;
                                                  _saveAcademicYearData(_currentYearIndex);
                                                });
                                              }
                                            : null,
                                        color: _currentYearIndex > 0 ? const Color(0xFF2E3F7F) : Colors.grey,
                                      ),
                                      Flexible(
                                        child: Column(
                                          children: [
                                            const Text(
                                              "Persentase Hafalan & Kehadiran",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2E3F7F),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              _academicYears[_currentYearIndex]['period'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[600],
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                                        onPressed: _currentYearIndex < _academicYears.length - 1
                                            ? () {
                                                setState(() {
                                                  _currentYearIndex++;
                                                  _saveAcademicYearData(_currentYearIndex);
                                                });
                                              }
                                            : null,
                                        color: _currentYearIndex < _academicYears.length - 1 ? const Color(0xFF2E3F7F) : Colors.grey,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildEnhancedProgressIndicator(
                                        value: _academicYears[_currentYearIndex]['hafalanProgress'] ?? 0.0,
                                        color: Colors.green,
                                        label: 'Hafalan',
                                        presentCount: _academicYears[_currentYearIndex]['hafalanPresent'] ?? 0,
                                        absentCount: _academicYears[_currentYearIndex]['hafalanAbsent'] ?? 0,
                                        totalCount: _academicYears[_currentYearIndex]['hafalanTotal'] ?? 0,
                                      ),
                                      _buildEnhancedProgressIndicator(
                                        value: _academicYears[_currentYearIndex]['kehadiranProgress'] ?? 0.0,
                                        color: Colors.blue,
                                        label: 'Kehadiran',
                                        presentCount: _academicYears[_currentYearIndex]['kehadiranPresent'] ?? 0,
                                        absentCount: _academicYears[_currentYearIndex]['kehadiranAbsent'] ?? 0,
                                        totalCount: _academicYears[_currentYearIndex]['kehadiranTotal'] ?? 0,
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

  Widget _buildLeaderboardItem({
    required int rank,
    required String name,
    required String score,
    required Color color,
    bool isFirst = false,
    bool isSecond = false,
    bool isThird = false,
    required double maxWidth,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: isFirst ? 35 : 28,
          backgroundColor: color,
          child: Text(
            '$rank',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: isFirst ? 24 : 20,
            ),
          ),
        ),
        SizedBox(height: 4),
        Container(
          width: maxWidth,
          child: Column(
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isFirst ? 16 : 14,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Hafalan: $score',
                style: TextStyle(
                  fontSize: isFirst ? 14 : 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
