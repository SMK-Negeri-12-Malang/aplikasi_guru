import 'package:flutter/material.dart';

class InputHafalanDialog extends StatefulWidget {
  final String namaSantri;
  final String ayatAwal;
  final String ayatAkhir;
  final String nilaiAwal;
  final List<String> nilaiList;
  final Function(String ayatAwal, String ayatAkhir, String nilai) onSimpan;

  const InputHafalanDialog({
    super.key,
    required this.namaSantri,
    required this.ayatAwal,
    required this.ayatAkhir,
    required this.nilaiAwal,
    required this.nilaiList,
    required this.onSimpan,
  });

  @override
  State<InputHafalanDialog> createState() => _InputHafalanDialogState();
}

class _InputHafalanDialogState extends State<InputHafalanDialog> {
  late String ayatAwal;
  late String ayatAkhir;
  late String nilai;
  String surat = '';

  @override
  void initState() {
    super.initState();
    ayatAwal = widget.ayatAwal;
    ayatAkhir = widget.ayatAkhir;
    nilai = widget.nilaiAwal;
    surat = '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Input Hafalan ${widget.namaSantri.isNotEmpty ? widget.namaSantri : ""}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tambahkan input manual untuk surat
          TextField(
            decoration: const InputDecoration(labelText: 'Surat'),
            onChanged: (value) => surat = value,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Ayat Awal'),
            controller: TextEditingController(text: ayatAwal),
            keyboardType: TextInputType.number,
            onChanged: (value) => ayatAwal = value,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Ayat Akhir'),
            controller: TextEditingController(text: ayatAkhir),
            keyboardType: TextInputType.number,
            onChanged: (value) => ayatAkhir = value,
          ),
          DropdownButtonFormField<String>(
            value: nilai,
            decoration: const InputDecoration(labelText: 'Nilai'),
            items: widget.nilaiList
                .map((grade) => DropdownMenuItem(value: grade, child: Text(grade)))
                .toList(),
            onChanged: (value) => setState(() => nilai = value ?? widget.nilaiList[0]),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        TextButton(
          onPressed: () {
            widget.onSimpan(ayatAwal, ayatAkhir, nilai);
            Navigator.pop(context);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
