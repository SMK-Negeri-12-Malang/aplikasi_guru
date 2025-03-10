import 'package:flutter/material.dart';
import 'tabel_tugas.dart'; // Import tabel_tugas.dart
import 'package:shared_preferences/shared_preferences.dart';

class TugasPage extends StatefulWidget {
  @override
  _TugasPageState createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> {
  int _selectedSesi = 0;
  String? _selectedCategory;
  final List<String> categories = ["Tahsin", "Tahfidz", "Mutabaah"];
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadPagePosition();
  }

  Future<void> _savePagePosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedSesi', _selectedSesi);
  }

  Future<void> _loadPagePosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSesi = prefs.getInt('selectedSesi') ?? 0;
      _pageController.jumpToPage(_selectedSesi);
    });
  }

  @override
  Widget build(BuildContext context) {
    String sesi = ["Siang", "Sore", "Malam"][_selectedSesi];

    return Scaffold(
      // 🔹 AppBar dengan Gradient & Title Tengah
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Tinggi AppBar
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)], // Warna gradasi
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent, // Agar mengikuti gradient
            elevation: 0, // Hilangkan shadow
            centerTitle: true, // 🔹 Title ada di tengah
            title: Text(
              "Tugas Santri",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),

      backgroundColor: Colors.white,
      body: Column(
        children: [
          // **📌 PageView Sesi dengan Background Biru**
          Container(
            height: 120,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedSesi = index;
                });
                _savePagePosition();
              },
              itemCount: 3,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      value = (1 - (value.abs() * 0.3)).clamp(0.85, 1.0);
                    }
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            ["Siang", "Sore", "Malam"][index],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black45,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // **📌 Dropdown Kategori**
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: "Pilih Kategori",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.category, color: Colors.blue),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              items: categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ))
                  .toList(),
            ),
          ),

          // **📌 Tabel Data Tugas**
          Expanded(
            child: _selectedCategory == null
                ? Center(child: Text("Silakan pilih kategori"))
                : TabelTugas(session: sesi, category: _selectedCategory!),
          ),
        ],
      ),
    );
  }
}
