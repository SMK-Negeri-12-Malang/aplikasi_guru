import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class DetailCekSantri extends StatelessWidget {
  final String studentName;
  final String room;
  final String className;
  final String studentId;
  final List<Map<String, dynamic>> progressData;

  DetailCekSantri({
    required this.studentName,
    required this.room,
    required this.className,
    required this.studentId,
    required this.progressData,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController _dateController = TextEditingController();
    String? _selectedSession;
    String? _selectedHalaqoh;

    final List<String> sessions = ["1", "2", "3", "4"];
    final List<String> halaqohs = ["Takhassus 1", "Takhassus 2", "Takhassus 3"];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: Container(
          padding: EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              studentName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student details
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person, size: 40, color: Color(0xFF2E3F7F)),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studentName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.meeting_room, size: 20, color: Colors.white70),
                              SizedBox(width: 8),
                              Text(
                                "Ruang: $room",
                                style: TextStyle(fontSize: 16, color: Colors.white70),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.class_, size: 20, color: Colors.white70),
                              SizedBox(width: 8),
                              Text(
                                "Kelas: $className",
                                style: TextStyle(fontSize: 16, color: Colors.white70),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.badge, size: 20, color: Colors.white70),
                              SizedBox(width: 8),
                              Text(
                                "No. Induk: $studentId",
                                style: TextStyle(fontSize: 16, color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "History Tahfidz",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3F7F),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Pilih Tanggal",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        _dateController.text =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSession,
                    decoration: InputDecoration(
                      labelText: "Pilih Sesi",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    onChanged: (String? newValue) {
                      _selectedSession = newValue;
                    },
                    items: sessions
                        .map((session) => DropdownMenuItem(
                              value: session,
                              child: Text(session,
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedHalaqoh,
              decoration: InputDecoration(
                labelText: "Pilih Halaqoh",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              onChanged: (String? newValue) {
                _selectedHalaqoh = newValue;
              },
              items: halaqohs
                  .map((halaqoh) => DropdownMenuItem(
                        value: halaqoh,
                        child: Text(halaqoh,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ))
                  .toList(),
            ),
            SizedBox(height: 16),
            // Quran progress table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    headingRowColor: MaterialStateColor.resolveWith(
                      (states) => Color(0xFF2E3F7F),
                    ),
                    headingTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    columns: [
                      DataColumn(label: Text('Tanggal')),
                      DataColumn(label: Text('Sesi')),
                      DataColumn(label: Text('Surat')),
                      DataColumn(label: Text('Ayat Awal')),
                      DataColumn(label: Text('Ayat Akhir')),
                      DataColumn(label: Text('Jumlah Baris')),
                      DataColumn(label: Text('Nilai')),
                      DataColumn(label: Text('Ustadz')),
                      DataColumn(label: Text('Halaqoh')),
                    ],
                    rows: progressData.map((data) {
                      return DataRow(cells: [
                        DataCell(Text(data['tanggal'] ?? '-')),
                        DataCell(Text(data['sesi'] ?? '-')),
                        DataCell(Text(data['surat'] ?? '-')),
                        DataCell(Text(data['ayatAwal'] ?? '-')),
                        DataCell(Text(data['ayatAkhir'] ?? '-')),
                        DataCell(Text(data['jumlahBaris']?.toString() ?? '-')),
                        DataCell(Text(data['nilai']?.toString() ?? '-')),
                        DataCell(Text(data['ustadz'] ?? '-')),
                        DataCell(Text(data['halaqoh'] ?? '-')),
                      ]);
                    }).toList(),
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
