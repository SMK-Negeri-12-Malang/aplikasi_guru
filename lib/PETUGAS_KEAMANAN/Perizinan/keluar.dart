import 'package:aplikasi_guru/ANIMASI/shimmer_loading.dart';
import 'package:aplikasi_guru/ANIMASI/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_guru/data/test_data.dart';


class KeluarPage extends StatefulWidget {
  @override
  _KeluarPageState createState() => _KeluarPageState();
}

class _KeluarPageState extends State<KeluarPage> {
  List<Map<String, dynamic>> _dataPerizinan = [];
  List<Map<String, dynamic>> _filteredDataPerizinan = [];
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
      final prefs = await SharedPreferences.getInstance();
      List<String> dataJson = prefs.getStringList('perizinan_data') ?? [];
      
      if (dataJson.isEmpty) {
        await TestData.resetTestData();
        dataJson = prefs.getStringList('perizinan_data') ?? [];
      }
      
      setState(() {
        _dataPerizinan = dataJson
            .map((str) => json.decode(str) as Map<String, dynamic>)
            .toList()
            .where((data) => data['status'] == 'Diperiksa' || 
                           data['status'] == 'Ditolak' ||
                           data['status'] == 'Diizinkan')
            .toList();
        _filteredDataPerizinan = List.from(_dataPerizinan);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredDataPerizinan = _dataPerizinan.where((data) {
        final matchesName = data['nama']!
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
        final matchesKelas = _selectedKelas == null ||
            data['kelas'] == _selectedKelas;
        final matchesDate = _selectedDate == null ||
            data['tanggalIzin'] == _selectedDate;
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

  Future<void> _updateStatus(Map<String, dynamic> data) async {
    if (data['status'] != 'Diizinkan') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Santri belum diizinkan untuk keluar')),
      );
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi'),
          content: Text('Apakah Anda yakin ingin mengeluarkan santri ini?'),
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

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> allDataJson = prefs.getStringList('perizinan_data') ?? [];
    List<Map<String, dynamic>> allData = allDataJson
        .map((str) => json.decode(str) as Map<String, dynamic>)
        .toList();

    int index = allData.indexWhere((item) => 
        item['nama'] == data['nama'] && 
        item['timestamp'] == data['timestamp']);

    if (index != -1) {
      allData[index]['status'] = 'Keluar';
      allData[index]['waktuKeluar'] = DateTime.now().toIso8601String();
      await prefs.setStringList('perizinan_data',
          allData.map((data) => json.encode(data)).toList());
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status santri berhasil diupdate ke Keluar')),
      );
      
      _loadDataFromLocal();
    }
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
            'Daftar Perizinan Santri',
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
          // Filter Section
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
                        controller: TextEditingController(text: _selectedDate ?? ''),
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

          // List Section
          Expanded(
            child: _buildListContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent() {
    if (_isLoading) {
      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: ShimmerLoading(height: 120),
          );
        },
      );
    }

    return _filteredDataPerizinan.isEmpty
        ? Center(
            child: Text('Tidak ada data perizinan',
                style: TextStyle(fontSize: 16)),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _filteredDataPerizinan.length,
            itemBuilder: (context, index) {
              final data = _filteredDataPerizinan[index];
              return _buildPerizinanCard(data);
            },
          );
  }

  Widget _buildPerizinanCard(Map<String, dynamic> data) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          data['nama'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kamar: ${data['kamar']} | Kelas: ${data['kelas']}'),
            Text('Keperluan: ${data['keperluan']}'),
            Text('Status: ${data['status']}',
                style: TextStyle(
                  color: data['status'] == 'Diizinkan' ? Colors.green : 
                         data['status'] == 'Ditolak' ? Colors.red : Colors.orange,
                  fontWeight: FontWeight.bold
                )),
            Text('Tanggal Izin: ${data['tanggalIzin']}'),
          ],
        ),
        trailing: data['status'] == 'Diizinkan' 
          ? ElevatedButton(
              onPressed: () => _updateStatus(data),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Keluar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          : Icon(
              data['status'] == 'Ditolak' ? Icons.block : Icons.pending,
              color: data['status'] == 'Ditolak' ? Colors.red : Colors.orange,
            ),
        onTap: () => _showDetailDialog(data),
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Perizinan'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Nama', data['nama']),
              _buildDetailRow('Kamar', data['kamar']),
              _buildDetailRow('Kelas', data['kelas']),
              _buildDetailRow('Halaqoh', data['halaqoh']),
              _buildDetailRow('Musyrif', data['musyrif']),
              _buildDetailRow('Keperluan', data['keperluan']),
              _buildDetailRow('Tanggal Izin', data['tanggalIzin']),
              _buildDetailRow('Tanggal Kembali', data['tanggalKembali']),
              _buildDetailRow('Status', data['status']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
