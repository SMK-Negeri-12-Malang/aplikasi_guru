import 'package:aplikasi_ortu/utils/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/student_service.dart';

class Tugas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TugasSantriPage(),
    );
  }
}

class TugasSantriPage extends StatefulWidget {
  @override
  _TugasSantriPageState createState() => _TugasSantriPageState();
}

class _TugasSantriPageState extends State<TugasSantriPage> {
  String selectedKamar = "Mutabaah";
  String selectedDate = '';
  List<String> kamarList = ["Mutabaah", "Tahsin", "Tahfidz"];
  
  PageController _pageController = PageController(
    viewportFraction: 0.75,
    initialPage: 0,
  );
  int _currentPage = 0;
  List<Student> filteredStudents = [];
  final List<String> sesiList = ['Pagi', 'Sore', 'Malam'];

  TextEditingController dateController = TextEditingController();
  Student? selectedStudent;
  String? selectedSesi;

  void updateSelectedStudent(String? newValue) {
    setState(() {
      selectedStudent = filteredStudents.firstWhere((student) => student.name == newValue);
    });
  }

  @override
  void initState() {
    super.initState();
    filteredStudents = StudentService.getStudentsByCategory(selectedKamar);
  }

  void updateFilteredSantri(String kamar) {
    setState(() {
      selectedKamar = kamar;
      filteredStudents = StudentService.getStudentsByCategory(kamar);
      _clearForm();
    });
  }

  void _clearForm() {
    setState(() {
      dateController.clear();
      selectedStudent = null;
      selectedSesi = null;
      selectedDate = '';
    });
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
        dateController.text = selectedDate;
      });
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 233, 233, 233),
      body: CustomScrollView(
        slivers: [
          CustomGradientAppBar(
            title: 'Tugas Santri',
            icon: Icons.task_sharp,
            height: 100.0,
            textColor: Colors.white,
            child: Container(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pilih Tugas",
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3F7F),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    height: screenHeight * 0.15,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: kamarList.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                          selectedKamar = kamarList[index];
                          updateFilteredSantri(selectedKamar);
                        });
                      },
                      scrollDirection: Axis.horizontal,
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
                              child: _buildRoomCard(
                                index,
                                selectedKamar == kamarList[index],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      kamarList.length,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Color(0xFF2E3F7F)
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: dateController,
                          decoration: InputDecoration(
                            labelText: 'Tanggal',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.all(10),
                            prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF2E3F7F)),
                          ),
                          readOnly: true,
                          onTap: _pickDate,
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedSesi,
                          decoration: InputDecoration(
                            labelText: 'Sesi',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.all(10),
                            prefixIcon: Icon(Icons.access_time, color: Color(0xFF2E3F7F)),
                          ),
                          items: sesiList.map((String sesi) {
                            return DropdownMenuItem<String>(
                              value: sesi,
                              child: Text(sesi),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedSesi = newValue;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            return filteredStudents
                                .map((student) => student.name)
                                .where((name) => name
                                    .toLowerCase()
                                    .contains(textEditingValue.text.toLowerCase()));
                          },
                          onSelected: (String selection) {
                            updateSelectedStudent(selection);
                          },
                          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'Nama Santri',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.all(10),
                                prefixIcon: Icon(Icons.person, color: Color(0xFF2E3F7F)),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2E3F7F),
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            // Handle form submission
                          },
                          child: Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(int index, bool isSelected) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSelected
              ? [Color(0xFF2E3F7F), Color(0xFF4557A4)]
              : [Colors.grey[300]!, Colors.grey[400]!],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: isSelected 
                ? Color(0xFF2E3F7F).withOpacity(0.3)
                : Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          kamarList[index],
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
