import 'package:flutter/material.dart';
import '../Kepesantrenan/Kepesantrenan.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Map<String, dynamic>> _leaderboardData = [];

  @override
  void initState() {
    super.initState();
    _loadLeaderboardData();
  }

  void _loadLeaderboardData() {
    setState(() {
      // Fetch leaderboard data from Kepesantrenan
      _leaderboardData = Kepesantrenan.getLeaderboardData(
          Kepesantrenan.hafalanDataByDate); // Use static property
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leaderboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1D2842), // Updated to match app theme
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildLeaderboardHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: _leaderboardData.length,
              itemBuilder: (context, index) {
                final student = _leaderboardData[index];
                return _buildLeaderboardItem(student, index);
              },
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5), // Light gray background
    );
  }

  Widget _buildLeaderboardHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1D2842), // Updated to match app theme
      child: Column(
        children: [
          const Text(
            'Performa Siswa',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Minggu Ini',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTopThreeItem(
                  _leaderboardData.length > 1 ? _leaderboardData[1] : null, 2),
              _buildTopThreeItem(
                  _leaderboardData.isNotEmpty ? _leaderboardData[0] : null, 1,
                  isLarger: true),
              _buildTopThreeItem(
                  _leaderboardData.length > 2 ? _leaderboardData[2] : null, 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopThreeItem(Map<String, dynamic>? student, int position,
      {bool isLarger = false}) {
    return Column(
      children: [
        Container(
          width: isLarger ? 80 : 60,
          height: isLarger ? 80 : 60,
          decoration: BoxDecoration(
            color: _getMedalColor(position),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              position.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: isLarger ? 26 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          student?['name'] ?? '',
          style: TextStyle(
            color: Colors.white,
            fontSize: isLarger ? 14 : 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          student?['surat'] ?? '', // Display the surah name
          style: TextStyle(
            color: Colors.white70,
            fontSize: isLarger ? 18 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> student, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                index < 3 ? _getMedalColor(index + 1) : const Color(0xFFE0E0E0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              (index + 1).toString(), // Ensure rank is based on sorted data
              style: TextStyle(
                color: index < 3 ? Colors.white : const Color(0xFF1D2842),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          student['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D2842),
          ),
        ),
        subtitle: Text(
          'Surat: ${student['surat']}', // Display the surah name
          style: const TextStyle(
            color: Color(0xFF1D2842),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1D2842).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            student['score'].toString(),
            style: const TextStyle(
              color: Color(0xFF1D2842),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getMedalColor(int position) {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFFE0E0E0);
    }
  }
}
