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
    _loadProfileData();
    _initPreferences();
  }

  Future<void> _loadProfileData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? userName = prefs.getString('user_name');
      String? userEmail = prefs.getString('user_email');
      String? profileImagePath = prefs.getString('profile_image_path');

      setState(() {
        _name = userName ?? "User Name";
        _email = userEmail ?? "user@example.com";
        _profileImagePath = profileImagePath;
      });
    } catch (e) {
      print('Error loading profile data: $e');
      setState(() {
        _name = 'Error loading data';
        _email = 'Please try again';
      });
    }
  }

  Future<void> _reloadProfileData() async {
    await _loadProfileData();
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
                        // Profile section (tanpa card)
                        Padding(
                          padding: EdgeInsets.only(top: 32, left: 20, right: 20, bottom: 18),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: Color(0xFF2E3F7F).withOpacity(0.12),
                                backgroundImage: _profileImagePath != null
                                    ? FileImage(File(_profileImagePath!))
                                    : AssetImage('assets/profile_picture.png') as ImageProvider,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _email,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Academic Year Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade100.withOpacity(0.13),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              height: 240,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: 2,
                                onPageChanged: (index) {
                                  setState(() {
                                    _pageIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final year = _academicYears[_currentYearIndex];
                                  final santriList = models.SantriDataProvider.getSantriForYear(year['period']);
                                  final sortedSantri = List.of(santriList)
                                    ..sort((a, b) => (b.hafalan ?? 0).compareTo(a.hafalan ?? 0));
                                  final topSantri = sortedSantri.take(3).toList();
                                  if (index == 0) {
                                    return Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.arrow_back_ios, size: 16),
                                                onPressed: _currentYearIndex > 0
                                                    ? () {
                                                        setState(() {
                                                          _currentYearIndex--;
                                                          _saveAcademicYearData(_currentYearIndex);
                                                        });
                                                      }
                                                    : null,
                                                color: _currentYearIndex > 0 ? Color(0xFF2E3F7F) : Colors.grey,
                                              ),
                                              Text(
                                                "Persentase Hafalan & Kehadiran",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2E3F7F),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.arrow_forward_ios, size: 16),
                                                onPressed: _currentYearIndex < _academicYears.length - 1
                                                    ? () {
                                                        setState(() {
                                                          _currentYearIndex++;
                                                          _saveAcademicYearData(_currentYearIndex);
                                                        });
                                                      }
                                                    : null,
                                                color: _currentYearIndex < _academicYears.length - 1 ? Color(0xFF2E3F7F) : Colors.grey,
                                              ),
                                            ],
                                          ),
                                          Text(
                                            year['period'],
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              _buildEnhancedProgressIndicator(
                                                value: year['hafalanProgress'] ?? 0.0,
                                                color: Colors.green,
                                                label: 'Hafalan',
                                                presentCount: year['hafalanPresent'] ?? 0,
                                                absentCount: year['hafalanAbsent'] ?? 0,
                                                totalCount: year['hafalanTotal'] ?? 0,
                                              ),
                                              _buildEnhancedProgressIndicator(
                                                value: year['kehadiranProgress'] ?? 0.0,
                                                color: Colors.blue,
                                                label: 'Kehadiran',
                                                presentCount: year['kehadiranPresent'] ?? 0,
                                                absentCount: year['kehadiranAbsent'] ?? 0,
                                                totalCount: year['kehadiranTotal'] ?? 0,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => LeaderboardPage(
                                              academicYear: year['period'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Peringkat 3 Besar Santri",
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2E3F7F),
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Expanded(
                                              child: LayoutBuilder(
                                                builder: (context, constraints) {
                                                  return Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      _buildLeaderboardItem(
                                                        rank: 2,
                                                        name: topSantri.length > 1 ? topSantri[1].name : '-',
                                                        score: topSantri.length > 1 ? '${topSantri[1].hafalan ?? 0}' : '',
                                                        color: Colors.grey,
                                                        isSecond: true,
                                                        maxWidth: constraints.maxWidth / 3.5,
                                                      ),
                                                      _buildLeaderboardItem(
                                                        rank: 1,
                                                        name: topSantri.isNotEmpty ? topSantri[0].name : '-',
                                                        score: topSantri.isNotEmpty ? '${topSantri[0].hafalan ?? 0}' : '',
                                                        color: Colors.amber,
                                                        isFirst: true,
                                                        maxWidth: constraints.maxWidth / 3.5,
                                                      ),
                                                      _buildLeaderboardItem(
                                                        rank: 3,
                                                        name: topSantri.length > 2 ? topSantri[2].name : '-',
                                                        score: topSantri.length > 2 ? '${topSantri[2].hafalan ?? 0}' : '',
                                                        color: Colors.brown,
                                                        isThird: true,
                                                        maxWidth: constraints.maxWidth / 3.5,
                                                      ),
                                                    ],
                                                  );
                                                }
                                              ),
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
                                },
                              ),
                            ),
                          ),
                        ),
                        // PageView indicator
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(2, (index) => Container(
                            width: 10,
                            height: 10,
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _pageIndex == index ? Color(0xFF2E3F7F) : Colors.grey[300],
                            ),
                          )),
                        ),
                        // Gallery
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: GalleryView(),
                        ),
                        // News
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