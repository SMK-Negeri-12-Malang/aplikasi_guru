import 'package:aplikasi_guru/GURU_QURAN/Home/Galeri/galeri.dart';
import 'package:aplikasi_guru/GURU_QURAN/Home/Berita/berita.dart';
import 'package:flutter/material.dart';
import 'dart:io';
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

  int _currentYearIndex = 2;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _academicYears = [
    {
      'period': '2022-2023',
      'startYear': '2022',
      'endYear': '2023',
      'hafalanProgress': 0.95,
      'kehadiranProgress': 0.88,
      'hafalanPresent': 38,
      'hafalanAbsent': 2,
      'hafalanTotal': 40,
      'kehadiranPresent': 35,
      'kehadiranAbsent': 5,
      'kehadiranTotal': 40,
    },
    {
      'period': '2023-2024',
      'startYear': '2023',
      'endYear': '2024',
      'hafalanProgress': 0.85,
      'kehadiranProgress': 0.70,
    },
    {
      'period': '2024-2025',
      'startYear': '2024',
      'endYear': '2025',
      'hafalanProgress': 0.75,
      'kehadiranProgress': 0.60,
    },
    {
      'period': '2025-2026',
      'startYear': '2025',
      'endYear': '2026',
      'hafalanProgress': 0.40,
      'kehadiranProgress': 0.85,
    },
    {
      'period': '2026-2027',
      'startYear': '2026',
      'endYear': '2027',
      'hafalanProgress': 0.25,
      'kehadiranProgress': 0.30,
    },
  ];

  @override
  void initState() {
    super.initState();
    _name = widget.name ?? "User Name";
    _email = widget.email ?? "user@example.com";
    _loadSantriData();
  }

  Future<void> _loadSantriData() async {
    for (var year in _academicYears) {
      final santriList =
          models.SantriDataProvider.getSantriForYear(year['period']);
      if (santriList.isNotEmpty) {
        int totalSantri = santriList.length;
        int hafalanPresent = (totalSantri * 0.85).round();
        int kehadiranPresent = (totalSantri * 0.75).round();

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
      }
    }
  }

  Future<void> _reloadProfileData() async {
    await Future.delayed(Duration(seconds: 1));
    await _loadSantriData();
    setState(() {});
  }

  void _navigateYear(int direction) {
    setState(() {
      int newIndex = _currentYearIndex + direction;
      if (newIndex >= 0 && newIndex < _academicYears.length) {
        _currentYearIndex = newIndex;
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
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
                                        icon: Icon(Icons.arrow_back_ios,
                                            size: 18),
                                        color: _currentYearIndex > 0
                                            ? Color(0xFF2E3F7F)
                                            : Colors.grey[400],
                                        onPressed: _currentYearIndex > 0
                                            ? () => _navigateYear(-1)
                                            : null,
                                        constraints: BoxConstraints(),
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 8),
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
                                        icon: Icon(Icons.arrow_forward_ios,
                                            size: 18),
                                        color: _currentYearIndex <
                                                _academicYears.length - 1
                                            ? Color(0xFF2E3F7F)
                                            : Colors.grey[400],
                                        onPressed: _currentYearIndex <
                                                _academicYears.length - 1
                                            ? () => _navigateYear(1)
                                            : null,
                                        constraints: BoxConstraints(),
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        splashRadius: 20,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildEnhancedProgressIndicator(
                                        value: currentYear['hafalanProgress'],
                                        color: Colors.blue,
                                        label: 'Hafalan',
                                        presentCount:
                                            currentYear['hafalanPresent'],
                                        absentCount:
                                            currentYear['hafalanAbsent'],
                                        totalCount: currentYear['hafalanTotal'],
                                      ),
                                      _buildEnhancedProgressIndicator(
                                        value: currentYear['kehadiranProgress'],
                                        color: Colors.green,
                                        label: 'Kehadiran',
                                        presentCount:
                                            currentYear['kehadiranPresent'],
                                        absentCount:
                                            currentYear['kehadiranAbsent'],
                                        totalCount:
                                            currentYear['kehadiranTotal'],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: GalleryView(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
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
      onTap: _isLoading
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });

              try {
                final route = MaterialPageRoute(
                  builder: (context) => SantriTablePage(
                    academicYear: _academicYears[_currentYearIndex]['period'],
                    category: label,
                    progress: value,
                    color: color,
                  ),
                );

                // Show loading overlay
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: color),
                          SizedBox(height: 16),
                          Text(
                            'Memuat data...',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                // Navigate and wait for result
                await Navigator.of(context).push(route);

                // Remove loading overlay
                if (mounted) Navigator.of(context).pop();

                // Reload data
                await _reloadProfileData();
              } finally {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
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
            _isLoading
                ? SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                : Text(
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
