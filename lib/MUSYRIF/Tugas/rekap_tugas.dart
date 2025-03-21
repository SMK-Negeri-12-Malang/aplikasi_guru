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
  Map<String, Map<String, int>> totalScores =
      {}; // Map untuk menyimpan total skor
  Map<String, Map<String, int>> countScores =
      {}; // Map untuk menyimpan jumlah entri skor

  @override
  void initState() {
    super.initState();
    _loadRekapData();
  }

  Future<void> _loadRekapData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, Map<String, int>> scores = {}; // Skor total per santri
    Map<String, Map<String, int>> counts =
        {}; // Jumlah tugas yang dinilai per santri

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

            scores[santri]
                ?.update(category, (val) => val + score, ifAbsent: () => score);
            counts[santri]
                ?.update(category, (val) => val + 1, ifAbsent: () => 1);
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

  RekapTugas(
      {required this.session,
      required this.category,
      required this.selectedDate}); // Update constructor

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rekap Tugas"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: scores.entries.map((entry) {
            return ListTile(
              title: Text(entry.key),
              trailing: Text(entry.value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
