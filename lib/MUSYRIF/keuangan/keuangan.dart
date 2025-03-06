import 'package:aplikasi_ortu/MUSYRIF/keuangan/detail_keuangan.dart';
import 'package:aplikasi_ortu/MUSYRIF/models/transaction.dart';
import 'package:aplikasi_ortu/utils/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import '../models/student_data.dart';
import '../../utils/currency_format.dart';

class Keuangan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: KeuanganSantriPage(),
    );
  }
}

class KeuanganSantriPage extends StatefulWidget {
  @override
  _KeuanganSantriPageState createState() => _KeuanganSantriPageState();
}

class _KeuanganSantriPageState extends State<KeuanganSantriPage> {
  String selectedKamar = "Kamar A";
  List<String> kamarList = StudentData.getAvailableRooms();
  PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  List<Map<String, dynamic>> filteredSantri = [];

  @override
  void initState() {
    super.initState();
    filteredSantri = StudentData.getSantriByKamar(selectedKamar);
  }

  void updateFilteredSantri(String kamar) {
    setState(() {
      selectedKamar = kamar;
      filteredSantri = StudentData.getSantriByKamar(kamar);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 233, 233, 233),
      body: CustomScrollView(
        slivers: [
          CustomGradientAppBar(
            title: 'Keuangan Santri',
            icon: Icons.account_balance_wallet,
            textColor: Colors.white, // Explicitly set white text
            child:
                Container(), // Empty container since we don't need the centered content anymore
            showBackButton: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pilih Kamar",
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3F7F),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: screenHeight * 0.15,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: kamarList.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                                selectedKamar = kamarList[index];
                                updateFilteredSantri(selectedKamar);
                              });
                            },
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              return _buildRoomCard(
                                index,
                                selectedKamar == kamarList[index],
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          kamarList.length,
                          (index) => Container(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            width: 8,
                            height: 8,
                            child: Icon(
                              _currentPage == index
                                  ? Icons.arrow_drop_up
                                  : _currentPage == index - 1 ||
                                          _currentPage == index + 1
                                      ? Icons.circle
                                      : Icons.arrow_drop_down,
                              color: _currentPage == index
                                  ? Color(0xFF2E3F7F)
                                  : Colors.grey[300],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: filteredSantri.length,
                    itemBuilder: (context, index) {
                      final santri = filteredSantri[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailKeuangan(
                                  namaSantri: santri["nama"],
                                  virtualAccount: santri["virtualAccount"],
                                  saldo: santri["saldo"],
                                  uangMasuk: santri["uangMasuk"],
                                  uangKeluar: santri["uangKeluar"],
                                  transactions: santri["transactions"],
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Color(0xFF2E3F7F),
                                      child: Text(
                                        santri["nama"][0].toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          santri["nama"],
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.04,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2E3F7F),
                                          ),
                                        ),
                                        Text(
                                          "Saldo: Rp ${CurrencyFormat.formatRupiah(santri["saldo"])}",
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildTransactionInfo(
                                      "Masuk",
                                      santri["uangMasuk"],
                                      Colors.green,
                                    ),
                                    _buildTransactionInfo(
                                      "Keluar",
                                      santri["uangKeluar"],
                                      Colors.red,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildRoomCard(int index, bool isSelected) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return TweenAnimationBuilder(
      tween: Tween<double>(
        begin: isSelected ? 0.0 : 0.3,
        end: isSelected ? 1.0 : 0.8,
      ),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..translate(0.0, isSelected ? 0.0 : 20.0)
            ..scale(value),
          alignment: Alignment.center,
          child: Container(
            margin: EdgeInsets.symmetric(
              vertical: screenHeight * 0.01,
              horizontal: screenWidth * 0.02,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSelected
                    ? [Color(0xFF2E3F7F), Color(0xFF4557A4)]
                    : [Colors.grey[300]!, Colors.grey[400]!],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? Color(0xFF2E3F7F).withOpacity(0.3)
                      : Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                kamarList[index],
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionInfo(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          "Rp ${CurrencyFormat.formatRupiah(amount)}",
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
