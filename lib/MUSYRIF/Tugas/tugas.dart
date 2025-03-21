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
  DateTime selectedDate = DateTime.now();
  String searchQuery = ""; // Add search query state variable

  @override
  void initState() {
    super.initState();
    _loadPagePosition();
    _loadSelectedCategory();
  }

  Future<void> _savePagePosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedSesi', _selectedSesi);
    await prefs.setString('selectedCategory', _selectedCategory ?? '');
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

  Future<void> _loadSelectedCategory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCategory = prefs.getString('selectedCategory');
    });
  }

  void _resetScores() {
    // Notify TabelTugas to reset scores
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String sesi = ["Siang", "Sore", "Malam"][_selectedSesi];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90), // Increased from 60
        child: Container(
          padding: EdgeInsets.only(top: 20), // Increased from 10
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
            automaticallyImplyLeading: false, // This removes the back button
            title: Text(
              "Tugas Santri",
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
              ),
            ),
          ),
        ),
      ),
     
      body: Column(
        children: [
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
          // Add dot indicators here
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedSesi == index 
                      ? Color(0xFF2E3F7F) 
                      : Colors.grey.shade300,
                ),
              );
            }),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: "Pilih Kategori",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                          _savePagePosition();
                        },
                        items: categories
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category,
                                      style:
                                          TextStyle(fontWeight: FontWeight.bold)),
                                ))
                            .toList(),
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
                              borderRadius: BorderRadius.circular(12)),
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
                              _resetScores();
                            });
                            _savePagePosition();
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
                        borderRadius: BorderRadius.circular(12)),
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
            child: _selectedCategory == null
                ? Center(child: Text("Silakan pilih kategori"))
                : TabelTugas(
                    session: sesi,
                    category: _selectedCategory!,
                    selectedDate: selectedDate,
                    searchQuery: searchQuery, // Pass search query to TabelTugas
                  ),
          ),
        ],
      ),
    );
  }
}
