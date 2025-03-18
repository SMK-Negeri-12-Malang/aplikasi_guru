import 'package:aplikasi_guru/MUSYRIF/Tugas/rekap_tugas.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:aplikasi_guru/MUSYRIF/Tugas/history_tugas.dart';
import 'package:aplikasi_guru/models/tugassantri_model.dart'; // Import the model

class TabelTugas extends StatefulWidget {
  final String session;
  final String category;

  TabelTugas({required this.session, required this.category});

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
        "scores_${widget.session}_${widget.category}", jsonEncode(scores));
  }

  Future<void> _loadSavedScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData =
        prefs.getString("scores_${widget.session}_${widget.category}");

    if (savedData != null) {
      Map<String, dynamic> savedScores = jsonDecode(savedData);
      setState(() {
        savedScores.forEach((key, value) {
          scoreControllers[key] = TextEditingController(text: value);
          predikatMap[key] = getPredikat(int.tryParse(value) ?? 0);
        });
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

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 16.0), // Add padding to the sides
            child: Column(
              children: allSantri.map((santri) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
                        SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double columnWidth = constraints.maxWidth / 4;
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: columnWidth / 2,
                                columns: [
                                  DataColumn(
                                      label: Container(
                                          width: columnWidth,
                                          child: Text("Tanggal"))),
                                  DataColumn(
                                      label: Container(
                                          width: columnWidth,
                                          child: Text("Aktivitas"))),
                                  DataColumn(
                                      label: Container(
                                          width: columnWidth,
                                          child: Text("Skor"))),
                                  DataColumn(
                                      label: Container(
                                          width: columnWidth,
                                          child: Text("Predikat"))),
                                ],
                                rows: activities.map((activity) {
                                  String key =
                                      "${widget.session}_${widget.category}_${santri}_${activity}";

                                  scoreControllers.putIfAbsent(
                                      key, () => TextEditingController());
                                  focusNodes.putIfAbsent(
                                      key, () => FocusNode());
                                  predikatMap.putIfAbsent(key, () => "-");

                                  return DataRow(
                                    cells: [
                                      DataCell(Container(
                                          width: columnWidth,
                                          child: Text("08-03-2025"))),
                                      DataCell(Container(
                                          width: columnWidth,
                                          child: Text(activity))),
                                      DataCell(
                                        Container(
                                          width: columnWidth,
                                          child: TextFormField(
                                            controller: scoreControllers[key],
                                            focusNode: focusNodes[key],
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              hintText: "0",
                                              border: InputBorder.none,
                                            ),
                                            enabled: isEditing,
                                            onChanged: (value) {
                                              setState(() {
                                                int skor =
                                                    int.tryParse(value) ?? 0;
                                                predikatMap[key] =
                                                    getPredikat(skor);
                                              });
                                              _saveScores();
                                            },
                                            onFieldSubmitted: (_) {
                                              _saveScores();
                                              _moveFocusToNextField(key);
                                            },
                                          ),
                                        ),
                                      ),
                                      DataCell(Container(
                                          width: columnWidth,
                                          child: Text(predikatMap[key]!))),
                                    ],
                                  );
                                }).toList(),
                              ),
                            );
                          },
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
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryTugas()),
                );
              },
              child: Icon(Icons.history),
              backgroundColor: Colors.orange,
            ),
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
                  MaterialPageRoute(builder: (context) => RekapHarian()),
                );
              },
              child: Icon(Icons.assessment),
              backgroundColor: Colors.red,
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
              child: Icon(Icons.more_vert),
              backgroundColor: Colors.grey,
            ),
          ),
          SizedBox(height: 1,
          ), // Add some space to avoid overflow
        ],
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
