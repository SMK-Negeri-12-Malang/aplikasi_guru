import 'package:aplikasi_guru/ANIMASI/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class IzinModel {
  final String nama;
  final String tanggal;
  final String kamar;
  final String halaqo;
  final String musyrif;

  IzinModel({
    required this.nama,
    required this.tanggal,
    required this.kamar,
    required this.halaqo,
    required this.musyrif,
  });
}

List<IzinModel> izinList = [
  IzinModel(
      nama: 'Ahmad',
      tanggal: '01-02-2025 to 05-02-2025',
      kamar: 'Kamar A',
      halaqo: 'Halaqo 1',
      musyrif: 'Ustadz Ali'),
  IzinModel(
      nama: 'Aisyah',
      tanggal: '02-02-2025 to 06-02-2025',
      kamar: 'Kamar B',
      halaqo: 'Halaqo 2',
      musyrif: 'Ustadzah Fatimah'),
  IzinModel(
      nama: 'Fatimah',
      tanggal: '03-02-2025 to 07-02-2025',
      kamar: 'Kamar C',
      halaqo: 'Halaqo 3',
      musyrif: 'Ustadzah Zainab'),
];

class IzinPage extends StatefulWidget {
  @override
  _IzinState createState() => _IzinState();
}

class _IzinState extends State<IzinPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _kamarController = TextEditingController();
  final TextEditingController _halaqoController = TextEditingController();
  final TextEditingController _musyrifController = TextEditingController();

  final List<IzinModel> _namaSantriList =
      izinList; // Use izinList for autocomplete
  bool _showDropdown = false;

  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: 1)),
      ),
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text =
            "${picked.start.day}-${picked.start.month}-${picked.start.year} to ${picked.end.day}-${picked.end.month}-${picked.end.year}";
      });
    }
  }

  void _submitIzin() {
    if (_namaController.text.isNotEmpty &&
        _tanggalController.text.isNotEmpty &&
        _kamarController.text.isNotEmpty &&
        _halaqoController.text.isNotEmpty &&
        _musyrifController.text.isNotEmpty) {
      // Ensure 'Kamar' does not contain the word 'Kelas'
      if (_kamarController.text.contains('Kelas')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Nama kamar tidak boleh mengandung kata "Kelas"!')),
        );
        return;
      }

      // Check for duplicates
      bool isDuplicate = izinList.any((izin) =>
          izin.nama == _namaController.text &&
          izin.tanggal == _tanggalController.text &&
          izin.kamar == _kamarController.text &&
          izin.halaqo == _halaqoController.text &&
          izin.musyrif == _musyrifController.text);

      if (!isDuplicate) {
        setState(() {
          izinList.add(
            IzinModel(
              nama: _namaController.text,
              tanggal: _tanggalController.text,
              kamar: _kamarController.text,
              halaqo: _halaqoController.text,
              musyrif: _musyrifController.text,
            ),
          );
        });

        _namaController.clear();
        _tanggalController.clear();
        _kamarController.clear();
        _halaqoController.clear();
        _musyrifController.clear();

        Navigator.pop(context, true); // Pass true to indicate data was saved
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data izin sudah ada!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi semua data!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final filteredSantriList = _namaSantriList
        .where((santri) => santri.nama
            .toLowerCase()
            .contains(_namaController.text.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 233, 233, 233),
      body: CustomScrollView(
        slivers: [
          CustomGradientAppBar(
            title: 'Formulir Izin',
            icon: Icons.edit,
            textColor: Colors.white,
            child: Container(),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                          _namaController, 'Nama Santri', Icons.person,
                          onTap: () {
                        setState(() {
                          _showDropdown = true;
                        });
                      }, onChange: (value) {
                        setState(() {});
                      }),
                      if (_showDropdown && filteredSantriList.isNotEmpty)
                        _buildSuggestionsList(filteredSantriList),
                      SizedBox(height: 16),
                      _buildDateField(
                          _tanggalController,
                          'Tanggal Izin',
                          Icons.calendar_today,
                          () => _selectDateRange(context)),
                      SizedBox(height: 16),
                      _buildTextField(_kamarController, 'Kamar', Icons.room,
                          readOnly: true),
                      SizedBox(height: 16),
                      _buildTextField(_halaqoController, 'Halaqo', Icons.group),
                      SizedBox(height: 16),
                      _buildTextField(_musyrifController, 'Musyrif',
                          Icons.supervisor_account),
                      SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2E3F7F),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _submitIzin,
                        child: Text(
                          'Simpan Izin',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                // blurRadius: 10.0,
                                color: Colors.white,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool readOnly = false,
      int? maxLines,
      VoidCallback? onTap,
      Function(String)? onChange}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines ?? 1,
      onTap: onTap,
      onChanged: onChange,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF2E3F7F)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF2E3F7F)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label,
      IconData icon, VoidCallback onTap) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF2E3F7F)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF2E3F7F)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildSuggestionsList(List<IzinModel> filteredList) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(top: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: 200),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final santri = filteredList[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFF2E3F7F).withOpacity(0.1),
                child: Text(
                  santri.nama[0],
                  style: TextStyle(
                    color: Color(0xFF2E3F7F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(santri.nama),
              subtitle: Text(santri.kamar),
              onTap: () {
                setState(() {
                  _namaController.text = santri.nama;
                  _kamarController.text = santri.kamar;
                  _halaqoController.text = santri.halaqo;
                  _musyrifController.text = santri.musyrif;
                  _showDropdown = false;
                });
              },
            );
          },
        ),
      ),
    );
  }
}
