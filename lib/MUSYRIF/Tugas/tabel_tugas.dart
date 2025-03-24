import 'package:aplikasi_guru/MUSYRIF/Tugas/rekap_tugas.dart';
import 'package:aplikasi_guru/models/tugassantri_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TabelTugas extends StatefulWidget {
  final String session;
  final String category;
  final DateTime selectedDate;
  final String searchQuery; // Add this parameter

  TabelTugas({
    required this.session,
    required this.category,
    required this.selectedDate,
    this.searchQuery = "", // Default to empty string
  });

  @override
  _TabelTugasState createState() => _TabelTugasState();
}

class _TabelTugasState extends State<TabelTugas>
    with SingleTickerProviderStateMixin {
  final List<String> allSantri = ["Ahmad", "Ali", "Fatimah", "Zaid"];
  Map<String, TextEditingController> scoreControllers = {};
  Map<String, FocusNode> focusNodes = {};
  Map<String, String> predikatMap = {};
  bool isEditing = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(_controller);
    _loadSavedScores();
  }

  @override
  void didUpdateWidget(TabelTugas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      setState(() {
        scoreControllers.clear();
        predikatMap.clear();
      });
      _loadSavedScores();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _saveScores();
    for (var controller in scoreControllers.values) {
      controller.dispose();
    }
    for (var focus in focusNodes.values) {
      focus.dispose();
    }
    super.dispose();
  }

  Future<void> _saveScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> scores = {};

    scoreControllers.forEach((key, controller) {
      scores[key] = controller.text;
    });

    await prefs.setString(
        "scores_${widget.session}_${widget.category}_${widget.selectedDate.toIso8601String()}",
        jsonEncode(scores));
  }

  Future<void> _loadSavedScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString(
        "scores_${widget.session}_${widget.category}_${widget.selectedDate.toIso8601String()}");

    if (savedData != null) {
      Map<String, dynamic> savedScores = jsonDecode(savedData);
      setState(() {
        scoreControllers.clear();
        predikatMap.clear();
        savedScores.forEach((key, value) {
          scoreControllers[key] = TextEditingController(text: value);
          predikatMap[key] = getPredikat(int.tryParse(value) ?? 0);
        });
      });
    } else {
      setState(() {
        scoreControllers.clear();
        predikatMap.clear();
      });
    }
  }

  String getPredikat(int skor) {
    if (skor >= 90) return "Istimewa";
    if (skor >= 80) return "Baik Sekali";
    if (skor >= 70) return "Baik";
    if (skor >= 60) return "Cukup";
    return "Kurang";
  }

  @override
  Widget build(BuildContext context) {
    List<String> activities = [];
    for (var sesi in SesiData.sesiList) {
      if (sesi["sesi"] == widget.session) {
        for (var kategori in sesi["kategori"]) {
          if (kategori["nama"] == widget.category) {
            activities = List<String>.from(kategori["kegiatan"]);
            break;
          }
        }
        break;
      }
    }

    // Filter students based on searchQuery
    List<String> filteredSantri = allSantri.where((santri) {
      return santri.toLowerCase().contains(widget.searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: filteredSantri.map((santri) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          santri,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        // Excel-like table
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.shade400, width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            children: [
                              // Header row
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF2E3F7F),
                                  border: Border(
                                    bottom: BorderSide(
                                        color: Colors.grey.shade400, width: 1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Date column header removed
                                    _buildHeaderCell("Aktivitas", 1),
                                    _buildHeaderCell("Skor", 1),
                                    _buildHeaderCell("Predikat", 1),
                                  ],
                                ),
                              ),
                              // Data rows
                              Column(
                                children: activities.map((activity) {
                                  String key =
                                      "${widget.session}_${widget.category}_${santri}_${activity}";

                                  scoreControllers.putIfAbsent(
                                      key, () => TextEditingController());
                                  focusNodes.putIfAbsent(
                                      key, () => FocusNode());
                                  predikatMap.putIfAbsent(key, () => "-");

                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey.shade400,
                                            width: 1),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Date column removed
                                        _buildDataCell(activity, 1, false),
                                        _buildDataCell(
                                          "",
                                          1,
                                          true,
                                          controller: scoreControllers[key],
                                          focusNode: focusNodes[key],
                                          onChanged: (value) {
                                            setState(() {
                                              int skor =
                                                  int.tryParse(value) ?? 0;
                                              predikatMap[key] =
                                                  getPredikat(skor);
                                            });
                                            _saveScores();
                                          },
                                          onSubmitted: (_) {
                                            _saveScores();
                                            _moveFocusToNextField(key);
                                          },
                                        ),
                                        _buildDataCell(
                                            predikatMap[key]!, 1, false),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ScaleTransition(
            scale: _animation,
            alignment: Alignment.bottomCenter,
          ),
          SizedBox(height: 16),
          ScaleTransition(
            scale: _animation,
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  isEditing = !isEditing;
                });
              },
              child: Icon(isEditing ? Icons.save : Icons.edit),
              backgroundColor: isEditing ? Colors.green : Colors.blue,
            ),
          ),
          SizedBox(height: 16),
          ScaleTransition(
            scale: _animation,
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RekapHarian(
                      selectedDate: widget.selectedDate,
                    ),
                  ),
                );
              },
              child: Icon(Icons.assessment, color: Colors.blue.shade700),
              backgroundColor: const Color.fromARGB(255, 244, 168, 54),
            ),
          ),
          SizedBox(height: 16),
          RotationTransition(
            turns: _rotationAnimation,
            child: FloatingActionButton(
              onPressed: () {
                if (_controller.isDismissed) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              },
              child: Icon(Icons.more_vert, color: Colors.blue.shade700),
              backgroundColor: Colors.blue.shade50,
            ),
          ),
          SizedBox(height: 1),
        ],
      ),
    );
  }

  // Helper method to build header cells for the Excel-like table
  Widget _buildHeaderCell(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Helper method to build data cells for the Excel-like table
  Widget _buildDataCell(
    String text,
    int flex,
    bool isEditable, {
    TextEditingController? controller,
    FocusNode? focusNode,
    Function(String)? onChanged,
    Function(String)? onSubmitted,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
          color: Colors.white,
        ),
        child: isEditable && isEditing
            ? TextField(
                controller: controller,
                focusNode: focusNode,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                  border: InputBorder.none,
                  hintText: "0",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                ),
                onChanged: onChanged,
                onSubmitted: onSubmitted,
              )
            : isEditable && !isEditing
                ? Center(
                    child: Text(
                      controller?.text ?? "0",
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Center(
                    child: Text(
                      text,
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
      ),
    );
  }

  void _moveFocusToNextField(String currentKey) {
    List<String> keys = scoreControllers.keys.toList();
    int currentIndex = keys.indexOf(currentKey);
    if (currentIndex != -1 && currentIndex < keys.length - 1) {
      FocusScope.of(context).requestFocus(focusNodes[keys[currentIndex + 1]]);
    }
  }
}