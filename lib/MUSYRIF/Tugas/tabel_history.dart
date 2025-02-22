import 'package:aplikasi_ortu/MUSYRIF/Tugas/tabel_tugas.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../models/student_model.dart';
import '../models/activity_model.dart';
import '../services/student_service.dart';
import '../services/activity_service.dart';

class HistoryPage extends StatefulWidget {
  final String kategori;
  
  const HistoryPage({
    Key? key,
    required this.kategori,
  }) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Student> students;
  final List<String> sesiList = ['Pagi', 'Sore', 'Malam'];
  DateTime selectedDate = DateTime.now();
  final ActivityService _activityService = ActivityService();

  final Map<String, List<Activity>> sessionActivities = {
    'Pagi': [
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
    ],
    'Sore': [
      // Same activities as Pagi
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
    ],
    'Malam': [
      // Same activities as Pagi
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
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: sesiList.length, vsync: this);
    students = StudentService.getStudentsByCategory(widget.kategori);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget _buildHeaderCell(String title) {
    return Container(
      padding: EdgeInsets.all(10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(0xFF2E3F7F),
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 1),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }

  void _navigateToDetail(Student student, String sesi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityTablePage(
          studentName: student.name,
          date: '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
          sesi: sesi,
          kategori: widget.kategori,
        ),
      ),
    );
  }

  List<Activity> _getActivitiesForStudent(String studentName, String sesi) {
    String dateStr = '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
    return _activityService.getActivities(dateStr, sesi, studentName);
  }

  void _showPreviousChanges() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Riwayat Perubahan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: 10, // Replace with actual history count
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(0xFF2E3F7F),
                            child: Text('${index + 1}'),
                          ),
                          title: Text('Perubahan pada ${selectedDate.subtract(Duration(days: index)).day}/'
                              '${selectedDate.subtract(Duration(days: index)).month}/'
                              '${selectedDate.subtract(Duration(days: index)).year}'),
                          subtitle: Text('Diubah oleh: Musyrif ${index + 1}'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Handle tapping on a specific history item
                            Navigator.of(context).pop();
                            setState(() {
                              selectedDate = selectedDate.subtract(Duration(days: index));
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History ${widget.kategori}'),
        backgroundColor: Color(0xFF2E3F7F),
        actions: [
          TextButton.icon(
            onPressed: () => _selectDate(context),
            icon: Icon(Icons.calendar_today, color: Colors.white),
            label: Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // Color for selected tab
          unselectedLabelColor: Colors.white.withOpacity(0.7), // Color for unselected tab
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs: sesiList.map((sesi) => Tab(text: sesi)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPreviousChanges,
        icon: Icon(Icons.history,
        color: Colors.white,
        ),
        label: Text('Riwayat',
        style: TextStyle(
          color: Colors.white,
        ),
        ),
        backgroundColor: Color(0xFF2E3F7F),
      ),
      body: TabBarView(
        controller: _tabController,
        children: sesiList.map((sesi) {
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final studentActivities = _getActivitiesForStudent(student.name, sesi);
              
              return Card(
                margin: EdgeInsets.all(8),
                child: InkWell(
                  onTap: () => _navigateToDetail(student, sesi),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          student.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        height: 300,
                        padding: EdgeInsets.all(8),
                        child: SfDataGrid(
                          source: ActivityDataSource(studentActivities),
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
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

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
