import 'package:aplikasi_guru/MUSYRIF/Tugas/riwayat_mutabaah.dart';
import 'package:flutter/material.dart';
import 'tabel_mutabaah.dart'; // Update import
import 'package:shared_preferences/shared_preferences.dart';

class TugasPage extends StatefulWidget {
  @override
  _TugasPageState createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> {
  int _selectedSesi = 0;
  final List<String> sessions = ["Pagi", "Sore", "Malam"];
  final PageController _pageController = PageController();
  DateTime selectedDate = DateTime.now();
  String searchQuery = ""; // Add search query state variable
  final GlobalKey<TabelMutabaahState> _tabelKey = GlobalKey<TabelMutabaahState>();

  @override
  void initState() {
    super.initState();
    _loadPagePosition();
  }

  Future<void> _savePagePosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedSesi', _selectedSesi);
    await prefs.setString('selectedDate', selectedDate.toIso8601String());
  }

  Future<void> _loadPagePosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSesi = prefs.getInt('selectedSesi') ?? 0;
      _pageController.jumpToPage(_selectedSesi);
      selectedDate = DateTime.parse(
          prefs.getString('selectedDate') ?? DateTime.now().toIso8601String());
    });
  }

  void _resetScores() {
    // Renamed but kept for compatibility
    setState(() {});
  }

  void _handleSaveComplete(bool success) {
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data mutabaah berhasil disimpan'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showSaveConfirmation() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.save, color: const Color(0xFF2E3F7F)),
              SizedBox(width: 8),
              Text('Konfirmasi Simpan'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Apakah Anda yakin ingin menyimpan perubahan?'),
              SizedBox(height: 12),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _tabelKey.currentState?.saveMutabaahData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E3F7F),
                foregroundColor: Colors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check),
                  SizedBox(width: 8),
                  Text('Ya, Simpan'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 15,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mutabaah Santri',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Catat aktivitas santri',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<int>(
                        value: _selectedSesi,
                        decoration: InputDecoration(
                          labelText: "Pilih Sesi",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        items: List.generate(sessions.length, (index) => 
                          DropdownMenuItem(
                            value: index,
                            child: Text(
                              sessions[index],
                              style: TextStyle(fontWeight: FontWeight.bold)
                            ),
                          )
                        ),
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedSesi = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Pilih Tanggal",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null && pickedDate != selectedDate) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        controller: TextEditingController(
                          text: "${selectedDate.toLocal()}".split(' ')[0],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Cari Nama Santri",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    suffixIcon: Icon(Icons.search, size: 20),
                    hintText: "Masukkan nama santri",
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: TabelMutabaah(
              key: _tabelKey,
              session: sessions[_selectedSesi],
              selectedDate: selectedDate,
              searchQuery: searchQuery,
              onSaveComplete: _handleSaveComplete,
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 7, // Takes up 70% of the space
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RekapHarian()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E3F7F),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      'Riwayat Mutabaah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 3, // Takes up 30% of the space
                  child: ElevatedButton(
                    onPressed: _showSaveConfirmation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Icon(
                      Icons.save,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
