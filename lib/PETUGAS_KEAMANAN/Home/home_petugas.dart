import 'dart:io';
import 'dart:ui';
import 'package:aplikasi_guru/PETUGAS_KEAMANAN/profil/profil.dart';
import 'package:aplikasi_guru/PETUGAS_KEAMANAN/Perizinan/masuk.dart';
import 'package:aplikasi_guru/PETUGAS_KEAMANAN/Perizinan/keluar.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HomePetugas extends StatefulWidget {
  @override
  _HomePetugasState createState() => _HomePetugasState();
}

class _HomePetugasState extends State<HomePetugas> {
  String _name = 'Nama Petugas';
  String _email = 'email@domain.com';
  String? _profileImagePath;
  List<Map<String, dynamic>> _dataPerizinan = [];
  List<Map<String, dynamic>> _filteredDataPerizinan = [];
  List<Map<String, dynamic>> _newsList = [];
  final TextEditingController _searchController = TextEditingController();
  String? _selectedKelas;
  String? _selectedDate;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDataFromLocal();
    _searchController.addListener(_applyFilters);
  }

  Future<void> _loadDataFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> dataJson = prefs.getStringList('perizinan_data') ?? [];
    
    setState(() {
      _dataPerizinan = dataJson
          .map((str) => json.decode(str) as Map<String, dynamic>)
          .toList();
      // Sort by timestamp to show newest first
      _dataPerizinan.sort((a, b) => 
          (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));
      _filteredDataPerizinan = List.from(_dataPerizinan);
      _applyFilters();
    });
  }

  Future<void> _updateLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> updatedDataJson = _dataPerizinan
        .map((data) => json.encode(data))
        .toList();
    await prefs.setStringList('perizinan_data', updatedDataJson);
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

  void _navigateToProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => profilsatpam(),
      ),
    );
  }

  void _navigateToMasukPage() async {
    if (_dataPerizinan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak ada data perizinan')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MasukPage(izinList: _dataPerizinan),
      ),
    );
    if (result != null) {
      setState(() {
        for (var returnedStudent in result) {
          int index = _dataPerizinan.indexWhere(
              (data) => data['nama'] == returnedStudent['nama']);
          if (index != -1) {
            _dataPerizinan[index]['status'] = 'Masuk';
            _dataPerizinan[index]['isKembali'] = true;
          }
        }
        _filteredDataPerizinan = List.from(_dataPerizinan);
        _applyFilters();
      });
      await _updateLocalStorage(); // Save changes to local storage
    }
  }

  void _navigateToKeluarPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => KeluarPage()),
    );
    if (result != null) {
      // Reload data from SharedPreferences after new data is added
      await _loadDataFromLocal();
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      _navigateToMasukPage();
    } else if (index == 1) {
      _navigateToKeluarPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2E3F7F),
              const Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    children: [
                      _buildProfileSection(),
                      SizedBox(height: 20),
                      _buildBeritaSection(),
                      SizedBox(height: 20),
                      _buildPerizinanSection(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _navigateToMasukPage(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentIndex == 0
                        ? const Color.fromARGB(255, 33, 93, 153)
                        : Colors.white,
                    foregroundColor: _currentIndex == 0
                        ? Colors.white
                        : const Color.fromARGB(255, 33, 93, 153),
                    side: BorderSide(
                      color: const Color.fromARGB(255, 33, 93, 153),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Masuk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _navigateToKeluarPage(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentIndex == 1
                        ? const Color.fromARGB(255, 33, 93, 153)
                        : Colors.white,
                    foregroundColor: _currentIndex == 1
                        ? Colors.white
                        : const Color.fromARGB(255, 33, 93, 153),
                    side: BorderSide(
                      color: const Color.fromARGB(255, 33, 93, 153),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Keluar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: EdgeInsets.only(
          top: 50, left: 20, right: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: _navigateToProfilePage,
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    backgroundImage: _profileImagePath != null
                        ? FileImage(File(_profileImagePath!))
                        : AssetImage('assets/profile_picture.png') as ImageProvider,
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _email,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeritaSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Berita',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          // Handle add news action
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _newsList.isEmpty
                      ? Container(
                          height: 120,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 50,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Belum ada berita',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 200,
                          child: PageView.builder(
                            itemCount: _newsList.length,
                            itemBuilder: (context, index) {
                              final news = _newsList[index];
                              return _buildNewsCard(news);
                            },
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> news) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E3F7F),
            Color.fromARGB(255, 117, 127, 170),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Row(
            children: [
              Container(
                width: 120,
                height: 120,
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    news['image'],
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news['judul'],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          news['deskripsi'],
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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

  Widget _buildPerizinanSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Data Perizinan Santri',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),
          SizedBox(height: 10),
          Divider(
            color: Colors.white70,
            thickness: 1.5,
          ),
          SizedBox(height: 10),
          _buildFilterSection(),
          SizedBox(height: 10),
          _filteredDataPerizinan.isEmpty
              ? Container(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: const Color.fromARGB(255, 153, 153, 153).withOpacity(0.8),
                          size: 50,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Belum ada data',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 153, 153, 153).withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _filteredDataPerizinan.length,
                  itemBuilder: (context, index) {
                    final data = _filteredDataPerizinan[index];
                    return _buildPerizinanCard(data);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedKelas = newValue;
                      _applyFilters();
                    });
                  },
                  items: ['Kelas 1', 'Kelas 2', 'Kelas 3']
                      .map((kelas) => DropdownMenuItem(
                            value: kelas,
                            child: Text(kelas, style: TextStyle(fontWeight: FontWeight.bold)),
                          ))
                      .toList(),
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              suffixIcon: Icon(Icons.search, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerizinanCard(Map<String, dynamic> data) {
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
          data['status'] == 'Masuk' ? Icons.check_circle : Icons.pending,
          color: data['status'] == 'Masuk' ? Colors.green : Colors.orange,
        ),
        onTap: () => _showBottomSheet(data),
      ),
    );
  }

  void _showBottomSheet(Map<String, dynamic> data) {
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
}

// Profile page class (simplified implementation)
class ProfilePetugasPage extends StatelessWidget {
  final String name;
  final String email;
  final String? profileImagePath;

  const ProfilePetugasPage({
    Key? key,
    required this.name,
    required this.email,
    this.profileImagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Petugas'),
        backgroundColor: Color(0xFF2E3F7F),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2E3F7F),
              const Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: profileImagePath != null
                    ? FileImage(File(profileImagePath!))
                    : AssetImage('assets/profile_picture.png') as ImageProvider,
              ),
              SizedBox(height: 20),
              Text(
                name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                email,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Implement edit profile functionality
                },
                child: Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
