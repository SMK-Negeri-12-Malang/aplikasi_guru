import 'package:flutter/material.dart';

class RekapHarian extends StatefulWidget {
  const RekapHarian({super.key});

  @override
  State<RekapHarian> createState() => _RekapHarianState();
}

class _RekapHarianState extends State<RekapHarian> {
  final List<String> sessions = ["Pagi", "Siang", "Sore", "Malam"];
  final List<String> activities = [
    "Tahsin",
    "Tahfidz",
    "Mutabaah",
    "Muhadoroh"
  ];
  final List<String> santriList = [
    "Ahmad",
    "Ali",
    "Fatimah",
    "Zaid",
    "Hamzah",
    "Bilal"
  ];

  // Simulated data - in a real app this would come from a database or SharedPreferences
  Map<String, Map<String, Map<String, double>>> scoreData = {};

  @override
  void initState() {
    super.initState();
    _generateDummyData();
  }

  void _generateDummyData() {
    // Generate random scores for demonstration
    for (var santri in santriList) {
      scoreData[santri] = {};
      for (var session in sessions) {
        scoreData[santri]![session] = {};
        for (var activity in activities) {
          // Generate random score between 50 and 100
          double score =
              50 + (50 * (DateTime.now().millisecondsSinceEpoch % 100) / 100);
          scoreData[santri]![session]![activity] =
              double.parse(score.toStringAsFixed(1));
        }
      }
    }
  }

  // Calculate average score for a santri per session
  double getSessionAverage(String santri, String session) {
    if (!scoreData.containsKey(santri) ||
        !scoreData[santri]!.containsKey(session)) {
      return 0.0;
    }

    double total = 0.0;
    int count = 0;

    scoreData[santri]![session]!.forEach((_, score) {
      total += score;
      count++;
    });

    return count > 0 ? total / count : 0.0;
  }

  // Calculate average score for a santri per activity across all sessions
  double getActivityAverage(String santri, String activity) {
    if (!scoreData.containsKey(santri)) {
      return 0.0;
    }

    double total = 0.0;
    int count = 0;

    scoreData[santri]!.forEach((_, activityMap) {
      if (activityMap.containsKey(activity)) {
        total += activityMap[activity]!;
        count++;
      }
    });

    return count > 0 ? total / count : 0.0;
  }

  // Calculate overall average for a santri
  double getOverallAverage(String santri) {
    if (!scoreData.containsKey(santri)) {
      return 0.0;
    }

    double total = 0.0;
    int count = 0;

    scoreData[santri]!.forEach((_, activityMap) {
      activityMap.forEach((_, score) {
        total += score;
        count++;
      });
    });

    return count > 0 ? total / count : 0.0;
  }

  // Calculate daily average score for a santri per activity
  double getDailyActivityAverage(String santri, String activity) {
    if (!scoreData.containsKey(santri)) {
      return 0.0;
    }

    double total = 0.0;
    int count = 0;

    // Calculate average across all sessions for today
    for (var session in sessions) {
      if (scoreData[santri]!.containsKey(session) &&
          scoreData[santri]![session]!.containsKey(activity)) {
        total += scoreData[santri]![session]![activity]!;
        count++;
      }
    }

    return count > 0 ? total / count : 0.0;
  }

  String getGrade(double score) {
    if (score >= 90) return "Istimewa";
    if (score >= 80) return "Baik";
    if (score >= 70) return "Cukup";
    if (score >= 60) return "Kurang";
    return "Sangat Kurang";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2E3F7F),
        title: const Text(
          "Rekap Nilai Santri",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Rekap Nilai Harian",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DataTable(
                  headingRowColor:
                      MaterialStateProperty.all(const Color(0xFF2E3F7F),),
                  // Fixed dataRowColor implementation
                  dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      // Get the index from the DataRow directly
                      final rowIndex = santriList.indexOf(
                        santriList.firstWhere(
                          (name) => states.contains(MaterialState.selected),
                          orElse: () => santriList[0],
                        ),
                      );

                      // Return alternating colors based on index
                      return rowIndex.isEven
                          ? Colors.grey.shade50
                          : Colors.white;
                    },
                  ),
                  border: TableBorder.all(
                    color: Colors.grey.shade300,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                  columnSpacing: 16,
                  // Header columns
                  columns: [
                    const DataColumn(
                      label: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Santri',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    // Activity columns only (removed session columns)
                    ...activities.map((activity) => DataColumn(
                          label: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              activity,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        )),
                    const DataColumn(
                      label: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Rata-rata',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const DataColumn(
                      label: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Grade',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                  rows: List.generate(
                    santriList.length,
                    (index) {
                      final santri = santriList[index];
                      // Calculate overall average for this santri
                      double overallAvg = getOverallAverage(santri);
                      String grade = getGrade(overallAvg);

                      return DataRow(
                        // Set color based on index instead of using the callback
                        color: MaterialStateProperty.all(
                            index.isEven ? Colors.grey.shade50 : Colors.white),
                        cells: [
                          // Santri name
                          DataCell(
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                santri,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          // Daily activity averages (instead of overall activity averages)
                          ...activities.map((activity) {
                            double activityAvg =
                                getDailyActivityAverage(santri, activity);
                            return DataCell(
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: Text(
                                  activityAvg.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }),
                          // Overall average
                          DataCell(
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              child: Text(
                                overallAvg.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // Grade
                          DataCell(
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              child: Text(
                                grade,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
