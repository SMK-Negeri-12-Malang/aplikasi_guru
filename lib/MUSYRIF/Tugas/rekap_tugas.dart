import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RekapHarian extends StatefulWidget {
  @override
  _RekapHarianState createState() => _RekapHarianState();
}

class _RekapHarianState extends State<RekapHarian> {
  final List<String> sessions = ["Siang", "Sore", "Malam"];
  final List<String> categories = ["Tahsin", "Tahfidz", "Mutabaah"];
  final List<String> allSantri = ["Ahmad", "Ali", "Fatimah", "Zaid"];
  Map<String, Map<String, int>> totalScores = {}; // Map untuk menyimpan total skor
  Map<String, Map<String, int>> countScores = {}; // Map untuk menyimpan jumlah entri skor

  @override
  void initState() {
    super.initState();
    _loadRekapData();
  }

  Future<void> _loadRekapData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, Map<String, int>> scores = {}; // Skor total per santri
    Map<String, Map<String, int>> counts = {}; // Jumlah tugas yang dinilai per santri

    for (String session in sessions) {
      for (String category in categories) {
        String? savedData = prefs.getString("scores_${session}_${category}");
        if (savedData != null) {
          Map<String, dynamic> savedScores = jsonDecode(savedData);
          savedScores.forEach((key, value) {
            List<String> parts = key.split("_");
            if (parts.length < 3) return;
            String santri = parts[2];

            int score = int.tryParse(value) ?? 0;

            scores.putIfAbsent(santri, () => {});
            counts.putIfAbsent(santri, () => {});

            scores[santri]?.update(category, (val) => val + score, ifAbsent: () => score);
            counts[santri]?.update(category, (val) => val + 1, ifAbsent: () => 1);
          });
        }
      }
    }

