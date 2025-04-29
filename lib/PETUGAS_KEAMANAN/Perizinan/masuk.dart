import 'package:aplikasi_guru/ANIMASI/shimmer_loading.dart';
import 'package:aplikasi_guru/data/test_data.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromLocal();
    _searchController.addListener(_applyFilters);
  }

  Future<void> _loadDataFromLocal() async {
    try {
      setState(() => _isLoading = true);
      List<Map<String, dynamic>> allData = await TestData.getAllData();
      
      setState(() {
        // Only show students with status 'Keluar' and not yet returned
        _izinList = allData
            .where((data) => 
                data['status'] == 'Keluar' && 
                data['isKembali'] == false)
            .toList();
        _izinList.sort((a, b) => 
            (b['waktuKeluar'] ?? '').compareTo(a['waktuKeluar'] ?? ''));
        _filteredIzinList = List.from(_izinList);
      });
    } catch (e) {
      print('Error loading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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

  void _toggleKembali(int index) async {
    setState(() {
      _filteredIzinList[index]['isKembali'] =
          !_filteredIzinList[index]['isKembali'];
    });
  }

  Future<void> _saveAndReturn() async {
    try {
      final returnedStudents = _filteredIzinList
          .where((data) => data['isKembali'] == true)
          .toList();

      if (returnedStudents.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pilih minimal satu santri terlebih dahulu')),
        );
        return;
      }

      List<Map<String, dynamic>> allData = await TestData.getAllData();

      // Update status for returned students
      for (var returnedStudent in returnedStudents) {
        int index = allData.indexWhere((data) => 
            data['id'] == returnedStudent['id']);
            
        if (index != -1) {
          allData[index] = {
            ...allData[index],
            'status': 'Masuk',
            'isKembali': true,
            'waktuMasuk': DateTime.now().toIso8601String(),
          };
        }
      }

      // Save updated data
      await TestData.updateData(allData);

      // Remove processed items from current list
      setState(() {
        _izinList.removeWhere((data) => 
          returnedStudents.any((student) => student['id'] == data['id']));
        _filteredIzinList = List.from(_izinList);
      });
        
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data berhasil disimpan ke riwayat perizinan')),
      );

    } catch (e) {
      print('Error saving data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    }
  }

  Widget _buildListView() {
    if (_isLoading) {
      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 5, // Show 5 shimmer items
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: ShimmerLoading(height: 120),
          );
        },
      );
    }

    return _filteredIzinList.isEmpty
        ? Center(
            child: Text('Tidak ada santri yang sedang keluar',
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
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Color(0xFF2E3F7F),
          elevation: 0,
          title: Text(
            'Daftar Santri Keluar',
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
            child: _buildListView(),
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
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    bool hasSelectedStudents = _filteredIzinList.any(
                        (student) => student['isKembali'] == true);
                    if (!hasSelectedStudents) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Pilih minimal satu santri terlebih dahulu')),
                      );
                      return;
                    }

                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Konfirmasi'),
                          content: Text('Apakah Anda yakin ingin menyimpan data santri yang telah kembali?'),
                          actions: [
                            TextButton(
                              child: Text('Batal'),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            TextButton(
                              child: Text('Ya'),
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm == true) {
                      await _saveAndReturn();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Simpan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
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
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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


