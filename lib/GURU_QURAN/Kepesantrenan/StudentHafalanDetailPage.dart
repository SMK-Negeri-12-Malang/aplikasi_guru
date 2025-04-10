import 'package:flutter/material.dart';
import 'SurahSelectionDialog.dart';

class StudentHafalanDetailPage extends StatefulWidget {
  final Map<String, dynamic> student;
  final Map<String, String> existingData;
  final List<String> grades;
  final Function(Map<String, String>) onSave;

  const StudentHafalanDetailPage({
    Key? key,
    required this.student,
    required this.existingData,
    required this.grades,
    required this.onSave,
  }) : super(key: key);

  @override
  State<StudentHafalanDetailPage> createState() => _StudentHafalanDetailPageState();
}

class _StudentHafalanDetailPageState extends State<StudentHafalanDetailPage> {
  late TextEditingController suratController;
  late TextEditingController ayatAwalController;
  late TextEditingController ayatAkhirController;
  late String selectedGrade;

  @override
  void initState() {
    super.initState();
    suratController = TextEditingController(text: widget.existingData['surat'] ?? '');
    ayatAwalController = TextEditingController(text: widget.existingData['ayatAwal'] ?? '');
    ayatAkhirController = TextEditingController(text: widget.existingData['ayatAkhir'] ?? '');
    selectedGrade = widget.existingData['nilai'] ?? widget.grades[0];
  }

  @override
  void dispose() {
    suratController.dispose();
    ayatAwalController.dispose();
    ayatAkhirController.dispose();
    super.dispose();
  }

  void _openSurahSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SurahSelectionDialog(
          onSelect: (String selectedSurah) {
            setState(() {
              suratController.text = selectedSurah;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF1D2842);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Detail Hafalan ${widget.student['name']}'),
        centerTitle: false,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Siswa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Nama', widget.student['name']),
                    _buildInfoRow('Kelas', widget.student['kelas']),
                    _buildInfoRow('Sesi', widget.student['session']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Hafalan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _openSurahSelectionDialog,
                      child: Stack(
                        children: [
                          TextField(
                            controller: suratController,
                            decoration: InputDecoration(
                              labelText: 'Surat',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: Icon(Icons.book, color: primaryColor),
                              suffixIcon: Icon(Icons.arrow_drop_down, color: primaryColor),
                            ),
                            enabled: false,
                          ),
                          Container(
                            height: 56,
                            color: Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ayatAwalController,
                            decoration: InputDecoration(
                              labelText: 'Ayat Awal',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: Icon(Icons.format_list_numbered, color: primaryColor),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: ayatAkhirController,
                            decoration: InputDecoration(
                              labelText: 'Ayat Akhir',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: Icon(Icons.format_list_numbered, color: primaryColor),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Nilai Hafalan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedGrade,
                          items: widget.grades.map((String grade) {
                            return DropdownMenuItem<String>(
                              value: grade,
                              child: Text(grade),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            if (value != null) {
                              setState(() => selectedGrade = value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final updatedData = {
                    'surat': suratController.text,
                    'ayatAwal': ayatAwalController.text,
                    'ayatAkhir': ayatAkhirController.text,
                    'nilai': selectedGrade,
                  };
                  widget.onSave(updatedData);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data hafalan berhasil disimpan'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}