import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _historyList = [];
  List<Map<String, dynamic>> _filteredHistoryList = [];
  final TextEditingController _searchController = TextEditingController();
  String? _selectedKelas;
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
    _searchController.addListener(_applyFilters);
  }

  Future<void> _loadHistoryData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> dataJson = prefs.getStringList('perizinan_data') ?? [];
    
    setState(() {
      // Only get data with status 'Masuk'
      _historyList = dataJson
          .map((str) => json.decode(str) as Map<String, dynamic>)
          .where((data) => data['status'] == 'Masuk')
          .toList();
      
      // Sort by timestamp, newest first
      _historyList.sort((a, b) => 
          (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));
      
      _filteredHistoryList = List.from(_historyList);
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredHistoryList = _historyList.where((data) {
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: AppBar(
            backgroundColor: Color(0xFF2E3F7F),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, 
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Riwayat Perizinan',
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
            _buildFilterSection(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Riwayat Perizinan Santri',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3F7F),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(
                      color: Colors.grey[300],
                      thickness: 1.5,
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: _filteredHistoryList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.history,
                                    color: Colors.grey[400],
                                    size: 50,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tidak ada riwayat perizinan',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.only(top: 8),
                              itemCount: _filteredHistoryList.length,
                              itemBuilder: (context, index) {
                                final data = _filteredHistoryList[index];
                                return Card(
                                  margin: EdgeInsets.only(bottom: 10),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      data['nama'] ?? '',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Kamar: ${data['kamar']} | Kelas: ${data['kelas']}'),
                                        Text('Status: ${data['status']}'),
                                        Text('Tanggal Izin: ${data['tanggalIzin']}'),
                                      ],
                                    ),
                                    trailing: Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    onTap: () => _showDetailBottomSheet(context, data),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailBottomSheet(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Detail Perizinan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              _buildDetailRow('Nama', data['nama'] ?? ''),
              _buildDetailRow('Kamar', data['kamar'] ?? ''),
              _buildDetailRow('Kelas', data['kelas'] ?? ''),
              _buildDetailRow('Halaqoh', data['halaqoh'] ?? ''),
              _buildDetailRow('Musyrif', data['musyrif'] ?? ''),
              _buildDetailRow('Keperluan', data['keperluan'] ?? ''),
              _buildDetailRow('Tanggal Izin', data['tanggalIzin'] ?? ''),
              _buildDetailRow('Tanggal Kembali', data['tanggalKembali'] ?? ''),
              _buildDetailRow('Status', data['status'] ?? ''),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E3F7F),
                    minimumSize: Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Tutup',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection() {
    return Padding(
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
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
