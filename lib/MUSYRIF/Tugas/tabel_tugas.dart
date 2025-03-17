import 'package:aplikasi_guru/MUSYRIF/Tugas/rekap_tugas.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:aplikasi_guru/MUSYRIF/Tugas/history_tugas.dart';

class TabelTugas extends StatefulWidget {
  final String session;
  final String category;

  TabelTugas({required this.session, required this.category});

  @override
  _TabelTugasState createState() => _TabelTugasState();
}

class _TabelTugasState extends State<TabelTugas> {
  final List<String> allSantri = ["Ahmad", "Ali", "Fatimah", "Zaid"];
  Map<String, TextEditingController> scoreControllers = {};
  Map<String, FocusNode> focusNodes = {};
  Map<String, String> predikatMap = {};
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadSavedScores();
  }

  @override
  void dispose() {
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
    List<String> activities = {
          "Siang": {
            "Tahsin": ["Belajar Tajwid", "Latihan Makhraj", "Praktik Bacaan"],
            "Tahfidz": ["Setoran Hafalan", "Muroja'ah", "Latihan Hafalan"],
            "Mutabaah": ["Shalat Dzuhur", "Makan Siang", "Kegiatan Siang"],
          },
          "Sore": {
            "Tahsin": [
              "Latihan Tajwid",
              "Praktik Makhraj",
              "Latihan Bacaan Quran"
            ],
            "Tahfidz": ["Setoran Hafalan", "Muroja'ah", "Latihan Hafalan"],
            "Mutabaah": ["Shalat Ashar", "Kegiatan Sore"],
          },
          "Malam": {
            "Tahsin": ["Muroja'ah", "Praktik Tajwid", "Latihan Hafalan"],
            "Tahfidz": ["Setoran Hafalan", "Muroja'ah"],
            "Mutabaah": ["Shalat Isya", "Kegiatan Malam"],
          },
        }[widget.session]?[widget.category] ??
        [];

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          double columnWidth = constraints.maxWidth / 4;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: columnWidth / 2,
                      columns: [
                        DataColumn(label: Text("Santri")),
                        DataColumn(label: Text("Tanggal")),
                        DataColumn(label: Text("Aktivitas")),
                        DataColumn(label: Text("Skor")),
                        DataColumn(label: Text("Predikat")),
                      ],
                      rows: allSantri.expand((santri) {
                        return activities.map((activity) {
                          String key =
                              "${widget.session}_${widget.category}_${santri}_${activity}";

                          scoreControllers.putIfAbsent(
                              key, () => TextEditingController());
                          focusNodes.putIfAbsent(key, () => FocusNode());
                          predikatMap.putIfAbsent(key, () => "-");

                          return DataRow(
                            cells: [
                              DataCell(Text(santri)),
                              DataCell(Text("08-03-2025")),
                              DataCell(Text(activity)),
                              DataCell(
                                TextFormField(
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
                                      int skor = int.tryParse(value) ?? 0;
                                      predikatMap[key] = getPredikat(skor);
                                    });
                                    _saveScores();
                                  },
                                  onFieldSubmitted: (_) {
                                    _saveScores();
                                  },
                                ),
                              ),
                              DataCell(Text(predikatMap[key]!)),
                            ],
                          );
                        }).toList();
                      }).toList(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _saveScores();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Data disimpan"),
                      ));
                    },
                    child: Text("Simpan Data"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HistoryTugas()),
                      );
                    },
                    child: Text("History"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RekapHarian()),
                      );
                    },
                    child: Text("Rekap Harian"),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