    setState(() {
      totalScores = scores;
      countScores = counts;
    });
  }

  String getPredikat(double skor) {
    if (skor >= 90) return "Istimewa";
    if (skor >= 80) return "Baik Sekali";
    if (skor >= 70) return "Baik";
    if (skor >= 60) return "Cukup";
    return "Kurang";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rekap Harian")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text("Santri")),
              DataColumn(label: Text("Tahsin")),
              DataColumn(label: Text("Tahfidz")),
              DataColumn(label: Text("Mutabaah")),
              DataColumn(label: Text("Rata-rata")),
              DataColumn(label: Text("Predikat")),
            ],
            rows: allSantri.map((santri) {
              double tahsinAvg = (totalScores[santri]?["Tahsin"] ?? 0) /
                  (countScores[santri]?["Tahsin"] ?? 1);
              double tahfidzAvg = (totalScores[santri]?["Tahfidz"] ?? 0) /
                  (countScores[santri]?["Tahfidz"] ?? 1);
              double mutabaahAvg = (totalScores[santri]?["Mutabaah"] ?? 0) /
                  (countScores[santri]?["Mutabaah"] ?? 1);

              double totalAvg = (tahsinAvg + tahfidzAvg + mutabaahAvg) / 3;
              String predikat = getPredikat(totalAvg);

              return DataRow(cells: [
                DataCell(Text(santri)),
                DataCell(Text(tahsinAvg.toStringAsFixed(1))),
                DataCell(Text(tahfidzAvg.toStringAsFixed(1))),
                DataCell(Text(mutabaahAvg.toStringAsFixed(1))),
                DataCell(Text(totalAvg.toStringAsFixed(1))),
                DataCell(Text(predikat)),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class RekapTugas extends StatefulWidget {
  final String session;
  final String category;
  final DateTime selectedDate; // Add this line

  RekapTugas({required this.session, required this.category, required this.selectedDate}); // Update constructor

  @override
  _RekapTugasState createState() => _RekapTugasState();
}

class _RekapTugasState extends State<RekapTugas> {
  Map<String, String> scores = {};

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString(
        "scores_${widget.session}_${widget.category}_${widget.selectedDate.toIso8601String()}");

    if (savedData != null) {
      setState(() {
        scores = Map<String, String>.from(jsonDecode(savedData));
      });
    }
  }

  // Helper method to filter scores by session and category
  Map<String, String> getFilteredScores() {
    // Already filtered by session and category when loading
    return scores;
  }

  // Helper method to extract santri name from the key
  String getSantriName(String key) {
    List<String> parts = key.split("_");
    return parts.length >= 3 ? parts[2] : key;
  }

  // Helper method to extract activity details from the key
  String getActivityDetails(String key) {
    List<String> parts = key.split("_");
    if (parts.length > 3) {
      // Get all parts after santri name to represent the activity details
      return parts.sublist(3).join(" ");
    }
    return "";
  }

  String formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final filteredScores = getFilteredScores();
    final hasData = filteredScores.isNotEmpty;
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Rekap ${widget.category} - ${widget.session}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tanggal: ${formatDate(widget.selectedDate)}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Sesi: ${widget.session} - Kategori: ${widget.category}",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            hasData ? Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text("Santri", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Aktivitas", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Nilai", style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: filteredScores.entries.map((entry) {
                    return DataRow(cells: [
                      DataCell(Text(getSantriName(entry.key))),
                      DataCell(Text(getActivityDetails(entry.key))),
                      DataCell(Text(
                        entry.value,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: int.tryParse(entry.value) != null && int.parse(entry.value) >= 80 
                              ? Colors.green 
                              : (int.tryParse(entry.value) != null && int.parse(entry.value) < 60 
                                  ? Colors.red 
                                  : Colors.black)
                        ),
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ) : Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "Tidak ada data untuk ${widget.category} pada sesi ${widget.session}",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RekapHarianSesi extends StatefulWidget {
  final DateTime selectedDate;

  RekapHarianSesi({required this.selectedDate});

  @override
  _RekapHarianSesiState createState() => _RekapHarianSesiState();
}

class _RekapHarianSesiState extends State<RekapHarianSesi> {
  final List<String> sessions = ["Siang", "Sore", "Malam"];
  final List<String> categories = ["Tahsin", "Tahfidz", "Mutabaah"];
  final List<String> allSantri = ["Ahmad", "Ali", "Fatimah", "Zaid"];
  
  Map<String, Map<String, Map<String, String>>> allScores = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllScores();
  }

  Future<void> _loadAllScores() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, Map<String, Map<String, String>>> result = {};

    // Initialize the nested map structure
    for (String santri in allSantri) {
      result[santri] = {};
      for (String session in sessions) {
        result[santri]![session] = {};
        for (String category in categories) {
          result[santri]![session]![category] = "-";
        }
      }
    }

    // Load data for each session and category
    for (String session in sessions) {
      for (String category in categories) {
        String? savedData = prefs.getString(
            "scores_${session}_${category}_${widget.selectedDate.toIso8601String()}");
        
        if (savedData != null) {
          Map<String, dynamic> sessionScores = jsonDecode(savedData);
          
          sessionScores.forEach((key, value) {
            List<String> parts = key.split("_");
            if (parts.length >= 3) {
              String santri = parts[2];
              if (allSantri.contains(santri)) {
                result[santri]?[session]?[category] = value.toString();
              }
            }
          });
        }
      }
    }

    setState(() {
      allScores = result;
      isLoading = false;
    });
  }

  String formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  // Calculate average for a santri across all categories in a session
  String calculateSessionAverage(String santri, String session) {
    int total = 0;
    int count = 0;
    
    categories.forEach((category) {
      String scoreStr = allScores[santri]?[session]?[category] ?? "-";
      if (scoreStr != "-") {
        total += int.tryParse(scoreStr) ?? 0;
        count++;
      }
    });
    
    if (count == 0) return "-";
    return (total / count).toStringAsFixed(1);
  }

  // Calculate daily average for a santri across all sessions
  String calculateDailyAverage(String santri) {
    int total = 0;
    int count = 0;
    
    sessions.forEach((session) {
      categories.forEach((category) {
        String scoreStr = allScores[santri]?[session]?[category] ?? "-";
        if (scoreStr != "-") {
          total += int.tryParse(scoreStr) ?? 0;
          count++;
        }
      });
    });
    
    if (count == 0) return "-";
    return (total / count).toStringAsFixed(1);
  }

  String getPredikat(String averageStr) {
    if (averageStr == "-") return "-";
    
    double average = double.tryParse(averageStr) ?? 0;
    if (average >= 90) return "Istimewa";
    if (average >= 80) return "Baik Sekali";
    if (average >= 70) return "Baik";
    if (average >= 60) return "Cukup";
    return "Kurang";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rekap Harian Semua Sesi"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tanggal: ${formatDate(widget.selectedDate)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            isLoading 
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text("Santri", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Sesi", style: TextStyle(fontWeight: FontWeight.bold))),
                          ...categories.map((category) => 
                            DataColumn(label: Text(category, style: TextStyle(fontWeight: FontWeight.bold)))
                          ).toList(),
                          DataColumn(label: Text("Rata-rata", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: [
                          for (String santri in allSantri)
                            for (String session in sessions)
                              DataRow(
                                cells: [
                                  // Show santri name only for the first session row
                                  DataCell(
                                    session == sessions.first 
                                      ? Text(santri, style: TextStyle(fontWeight: FontWeight.bold))
                                      : Text("")
                                  ),
                                  // Session name
                                  DataCell(Text(session)),
                                  // Category scores
                                  ...categories.map((category) {
                                    final score = allScores[santri]?[session]?[category] ?? "-";
                                    Color textColor = Colors.black;
                                    if (score != "-") {
                                      int scoreValue = int.tryParse(score) ?? 0;
                                      if (scoreValue >= 80) {
                                        textColor = Colors.green;
                                      } else if (scoreValue < 60) {
                                        textColor = Colors.red;
                                      }
                                    }
                                    return DataCell(Text(
                                      score, 
                                      style: TextStyle(color: textColor, fontWeight: FontWeight.w500)
                                    ));
                                  }).toList(),
                                  // Session average
                                  DataCell(Text(
                                    calculateSessionAverage(santri, session),
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                  )),
                                ],
                              ),
                          // Add a summary row for each santri with daily average and predikat
                          for (String santri in allSantri)
                            DataRow(
                              color: MaterialStateProperty.all(Colors.grey[200]),
                              cells: [
                                DataCell(Text(santri, style: TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(Text("Rata-rata Harian", style: TextStyle(fontWeight: FontWeight.bold))),
                                ...categories.map((_) => DataCell(Text(""))).toList(),
                                DataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        calculateDailyAverage(santri),
                                        style: TextStyle(fontWeight: FontWeight.bold)
                                      ),
                                      Text(
                                        getPredikat(calculateDailyAverage(santri)),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.blue[700]
                                        )
                                      ),
                                    ],
                                  )
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
