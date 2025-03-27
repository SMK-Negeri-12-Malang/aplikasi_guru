import 'package:aplikasi_guru/MODELS/models/santri_data.dart' as models;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// Add shimmer package for loading effects
import 'package:shimmer/shimmer.dart';

class SantriTablePage extends StatefulWidget {
  final String academicYear;
  final String category;
  final double progress;
  final Color color;
  final Function(double progress, int present, int total)? onDataUpdate;

  const SantriTablePage({
    Key? key,
    required this.academicYear,
    required this.category,
    required this.progress,
    required this.color,
    this.onDataUpdate,
  }) : super(key: key);

  @override
  State<SantriTablePage> createState() => _SantriTablePageState();
}

class _SantriTablePageState extends State<SantriTablePage> with TickerProviderStateMixin {
  late List<models.Santri> _santriData;
  bool _isLoading = true;
  String _searchQuery = '';
  Map<int, bool> _attendanceStatus = {};
  bool _isRefreshing = false;
  late AnimationController _loadingController;
  late AnimationController _refreshController;
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  bool _useShimmerLoading = true; // Flag to toggle between loading animation types
  // Add a variable to store the current progress
  double _currentProgress = 0.0;
  
  @override
  void initState() {
    super.initState();
    // Initialize _currentProgress with the value from widget.progress
    _currentProgress = widget.progress;
    
    _loadingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat();
    
    _refreshController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _bounceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    
    _loadSantriData();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _refreshController.dispose();
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _loadSantriData() async {
    // Simulate loading delay
    await Future.delayed(Duration(milliseconds: 800));
    
    // Load the santri data
    final santriList = models.SantriDataProvider.getSantriForYear(widget.academicYear);
    
    // Load saved attendance status from SharedPreferences
    Map<int, bool> savedAttendance = await _loadAttendanceFromPrefs();
    
    setState(() {
      _santriData = santriList;
      
      // Initialize attendance status - use saved data if available
      for (var santri in _santriData) {
        if (savedAttendance.containsKey(santri.id)) {
          _attendanceStatus[santri.id] = savedAttendance[santri.id]!;
        } else {
          _attendanceStatus[santri.id] = true; // default to present
        }
      }
      
      _isLoading = false;
    });
    
    // Calculate and update progress based on actual attendance data
    _recalculateAndUpdateProgress();
    
    // Notify parent about current data after recalculation
    _notifyParentOfUpdate();
  }

  // New improved method to calculate and update progress
  void _recalculateAndUpdateProgress() {
    if (_santriData.isEmpty) return;
    
    // Count present students
    int presentCount = 0;
    for (var santri in _santriData) {
      if (_attendanceStatus[santri.id] == true) {
        presentCount++;
      }
    }
    
    // Calculate current percentage
    final percentage = presentCount / _santriData.length;
    
    // Update local progress value
    setState(() {
      _currentProgress = percentage;
    });
    
    debugPrint('Progress recalculated: ${(percentage * 100).toStringAsFixed(1)}% ($presentCount/${_santriData.length})');
  }

  Future<Map<int, bool>> _loadAttendanceFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${widget.academicYear}_${widget.category}_attendance';
      final savedData = prefs.getString(key);
      
      if (savedData != null) {
        Map<String, dynamic> decoded = json.decode(savedData);
        // Convert string keys back to int keys
        Map<int, bool> result = {};
        decoded.forEach((key, value) {
          result[int.parse(key)] = value;
        });
        return result;
      }
    } catch (e) {
      debugPrint('Error loading attendance data: $e');
    }
    return {};
  }

  Future<void> _saveAttendanceToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${widget.academicYear}_${widget.category}_attendance';
      
      // Convert int keys to string keys for JSON serialization
      Map<String, bool> toSave = {};
      _attendanceStatus.forEach((key, value) {
        toSave[key.toString()] = value;
      });
      
      final data = json.encode(toSave);
      await prefs.setString(key, data);
      debugPrint('Saved attendance data for ${widget.category}');
    } catch (e) {
      debugPrint('Error saving attendance data: $e');
    }
  }

  // Add this method to refresh data with animation
  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    
    _refreshController.reset();
    _refreshController.repeat();
    
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 1200));
    
    // Randomly change some attendance statuses to demonstrate refresh effect
    if (_santriData.isNotEmpty) {
      final random = new DateTime.now().millisecondsSinceEpoch;
      for (var i = 0; i < min(3, _santriData.length); i++) {
        final randomIndex = (random + i) % _santriData.length;
        final santriId = _santriData[randomIndex].id;
        _toggleAttendance(santriId);
      }
    }
    
    await _saveAttendanceToPrefs();
    _notifyParentOfUpdate();
    
    setState(() {
      _isRefreshing = false;
    });
    
    _refreshController.stop();
  }

  // Toggle attendance status for a specific santri
  void _toggleAttendance(int santriId) {
    setState(() {
      _attendanceStatus[santriId] = !(_attendanceStatus[santriId] ?? true);
    });
    
    // Save changes to preferences
    _saveAttendanceToPrefs();
    
    // Update progress and notify parent
    _recalculateAndUpdateProgress();
    _notifyParentOfUpdate();
  }

  void _notifyParentOfUpdate() {
    if (widget.onDataUpdate != null) {
      final summary = _attendanceSummary;
      
      // Pass the updated progress value back to parent widget
      widget.onDataUpdate!(
        _currentProgress,
        summary['present']!,
        summary['total']!
      );
    }
  }

  // Get present and absent counts
  Map<String, int> get _attendanceSummary {
    int presentCount = 0;
    int absentCount = 0;
    
    for (var santri in _santriData) {
      if (_attendanceStatus[santri.id] == true) {
        presentCount++;
      } else {
        absentCount++;
      }
    }
    
    return {
      'present': presentCount,
      'absent': absentCount,
      'total': _santriData.length
    };
  }

  List<models.Santri> get _filteredData {
    if (_searchQuery.isEmpty) {
      return _santriData;
    }
    
    return _santriData.where((santri) {
      return santri.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             santri.id.toString().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final summary = _attendanceSummary;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} - ${widget.academicYear}'),
        backgroundColor: widget.color,
      ),
      body: Column(
        children: [
          Container(
            color: widget.color.withOpacity(0.1),
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Add an animated progress circle to make the percentage changes more visually appealing
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _currentProgress,
                          backgroundColor: widget.color.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                          strokeWidth: 6,
                        ),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: widget.color,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(_currentProgress * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                '${summary['present']}/${summary['total']}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress ${widget.category}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Tahun Ajaran ${widget.academicYear}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Hadir: ${summary['present']} | Tidak Hadir: ${summary['absent']} | Total: ${summary['total']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari nama santri...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? _useShimmerLoading 
                    ? _buildShimmerLoading()
                    : _buildSpinKitLoading()
                : _filteredData.isEmpty
                    ? Center(child: Text('Tidak ada data yang sesuai'))
                    : Stack(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(
                                  widget.color.withOpacity(0.2),
                                ),
                                columnSpacing: 16.0,
                                horizontalMargin: 12.0,
                                columns: [
                                  DataColumn(
                                    label: Text('No', style: TextStyle(fontWeight: FontWeight.bold)),
                                    numeric: true,
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Text('Nama Santri', 
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text('NIS', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  DataColumn(
                                    label: Text('Kehadiran', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                                rows: _filteredData.map((santri) {
                                  // Generate a NIS based on the student ID and academic year
                                  String nis = "S${santri.id.toString().padLeft(3, '0')}${widget.academicYear.substring(2, 4)}${widget.academicYear.substring(7, 9)}";
                                  
                                  bool isPresent = _attendanceStatus[santri.id] ?? true;
                                  
                                  return DataRow(
                                    cells: [
                                      DataCell(Container(
                                        alignment: Alignment.center,
                                        width: 40,
                                        child: Text(santri.id.toString()),
                                      )),
                                      DataCell(Text(santri.name)),
                                      DataCell(Text(nis)),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => _toggleAttendance(santri.id),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isPresent ? Colors.green.shade100 : Colors.red.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isPresent ? Colors.green.shade700 : Colors.red.shade700,
                                              ),
                                            ),
                                            child: Text(
                                              isPresent ? 'Hadir' : 'Tidak Hadir',
                                              style: TextStyle(
                                                color: isPresent ? Colors.green.shade800 : Colors.red.shade800,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          if (_isRefreshing)
                            AnimatedBuilder(
                              animation: _refreshController,
                              builder: (context, child) {
                                return Container(
                                  color: Colors.black.withOpacity(0.2),
                                  child: Center(
                                    child: Card(
                                      elevation: 8,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SpinKitFadingCube(
                                              color: widget.color,
                                              size: 40.0,
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              'Memperbarui Data...',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
          ),
        ],
      ),
      floatingActionButton: !_isLoading ? FloatingActionButton(
        onPressed: _isRefreshing ? null : _refreshData,
        backgroundColor: widget.color,
        child: _isRefreshing 
            ? SpinKitRing(color: Colors.white, lineWidth: 2, size: 24)
            : Icon(Icons.refresh),
      ) : null,
    );
  }
  
  // New method to build fancy SpinKit loading animation
  Widget _buildSpinKitLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_bounceController.value * 0.2),
                child: SpinKitPouringHourGlassRefined(
                  color: widget.color,
                  size: 50.0,
                ),
              );
            }
          ),
          SizedBox(height: 16),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Opacity(
                opacity: 0.6 + (_pulseController.value * 0.4),
                child: Text(
                  'Memuat data santri...',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 16 + (_pulseController.value * 2),
                  ),
                ),
              );
            }
          ),
          SizedBox(height: 24),
          // Additional loading animations
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinKitWave(
                color: widget.color.withOpacity(0.7),
                size: 30.0,
              ),
              SizedBox(width: 20),
              SpinKitDoubleBounce(
                color: widget.color.withOpacity(0.7),
                size: 30.0,
              ),
              SizedBox(width: 20),
              SpinKitThreeBounce(
                color: widget.color.withOpacity(0.7),
                size: 20.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // New method to build shimmer loading effect for tables
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shimmer for table header
              Container(
                height: 50,
                color: Colors.white,
                margin: EdgeInsets.only(bottom: 12),
              ),
              
              // Shimmer for table rows
              for (int i = 0; i < 12; i++)
                Container(
                  height: 40,
                  margin: EdgeInsets.only(bottom: 8),
                  color: Colors.white,
                ),
                
              SizedBox(height: 20),
              
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Loading...', style: TextStyle(color: Colors.transparent)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper function to get minimum value
  int min(int a, int b) => a < b ? a : b;
}
