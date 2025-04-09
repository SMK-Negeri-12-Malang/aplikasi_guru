import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'history.dart';

class MasukPage extends StatefulWidget {
  final List<Map<String, dynamic>> izinList;

  MasukPage({required this.izinList});

  @override
  _MasukPageState createState() => _MasukPageState();
}

class _MasukPageState extends State<MasukPage> {
  late List<Map<String, dynamic>> _izinList;
  late List<Map<String, dynamic>> _filteredIzinList;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedKelas;
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    _izinList = widget.izinList
        .where((data) => data['status'] == 'Keluar')
        .map((data) => Map<String, dynamic>.from(data))
        .toList();
    _filteredIzinList = List.from(_izinList);
    _searchController.addListener(_applyFilters);
  }

  void _applyFilters() {
    setState(() {
      _filteredIzinList = _izinList.where((data) {
        final matchesName = data['nama']!
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
        final matchesKelas = _selectedKelas == null ||
            data['kelas'] == _selectedKelas;
        final matchesDate = _selectedDate == null ||
            data['tanggalIzin'] == _selectedDate ||
            data['tanggalKembali'] == _selectedDate;
        return matchesName && matchesKelas && matchesDate;
      }).toList();
    });
  }

  void _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = "${picked.day}-${picked.month}-${picked.year}";
        _applyFilters();
      });
    }
  }

  void _toggleKembali(int index) {
    setState(() {
      _filteredIzinList[index]['isKembali'] =
          !_filteredIzinList[index]['isKembali'];
    });
  }

  void _saveAndReturn() async {
    final returnedStudents = _filteredIzinList
        .where((data) => data['isKembali'] == true)
        .map((data) => Map<String, dynamic>.from(data))
        .toList();

    final prefs = await SharedPreferences.getInstance();
    List<String> allDataJson = prefs.getStringList('perizinan_data') ?? [];
    List<Map<String, dynamic>> allData = allDataJson
        .map((str) => json.decode(str) as Map<String, dynamic>)
        .toList();

    for (var returnedStudent in returnedStudents) {
      int index =
          allData.indexWhere((data) => data['nama'] == returnedStudent['nama']);
      if (index != -1) {
        allData[index]['status'] = 'Masuk';
        allData[index]['isKembali'] = true;
      }
    }

    await prefs.setStringList('perizinan_data',
        allData.map((data) => json.encode(data)).toList());

    Navigator.pop(context, returnedStudents);
  }

  void _loadDataFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> allDataJson = prefs.getStringList('perizinan_data') ?? [];
    List<Map<String, dynamic>> allData = allDataJson
        .map((str) => json.decode(str) as Map<String, dynamic>)
        .toList();

    setState(() {
      _izinList = allData
          .where((data) => data['status'] == 'Keluar')
          .map((data) => Map<String, dynamic>.from(data))
          .toList();
      _filteredIzinList = List.from(_izinList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Color(0xFF2E3F7F),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _saveAndReturn,
          ),
          title: Text(
            'Daftar Santri Izin',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
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
                      child: DropdownButtonFormField<String>(
                        value: _selectedKelas,
                        decoration: InputDecoration(
                          labelText: "Pilih Kelas",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: ['Kelas 1', 'Kelas 2', 'Kelas 3']
                            .map((kelas) => DropdownMenuItem(
                                  value: kelas,
                                  child: Text(kelas),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedKelas = value;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Pilih Tanggal",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onTap: () => _selectDate(context),
                        controller: TextEditingController(
                          text: _selectedDate ?? '',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: "Cari Nama Santri",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredIzinList.isEmpty
                ? Center(
                    child: Text('Tidak ada santri yang sedang izin',
                        style: TextStyle(fontSize: 16)),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _filteredIzinList.length,
                    itemBuilder: (context, index) {
                      final izin = _filteredIzinList[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CheckboxListTile(
                          value: izin['isKembali'] ?? false,
                          onChanged: (_) => _toggleKembali(index),
                          title: Text(
                            izin['nama'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Kamar: ${izin['kamar']} | Kelas: ${izin['kelas']}'),
                              Text('Keperluan: ${izin['keperluan']}'),
                              Text('Tanggal Izin: ${izin['tanggalIzin']}'),
                              Text('Tanggal Kembali: ${izin['tanggalKembali']}'),
                            ],
                          ),
                          secondary: Icon(
                            izin['isKembali'] == true
                                ? Icons.check_circle
                                : Icons.pending,
                            color: izin['isKembali'] == true
                                ? Colors.green
                                : Colors.orange,
                          ),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryPage()),
              );
              _loadDataFromLocal();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 33, 93, 153),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 20),
                SizedBox(width: 8),
                Text(
                  'Riwayat Perizinan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}


