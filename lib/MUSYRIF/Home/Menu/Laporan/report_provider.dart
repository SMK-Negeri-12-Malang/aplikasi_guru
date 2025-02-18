import 'package:flutter/material.dart';

class ReportProvider with ChangeNotifier {
  final Map<String, List<Map<String, dynamic>>> _reportsPerKelas = {};

  Map<String, List<Map<String, dynamic>>> get reportsPerKelas => _reportsPerKelas;

  void addReport(Map<String, dynamic> report) {
    if (_reportsPerKelas.containsKey(report['kelas'])) {
      _reportsPerKelas[report['kelas']]!.add(report);
    } else {
      _reportsPerKelas[report['kelas']] = [report];
    }
    notifyListeners();
  }
}
