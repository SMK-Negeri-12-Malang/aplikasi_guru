import 'package:flutter/material.dart';
import 'package:aplikasi_guru/MODELS/models/santri_data.dart' as models;

class LeaderboardPage extends StatefulWidget {
  final String academicYear;

  const LeaderboardPage({
    Key? key,
    required this.academicYear,
  }) : super(key: key);

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  late List<models.Santri> sortedSantri;

  @override
  void initState() {
    super.initState();
    _loadSantriData();
  }

  void _loadSantriData() {
    final santriList = models.SantriDataProvider.getSantriForYear(widget.academicYear);
    setState(() {
      sortedSantri = List.of(santriList)
        ..sort((a, b) => (b.hafalan ?? 0).compareTo(a.hafalan ?? 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Peringkat Santri ${widget.academicYear}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF2E3F7F),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Top 3 podium visualization
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            color: Color(0xFF2E3F7F).withOpacity(0.1),
            child: sortedSantri.isNotEmpty
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildPodiumItem(
                        rank: 2,
                        name: sortedSantri.length > 1 ? sortedSantri[1].name : '-',
                        score: sortedSantri.length > 1 ? sortedSantri[1].hafalan ?? 0 : 0,
                        color: Colors.grey,
                        height: 100,
                      ),
                      _buildPodiumItem(
                        rank: 1,
                        name: sortedSantri.isNotEmpty ? sortedSantri[0].name : '-',
                        score: sortedSantri.isNotEmpty ? sortedSantri[0].hafalan ?? 0 : 0,
                        color: Colors.amber,
                        height: 130,
                      ),
                      _buildPodiumItem(
                        rank: 3,
                        name: sortedSantri.length > 2 ? sortedSantri[2].name : '-',
                        score: sortedSantri.length > 2 ? sortedSantri[2].hafalan ?? 0 : 0,
                        color: Colors.brown,
                        height: 80,
                      ),
                    ],
                  )
                : Center(child: Text('Tidak ada data santri')),
          ),
          
          // Title for the list
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Daftar Lengkap Peringkat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3F7F),
                  ),
                ),
              ],
            ),
          ),
          
          // List of all santri
          Expanded(
            child: ListView.builder(
              itemCount: sortedSantri.length,
              itemBuilder: (context, index) {
                final santri = sortedSantri[index];
                
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getRankColor(index),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      santri.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Hafalan: ${santri.hafalan ?? 0}'),
                    trailing: index < 3
                        ? Icon(
                            Icons.emoji_events,
                            color: _getRankColor(index),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem({
    required int rank,
    required String name,
    required int score,
    required Color color,
    required double height,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color,
          child: Text(
            '$rank',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 22,
            ),
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: 100,
          child: Column(
            children: [
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Hafalan: $score',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey;
      case 2:
        return Colors.brown;
      default:
        return Colors.blue.shade200;
    }
  }
}