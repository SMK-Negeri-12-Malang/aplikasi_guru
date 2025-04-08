import 'package:flutter/material.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  // Sample data for leaderboard
  final List<Map<String, dynamic>> _leaderboardData = [
    {'rank': 1, 'name': 'Ahmad Rizky', 'score': 98, 'avatar': 'assets/avatar1.png'},
    {'rank': 2, 'name': 'Siti Nurhaliza', 'score': 95, 'avatar': 'assets/avatar2.png'},
    {'rank': 3, 'name': 'Budi Santoso', 'score': 92, 'avatar': 'assets/avatar3.png'},
    {'rank': 4, 'name': 'Dewi Anggraini', 'score': 90, 'avatar': 'assets/avatar4.png'},
    {'rank': 5, 'name': 'Farhan Abdullah', 'score': 88, 'avatar': 'assets/avatar5.png'},
    {'rank': 6, 'name': 'Rina Marlina', 'score': 85, 'avatar': 'assets/avatar6.png'},
    {'rank': 7, 'name': 'Dimas Pratama', 'score': 82, 'avatar': 'assets/avatar7.png'},
    {'rank': 8, 'name': 'Anisa Rahmawati', 'score': 80, 'avatar': 'assets/avatar8.png'},
    {'rank': 9, 'name': 'Irfan Hakim', 'score': 78, 'avatar': 'assets/avatar9.png'},
    {'rank': 10, 'name': 'Maya Putri', 'score': 75, 'avatar': 'assets/avatar10.png'},
  ];

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
              // Second Place
              _buildTopThreeItem(_leaderboardData[1], 2),
              // First Place (larger)
              _buildTopThreeItem(_leaderboardData[0], 1, isLarger: true),
              // Third Place
              _buildTopThreeItem(_leaderboardData[2], 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopThreeItem(Map<String, dynamic> student, int position, {bool isLarger = false}) {
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
          student['name'],
          style: TextStyle(
            color: Colors.white,
            fontSize: isLarger ? 14 : 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          student['score'].toString(),
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
            color: index < 3 ? _getMedalColor(index + 1) : const Color(0xFFE0E0E0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              student['rank'].toString(),
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