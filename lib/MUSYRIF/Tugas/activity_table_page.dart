import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../models/activity_model.dart';

class ActivityTablePage extends StatelessWidget {
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

  final List<Activity> dummyData = [
    Activity(
      aktivitas: 'Membaca Al-Quran',
      kategori: 'Tahfidz',
      dilakukan: 'Ya',
      skor: 100,
      keterangan: 'Baik',
    ),
    Activity(
      aktivitas: 'Menghafal Hadits',
      kategori: 'Hadits',
      dilakukan: 'Ya',
      skor: 90,
      keterangan: 'Bagus',
    ),
    Activity(
      aktivitas: 'Sholat Dhuha',
      kategori: 'Ibadah',
      dilakukan: 'Ya',
      skor: 85,
      keterangan: 'Cukup',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Aktivitas',
        style: TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
        ),),
        backgroundColor: Color(0xFF2E3F7F),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // TODO: Implement edit functionality
              print('Edit button pressed');
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
                    Text('Nama Santri: $studentName', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Tanggal: $date', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Sesi: $sesi', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Kategori: $kategori', style: TextStyle(fontSize: 16)),
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
                  source: ActivityDataSource(dummyData),
                  columnWidthMode: ColumnWidthMode.auto,
                  gridLinesVisibility: GridLinesVisibility.both,
                  headerGridLinesVisibility: GridLinesVisibility.both,
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
        DataGridCell<String>(columnName: 'Dilakukan', value: activity.dilakukan),
        DataGridCell<int>(columnName: 'Skor', value: activity.skor),
        DataGridCell<String>(columnName: 'Keterangan', value: activity.keterangan),
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
          child: Text(dataCell.value.toString(), style: TextStyle(fontSize: 14)),
        );
      }).toList(),
    );
  }
}
