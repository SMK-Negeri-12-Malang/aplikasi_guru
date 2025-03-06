import 'package:aplikasi_ortu/MUSYRIF/services/activity_service.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../models/activity_model.dart';

class ActivityTablePage extends StatefulWidget {
  final String studentName;
  final String date;
  final String sesi;
  final String kategori;

  ActivityTablePage({
    required this.studentName,
    required this.date,
    required this.sesi,
    required this.kategori,
  });

  @override
  State<ActivityTablePage> createState() => _ActivityTablePageState();
}

class _ActivityTablePageState extends State<ActivityTablePage> {
  late List<Activity> activities;
  late ActivityDataSource activityDataSource;
  bool isEditMode = false;
  final ActivityService _activityService = ActivityService();

  @override
  void initState() {
    super.initState();
    activities = _activityService.getActivities(
      widget.date,
      widget.sesi,
      widget.studentName,
    );
    activityDataSource = ActivityDataSource(activities);
  }

  void _saveActivities() {
    _activityService.saveActivities(
      widget.date,
      widget.sesi,
      widget.studentName,
      activities,
    );
    setState(() {
      isEditMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Perubahan disimpan')),
    );
  }

  String getKeteranganFromSkor(int skor) {
    if (skor >= 91 && skor <= 100) return 'Baik Sekali';
    if (skor >= 76 && skor <= 90) return 'Baik';
    if (skor >= 61 && skor <= 75) return 'Cukup';
    if (skor >= 41 && skor <= 60) return 'Kurang';
    if (skor >= 21 && skor <= 40) return 'Buruk';
    if (skor >= 1 && skor <= 20) return 'Sangat Buruk';
    return 'Invalid';
  }

  Future<void> _showEditDialog(Activity activity) async {
    if (!isEditMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aktifkan mode edit terlebih dahulu'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    String? newDilakukan = activity.dilakukan;
    int? newSkor = activity.skor;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Aktivitas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: newDilakukan,
              items: ['Ya', 'Tidak'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                newDilakukan = value;
              },
              decoration: InputDecoration(labelText: 'Dilakukan'),
            ),
            TextFormField(
              initialValue: newSkor?.toString() ?? '',
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Skor'),
              onChanged: (value) {
                newSkor = int.tryParse(value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                activity.dilakukan = newDilakukan;
                activity.skor = newSkor;
                activity.keterangan = newSkor != null ? getKeteranganFromSkor(newSkor!) : '';
                activityDataSource = ActivityDataSource(activities);
              });
              Navigator.pop(context);
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Detail Aktivitas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF2E3F7F),
        actions: [
          IconButton(
            icon: Icon(
              isEditMode ? Icons.save : Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              if (isEditMode) {
                _saveActivities();
              } else {
                setState(() {
                  isEditMode = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Mode edit aktif. Ketuk pada baris yang ingin diedit'),
                    
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Informasi Santri
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nama Santri: ${widget.studentName}', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Tanggal: ${widget.date}', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Sesi: ${widget.sesi}', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Kategori: ${widget.kategori}', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
          
          // Tabel Scrollable dengan Header Berwarna
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: SfDataGrid(
                  source: activityDataSource,
                  columnWidthMode: ColumnWidthMode.auto,
                  gridLinesVisibility: GridLinesVisibility.both,
                  headerGridLinesVisibility: GridLinesVisibility.both,
                  onCellTap: (details) {
                    if (details.rowColumnIndex.rowIndex != 0) {
                      final rowIndex = details.rowColumnIndex.rowIndex - 1;
                      if (rowIndex < activities.length) {
                        _showEditDialog(activities[rowIndex]);
                      }
                    }
                  },
                  columns: [
                    GridColumn(
                      columnName: 'Aktivitas',
                      label: _buildHeaderCell('Aktivitas'),
                    ),
                    GridColumn(
                      columnName: 'Kategori',
                      label: _buildHeaderCell('Kategori'),
                    ),
                    GridColumn(
                      columnName: 'Dilakukan',
                      label: _buildHeaderCell('Dilakukan'),
                    ),
                    GridColumn(
                      columnName: 'Skor',
                      label: _buildHeaderCell('Skor'),
                    ),
                    GridColumn(
                      columnName: 'Keterangan',
                      label: _buildHeaderCell('Keterangan'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk Header dengan Warna
  Widget _buildHeaderCell(String title) {
    return Container(
      padding: EdgeInsets.all(10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(0xFF2E3F7F), // Warna latar belakang biru tua
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 1),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.white, // Warna teks putih agar kontras
        ),
      ),
    );
  }
}

// Data Source untuk SfDataGrid
class ActivityDataSource extends DataGridSource {
  List<DataGridRow> _dataGridRows = [];

  ActivityDataSource(List<Activity> activities) {
    _dataGridRows = activities.map<DataGridRow>((activity) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'Aktivitas', value: activity.aktivitas),
        DataGridCell<String>(columnName: 'Kategori', value: activity.kategori),
        DataGridCell<String>(
          columnName: 'Dilakukan', 
          value: activity.dilakukan ?? '-'
        ),
        DataGridCell<String>(
          columnName: 'Skor', 
          value: activity.skor?.toString() ?? '-'
        ),
        DataGridCell<String>(
          columnName: 'Keterangan', 
          value: activity.keterangan.isEmpty ? '-' : activity.keterangan
        ),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataCell) {
        return Container(
          padding: EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
          child: Text(
            dataCell.value.toString(),
            style: TextStyle(
              fontSize: 14,
              color: dataCell.value == '-' ? Colors.grey : Colors.black
            )
          ),
        );
      }).toList(),
    );
  }
}
