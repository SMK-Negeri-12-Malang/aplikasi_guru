import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime? selectedDate;
  DateTime? returnDate;
  String? selectedName;
  TextEditingController nameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController returnDateController = TextEditingController();

  Map<String, Map<String, String>> studentData = {
    'Ahmad': {'kelas': '10A', 'kamar': 'A1', 'halaqo': 'H1', 'musryf': 'Ust. Ali'},
    'Budi': {'kelas': '10B', 'kamar': 'B2', 'halaqo': 'H2', 'musryf': 'Ust. Hasan'},
    'Citra': {'kelas': '11A', 'kamar': 'C3', 'halaqo': 'H3', 'musryf': 'Ust. Yusuf'},
  };

  Map<String, int> permissionCount = {
    'Ahmad': 2,
    'Budi': 1,
    'Citra': 3,
  };

  String kelas = '';
  String kamar = '';
  String halaqo = '';
  String musryf = '';

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _selectReturnDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: selectedDate ?? DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != returnDate) {
      setState(() {
        returnDate = picked;
        returnDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _onNameSelected(String name) {
    setState(() {
      selectedName = name;
      nameController.text = name;
      kelas = studentData[name]?['kelas'] ?? '';
      kamar = studentData[name]?['kamar'] ?? '';
      halaqo = studentData[name]?['halaqo'] ?? '';
      musryf = studentData[name]?['musryf'] ?? '';
    });
  }

  void _submitPermission() {
    if (selectedName != null && selectedDate != null && returnDate != null) {
      // Handle submission
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perizinan berhasil disubmit')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi semua field termasuk tanggal kembali')),
      );
    }
  }

  int calculateDays(DateTime startDate, DateTime endDate) {
    return endDate.difference(startDate).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Halaman Izin Siswa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                return studentData.keys.where(
                  (option) => option.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ),
                );
              },
              onSelected: _onNameSelected,
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Nama Siswa',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.all(10),
                  ),
                );
              },
            ),
            SizedBox(height: 10),
            if (selectedName != null)
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Jumlah izin semester ini: ${permissionCount[selectedName] ?? 0}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            SizedBox(height: 10),
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'Tanggal Mulai Izin',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.all(10),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 10),
            TextField(
              controller: returnDateController,
              decoration: InputDecoration(
                labelText: 'Tanggal Kembali',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.all(10),
              ),
              readOnly: true,
              onTap: () => _selectReturnDate(context),
            ),
            SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: kelas),
              decoration: InputDecoration(
                labelText: 'Kelas',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.all(10),
              ),
              readOnly: true,
            ),
            SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: kamar),
              decoration: InputDecoration(
                labelText: 'Kamar',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.all(10),
              ),
              readOnly: true,
            ),
            SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: halaqo),
              decoration: InputDecoration(
                labelText: 'Halaqo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.all(10),
              ),
              readOnly: true,
            ),
            SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: musryf),
              decoration: InputDecoration(
                labelText: 'Musyrif',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.all(10),
              ),
              readOnly: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedName != null && selectedDate != null && returnDate != null) {
                  _submitPermission();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Harap isi semua field termasuk tanggal kembali')),
                  );
                }
              },
              child: Text(
                'Kirim',
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 45),
                backgroundColor: Colors.green,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
