import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/student_data.dart';
import '../../utils/currency_format.dart';

class DetailKeuangan extends StatefulWidget {
  final String namaSantri;
  final String virtualAccount;
  final double saldo;
  final double uangMasuk;
  final double uangKeluar;
  final List<Transaction> transactions;

  DetailKeuangan({
    required this.namaSantri,
    required this.virtualAccount,
    required this.saldo,
    required this.uangMasuk,
    required this.uangKeluar,
    required this.transactions,
  });

  @override
  _DetailKeuanganState createState() => _DetailKeuanganState();
}

class _DetailKeuanganState extends State<DetailKeuangan> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;
  List<Transaction> _filteredTransactions = [];
  final List<String> months = [
    'Januari', 'Februari', 'Maret', 'April', 
    'Mei', 'Juni', 'Juli', 'Agustus',
    'September', 'Oktober', 'November', 'Desember'
  ];
  
  // Add new variables to track filtered summary
  double _filteredUangMasuk = 0;
  double _filteredUangKeluar = 0;

  // Add new variable for grouped transactions
  Map<String, List<Transaction>> _groupedTransactions = {};

  String getMonthName(int month) {
    return months[month - 1];
  }

  @override
  void initState() {
    super.initState();
    // Set current month as default filter
    _selectedDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
    );
    _filteredTransactions = widget.transactions;
    _searchController.addListener(_onSearchChanged);
    filterTransactions(); // This will apply current month filter
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() { 
    filterTransactions();
  }

  void _updateFilteredSummary(List<Transaction> transactions) {
    double masuk = 0;
    double keluar = 0;
    
    for (var transaction in transactions) {
      if (transaction.type == 'masuk') {
        masuk += transaction.amount;
      } else {
        keluar += transaction.amount;
      }
    }

    setState(() {
      _filteredUangMasuk = masuk;
      _filteredUangKeluar = keluar;
    });
  }

  void _groupTransactionsByMonth() {
    _groupedTransactions.clear();
    
    // Sort transactions by date descending first
    final sortedTransactions = List<Transaction>.from(_filteredTransactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    for (var transaction in sortedTransactions) {
      String key = '${getMonthName(transaction.date.month)} ${transaction.date.year}';
      if (!_groupedTransactions.containsKey(key)) {
        _groupedTransactions[key] = [];
      }
      _groupedTransactions[key]!.add(transaction);
    }
  }

  void filterTransactions() {
    setState(() {
      _filteredTransactions = widget.transactions.where((transaction) {
        bool matchesSearch = transaction.description
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
        
        if (_selectedDate != null) {
          bool matchesDate = 
            transaction.date.year == _selectedDate!.year &&
            transaction.date.month == _selectedDate!.month;
          return matchesSearch && matchesDate;
        }
        
        return matchesSearch;
      }).toList();

      // Update only uang masuk and keluar summaries
      _updateFilteredSummary(_filteredTransactions);
      // Group transactions by month
      _groupTransactionsByMonth();
    });
  }

  Future<void> _showDatePicker() async {
    final currentDate = DateTime.now();
    final currentYear = currentDate.year;
    final years = List.generate(5, (index) => currentYear - index);
    
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Periode',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3F7F),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                height: 300,
                width: double.maxFinite,
                child: Row(
                  children: [
                    // Years Column
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          itemCount: years.length,
                          itemBuilder: (context, index) {
                            final year = years[index];
                            final isCurrentYear = year == currentDate.year;
                            final isSelected = _selectedDate?.year == year;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedDate = DateTime(year, 
                                    _selectedDate?.month ?? currentDate.month);
                                });
                                filterTransactions();
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Color(0xFF2E3F7F)
                                      : null,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isCurrentYear ? "Tahun ini" : year.toString(),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected || isCurrentYear
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    // Months Column
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          itemCount: months.length,
                          itemBuilder: (context, index) {
                            final month = index + 1;
                            final isCurrentMonth = month == currentDate.month && 
                                                 _selectedDate?.year == currentDate.year;
                            final isSelected = _selectedDate?.month == month;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedDate = DateTime(
                                    _selectedDate?.year ?? currentDate.year,
                                    month,
                                  );
                                });
                                filterTransactions();
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Color(0xFF2E3F7F)
                                      : null,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isCurrentMonth ? "Bulan ini" : months[index],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected || isCurrentMonth
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = StudentData.getStudentSummary(widget.virtualAccount);
    
    return MaterialApp( // Wrap with MaterialApp to make independent
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(0xFFF5F6F8),
        body: Stack(
          children: [
            // Curved App Bar
            Container(
              height: 395,
              decoration: BoxDecoration(
                color: Color(0xFF2E3F7F),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
            
            SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'Detail Keuangan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bank Card Style
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color.fromARGB(255, 47, 95, 224), Color.fromARGB(255, 124, 124, 124)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Virtual Account',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Icon(
                                Icons.credit_card,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.virtualAccount,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            widget.namaSantri,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Rp ${CurrencyFormat.formatRupiah(summary["saldo"])}', // Always show total saldo
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Transaction Summary
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTransactionSummary(
                            'Uang Masuk',
                            _selectedDate != null ? _filteredUangMasuk : summary["uangMasuk"],
                            Icons.arrow_upward,
                            Colors.green,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildTransactionSummary(
                            'Uang Keluar',
                            _selectedDate != null ? _filteredUangKeluar : summary["uangKeluar"],
                            Icons.arrow_downward,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Transaction History Title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Riwayat Transaksi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Spacer(),
                            // Date Filter Button
                            _buildFilterButton(),
                          ],
                        ),
                        SizedBox(height: 8),
                        // Search Bar
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Cari transaksi...',
                              border: InputBorder.none,
                              icon: Icon(Icons.search),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12),

                  // Transaction History List
                  Expanded(
                    child: _filteredTransactions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                                SizedBox(height: 16),
                                Text(
                                  'Tidak ada transaksi',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _groupedTransactions.length,
                            itemBuilder: (context, index) {
                              final monthYear = _groupedTransactions.keys.elementAt(index);
                              final transactions = _groupedTransactions[monthYear]!;
                              
                              return Container(
                                margin: EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Month header
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF2E3F7F).withOpacity(0.1),
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_month,
                                            color: Color(0xFF2E3F7F),
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            monthYear,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2E3F7F),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Transactions list
                                    ...transactions.map((transaction) => Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.withOpacity(0.1),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: ListTile(
                                        leading: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: transaction.type == 'masuk'
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            transaction.type == 'masuk'
                                                ? Icons.add
                                                : Icons.remove,
                                            color: transaction.type == 'masuk'
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                        title: Row(
                                          children: [
                                            Text(
                                              'Rp ${CurrencyFormat.formatRupiah(transaction.amount)}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: transaction.type == 'masuk'
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(transaction.description),
                                            Text(
                                              '${transaction.date.day} ${getMonthName(transaction.date.month)} ${transaction.date.year}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        isThreeLine: true,
                                      ),
                                    )).toList(),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return TextButton.icon(
      onPressed: _showDatePicker,
      icon: Icon(Icons.calendar_today, color: Color(0xFF2E3F7F)),
      label: Text(
        '${getMonthName(_selectedDate!.month)} ${_selectedDate!.year}',
        style: TextStyle(color: Color(0xFF2E3F7F)),
      ),
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Color(0xFF2E3F7F), width: 1),
        ),
      ),
    );
  }

  Widget _buildTransactionSummary(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Rp ${CurrencyFormat.formatRupiah(amount)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
