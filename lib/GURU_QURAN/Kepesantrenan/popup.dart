import 'package:flutter/material.dart';
import 'surat.dart'; // Import surah list

class PopupInput extends StatefulWidget {
  final String initialSurat;
  final String initialAyatAwal;
  final String initialAyatAkhir;
  final String initialNilai;
  final List<String> grades;
  final Function(String surat, String ayatAwal, String ayatAkhir, String nilai)
      onSave;

  const PopupInput({
    super.key,
    required this.initialSurat,
    required this.initialAyatAwal,
    required this.initialAyatAkhir,
    required this.initialNilai,
    required this.grades,
    required this.onSave,
  });

  @override
  State<PopupInput> createState() => _PopupInputState();
}

class _PopupInputState extends State<PopupInput> {
  late TextEditingController _suratController;
  late TextEditingController _ayatAwalController;
  late TextEditingController _ayatAkhirController;
  late String _selectedNilai;
  List<String> _filteredSurahList = surahList;

  @override
  void initState() {
    super.initState();
    _suratController = TextEditingController(text: widget.initialSurat);
    _ayatAwalController = TextEditingController(text: widget.initialAyatAwal);
    _ayatAkhirController = TextEditingController(text: widget.initialAyatAkhir);
    _selectedNilai = widget.initialNilai;
  }

  @override
  void dispose() {
    _suratController.dispose();
    _ayatAwalController.dispose();
    _ayatAkhirController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Input Hafalan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Surat'),
              controller: _suratController,
              onChanged: (value) {
                setState(() {
                  _filteredSurahList = surahList
                      .where((surah) =>
                          surah.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
            if (_filteredSurahList.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 100),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredSurahList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_filteredSurahList[index]),
                      onTap: () {
                        setState(() {
                          _suratController.text = _filteredSurahList[index];
                          _filteredSurahList = [];
                        });
                      },
                    );
                  },
                ),
              ),
            TextField(
              decoration: const InputDecoration(labelText: 'Ayat Awal'),
              keyboardType: TextInputType.number,
              controller: _ayatAwalController,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Ayat Akhir'),
              keyboardType: TextInputType.number,
              controller: _ayatAkhirController,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedNilai,
              decoration: InputDecoration(
                labelText: 'Nilai',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: widget.grades.map((String grade) {
                return DropdownMenuItem<String>(
                  value: grade,
                  child: Text(grade),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() => _selectedNilai = value);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(
              _suratController.text,
              _ayatAwalController.text,
              _ayatAkhirController.text,
              _selectedNilai,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
