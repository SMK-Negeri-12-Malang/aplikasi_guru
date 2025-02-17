import 'package:flutter/material.dart';

class MusyrifRoutes {
  static const pelanggaran = '/pelanggaran';
  static const kesehatan = '/kesehatan';
  static const perizinan = '/perizinan';
  static const uangSaku = '/uang-saku';
  static const kamar = '/kamar';
}

class MusyrifDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Musyrif'),
        backgroundColor: Colors.blue[700],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[700],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blue[700]),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Musyrif',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              context,
              'Pelanggaran',
              Icons.warning,
              MusyrifRoutes.pelanggaran,
            ),
            _buildDrawerItem(
              context,
              'Kesehatan',
              Icons.local_hospital,
              MusyrifRoutes.kesehatan,
            ),
            _buildDrawerItem(
              context,
              'Perizinan',
              Icons.assignment,
              MusyrifRoutes.perizinan,
            ),
            _buildDrawerItem(
              context,
              'Uang Saku',
              Icons.account_balance_wallet,
              MusyrifRoutes.uangSaku,
            ),
            _buildDrawerItem(
              context,
              'Kamar Santri',
              Icons.bedroom_parent,
              MusyrifRoutes.kamar,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Keluar'),
              onTap: () => Navigator.pushReplacementNamed(context, '/role-selector'),
            ),
          ],
        ),
      ),
      body: GridView.count(
        padding: EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildMenuCard(
            context,
            'Pelanggaran',
            Icons.warning,
            Colors.red,
            () => Navigator.pushNamed(context, MusyrifRoutes.pelanggaran),
          ),
          _buildMenuCard(
            context,
            'Kesehatan',
            Icons.local_hospital,
            Colors.green,
            () => Navigator.pushNamed(context, MusyrifRoutes.kesehatan),
          ),
          _buildMenuCard(
            context,
            'Perizinan',
            Icons.assignment,
            Colors.orange,
            () => Navigator.pushNamed(context, MusyrifRoutes.perizinan),
          ),
          _buildMenuCard(
            context,
            'Uang Saku',
            Icons.account_balance_wallet,
            Colors.purple,
            () => Navigator.pushNamed(context, MusyrifRoutes.uangSaku),
          ),
          _buildMenuCard(
            context,
            'Kamar Santri',
            Icons.bedroom_parent,
            Colors.blue,
            () => Navigator.pushNamed(context, MusyrifRoutes.kamar),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close drawer
        Navigator.pushNamed(context, route);
      },
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
