import 'package:aplikasi_guru/MUSYRIF/keuangan/detail_keuangan.dart';
import 'package:flutter/material.dart';
import '../../MODELS/models_musyrif/models/student_data.dart';
import '../../ANIMASI/currency_format.dart';


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
  PageController _roomPageController = PageController(initialPage: 0);
  int _currentKamarIndex = 0;

  // Add new state variable for search
  String searchQuery = "";

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
    _roomPageController.dispose();
    super.dispose();
  }

  Widget _buildRoomSelector() {
    return Container(
      height: 120,
      child: Stack(
        children: [
          PageView.builder(
            controller: _roomPageController,
            itemCount: kamarList.length,
            onPageChanged: (index) {
              setState(() {
                _currentKamarIndex = index;
                selectedKamar = kamarList[index];
                updateFilteredSantri(selectedKamar);
              });
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _roomPageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_roomPageController.position.haveDimensions) {
                    value = 1 - (_roomPageController.page! - index).abs();
                    value = 0.8 + (value * 0.2);
                  }
                  return Center(
                    child: Transform.scale(
                      scale: value,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: selectedKamar == kamarList[index]
                                ? [Color(0xFF2E3F7F), Color(0xFF4557A4)]
                                : [Colors.white, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: selectedKamar == kamarList[index]
                                  ? Color(0xFF2E3F7F).withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: selectedKamar == kamarList[index]
                                ? Colors.transparent
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            kamarList[index],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: selectedKamar == kamarList[index]
                                  ? Colors.white
                                  : Color(0xFF2E3F7F),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // Navigation arrows
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, size: 30),
                  onPressed: _currentKamarIndex > 0
                      ? () {
                          _roomPageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  color: _currentKamarIndex > 0
                      ? Color(0xFF2E3F7F)
                      : Colors.grey.shade300,
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, size: 30),
                  onPressed: _currentKamarIndex < kamarList.length - 1
                      ? () {
                          _roomPageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  color: _currentKamarIndex < kamarList.length - 1
                      ? Color(0xFF2E3F7F)
                      : Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Modify filteredSantri calculation
    final displayedSantri = filteredSantri.where((santri) =>
      santri["nama"].toString().toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      backgroundColor: Colors.white,  // Changed to white for banking app look
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.grey[100],
            expandedHeight: screenHeight * 0.10,
            pinned: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: FlexibleSpaceBar(
                centerTitle: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_balance_wallet,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Keuangan Santri',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add search field before room selector
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari nama santri...',
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    searchQuery = '';
                                  });
                                  // Clear the text field
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    FocusScope.of(context).unfocus();
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF2E3F7F)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF2E3F7F).withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF2E3F7F), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  
                  Text(
                    "Pilih Kamar",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E3F7F),
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildRoomSelector(),
                  SizedBox(height: 20),
                  // Use filtered list instead of original
                  ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: displayedSantri.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                    itemBuilder: (context, index) {
                      final santri = displayedSantri[index];
                      return InkWell(
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
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      santri["nama"],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "VA: ${santri["virtualAccount"]}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Rp ${CurrencyFormat.formatRupiah(santri["saldo"])}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E3F7F),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_upward,
                                        size: 12,
                                        color: Colors.green,
                                      ),
                                      Text(
                                        "Rp ${CurrencyFormat.formatRupiah(santri["uangMasuk"])}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_downward,
                                        size: 12,
                                        color: Colors.red,
                                      ),
                                      Text(
                                        "Rp ${CurrencyFormat.formatRupiah(santri["uangKeluar"])}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ],
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
