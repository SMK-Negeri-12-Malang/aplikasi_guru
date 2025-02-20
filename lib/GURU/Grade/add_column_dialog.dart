import 'package:flutter/material.dart';

class AddColumnDialog extends StatefulWidget {
  final String type;

  AddColumnDialog({required this.type});

  @override
  _AddColumnDialogState createState() => _AddColumnDialogState();
}

class _AddColumnDialogState extends State<AddColumnDialog> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  double maxScore = 100;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tambah Kolom ${widget.type}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Judul Kolom',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul tidak boleh kosong';
                }
                return null;
              },
              onChanged: (value) => title = value,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Deskripsi (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) => description = value,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Nilai Maksimal',
                border: OutlineInputBorder(),
              ),
              initialValue: '100',
              keyboardType: TextInputType.number,
              onChanged: (value) => maxScore = double.tryParse(value) ?? 100,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'title': title,
                'description': description,
                'maxScore': maxScore,
                'type': widget.type,
              });
            }
          },
          child: Text('Tambah'),
        ),
      ],
    );
  }
}
