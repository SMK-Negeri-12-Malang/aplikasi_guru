import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  String selectedSession = 'Sesi 1';
  String selectedDate = '2025-03-28';
  String selectedLevel = 'SMP';

  final List<String> sessions = ['Sesi 1', 'Sesi 2', 'Sesi 3'];
  final List<String> dates = ['2025-03-28', '2025-03-29', '2025-03-30'];
  final List<String> levels = ['SMP', 'SMA'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kepesantrenan'),
      ),
      body: Column(
        children: [
          // Dropdowns
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Dropdown for Session
                DropdownButton<String>(
                  value: selectedSession,
                  items: sessions.map((String session) {
                    return DropdownMenuItem<String>(
                      value: session,
                      child: Text(session),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSession = newValue!;
                    });
                  },
                ),
                // Dropdown for Date
                DropdownButton<String>(
                  value: selectedDate,
                  items: dates.map((String date) {
                    return DropdownMenuItem<String>(
                      value: date,
                      child: Text(date),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDate = newValue!;
                    });
                  },
                ),
                // Dropdown for Level
                DropdownButton<String>(
                  value: selectedLevel,
                  items: levels.map((String level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedLevel = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          // PageView
          Expanded(
            child: PageView(
              children: [
                Center(child: Text('Halaman 1')),
                Center(child: Text('Halaman 2')),
                Center(child: Text('Halaman 3')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}