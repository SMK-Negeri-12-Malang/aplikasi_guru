import 'transaction.dart';

class StudentData {
  static List<Map<String, dynamic>> santriList = [
    // Kamar A
    {
      "nama": "Budi Santoso",
      "saldo": 50000.0,
      "uangMasuk": 100000.0,
      "uangKeluar": 50000.0,
      "kamar": "Kamar A",
      "virtualAccount": "88776655441",
      "transactions": [
        Transaction(
          type: "masuk",
          amount: 300000,
          date: DateTime.now().subtract(Duration(days: 34)),
          description: "Kiriman orangtua",
        ),
        Transaction(
          type: "keluar",
          amount: 50000,
          date: DateTime.now().subtract(Duration(days: 1)),
          description: "Beli keperluan sekolah",
        ),
                Transaction(
          type: "masuk",
          amount: 100000,
          date: DateTime.now().subtract(Duration(days: 2)),
          description: "Kiriman orangtua",
        ),
        Transaction(
          type: "keluar",
          amount: 50000,
          date: DateTime.now().subtract(Duration(days: 1)),
          description: "beli kopi",
        ),
                Transaction(
          type: "masuk",
          amount: 1000000,
          date: DateTime.now().subtract(Duration(days: 2)),
          description: "Kiriman orangtua",
        ),
        Transaction(
          type: "keluar",
          amount: 50000,
          date: DateTime.now().subtract(Duration(days: 1)),
          description: "Beli jajan",
        ),
                Transaction(
          type: "masuk",
          amount: 100000,
          date: DateTime.now().subtract(Duration(days: 2)),
          description: "Kiriman orangtua",
        ),
        Transaction(
          type: "keluar",
          amount: 50000,
          date: DateTime.now().subtract(Duration(days: 1)),
          description: "beli rokok",
        ),
                Transaction(
          type: "masuk",
          amount: 100000,
          date: DateTime.now().subtract(Duration(days: 2)),
          description: "Kiriman orangtua",
        ),
        Transaction(
          type: "keluar",
          amount: 50000,
          date: DateTime.now().subtract(Duration(days: 1)),
          description: "Beli keperluan sekolah",
        ),
                Transaction(
          type: "masuk",
          amount: 100000,
          date: DateTime.now().subtract(Duration(days: 2)),
          description: "Kiriman orangtua",
        ),
        Transaction(
          type: "keluar",
          amount: 50000,
          date: DateTime.now().subtract(Duration(days: 1)),
          description: "beli kopi",
        ),
                Transaction(
          type: "masuk",
          amount: 1000000,
          date: DateTime.now().subtract(Duration(days: 2)),
          description: "Kiriman orangtua",
        ),
        Transaction(
          type: "keluar",
          amount: 50000,
          date: DateTime.now().subtract(Duration(days: 1)),
          description: "Beli vocer ff",
        ),
                Transaction(
          type: "masuk",
          amount: 600000,
          date: DateTime.now().subtract(Duration(days: 2)),
          description: "Kiriman orangtua",
        ),
        Transaction(
          type: "keluar",
          amount: 50000,
          date: DateTime.now().subtract(Duration(days: 1)),
          description: "beli rokok",
        ),
      ],
    },
    {
      "nama": "Ahmad Rizki",
      "saldo": 75000.0,
      "uangMasuk": 150000.0,
      "uangKeluar": 75000.0,
      "kamar": "Kamar A",
      "virtualAccount": "88776655442",
      "transactions": _generateTransactions(150000, 75000),
    },
    {
      "nama": "Deni Saputra",
      "saldo": 85000.0,
      "uangMasuk": 160000.0,
      "uangKeluar": 75000.0,
      "kamar": "Kamar A",
      "virtualAccount": "88776655443",
      "transactions": _generateTransactions(160000, 75000),
    },
    {
      "nama": "Faiz Rahman",
      "saldo": 95000.0,
      "uangMasuk": 170000.0,
      "uangKeluar": 75000.0,
      "kamar": "Kamar A",
      "virtualAccount": "88776655444",
      "transactions": _generateTransactions(170000, 75000),
    },
    {
      "nama": "Gani Abdullah",
      "saldo": 105000.0,
      "uangMasuk": 180000.0,
      "uangKeluar": 75000.0,
      "kamar": "Kamar A",
      "virtualAccount": "88776655445",
      "transactions": _generateTransactions(180000, 75000),
    },
    // Kamar B
    {
      "nama": "Hendra Wijaya",
      "saldo": 125000.0,
      "uangMasuk": 200000.0,
      "uangKeluar": 75000.0,
      "kamar": "Kamar B",
      "virtualAccount": "88776655446",
      "transactions": _generateTransactions(200000, 75000),
    },
    {
      "nama": "Irfan Maulana",
      "saldo": 90000.0,
      "uangMasuk": 120000.0,
      "uangKeluar": 30000.0,
      "kamar": "Kamar B",
      "virtualAccount": "88776655447",
      "transactions": _generateTransactions(120000, 30000),
    },
    {
      "nama": "Joko Susilo",
      "saldo": 110000.0,
      "uangMasuk": 150000.0,
      "uangKeluar": 40000.0,
      "kamar": "Kamar B",
      "virtualAccount": "88776655448",
      "transactions": _generateTransactions(150000, 40000),
    },
    {
      "nama": "Koko Prayogo",
      "saldo": 130000.0,
      "uangMasuk": 180000.0,
      "uangKeluar": 50000.0,
      "kamar": "Kamar B",
      "virtualAccount": "88776655449",
      "transactions": _generateTransactions(180000, 50000),
    },
    {
      "nama": "Lutfi Hakim",
      "saldo": 140000.0,
      "uangMasuk": 190000.0,
      "uangKeluar": 50000.0,
      "kamar": "Kamar B",
      "virtualAccount": "88776655450",
      "transactions": _generateTransactions(190000, 50000),
    },
    // Kamar C
    {
      "nama": "Malik Ibrahim",
      "saldo": 150000.0,
      "uangMasuk": 200000.0,
      "uangKeluar": 50000.0,
      "kamar": "Kamar C",
      "virtualAccount": "88776655451",
      "transactions": _generateTransactions(200000, 50000),
    },
    {
      "nama": "Naufal Aziz",
      "saldo": 160000.0,
      "uangMasuk": 210000.0,
      "uangKeluar": 50000.0,
      "kamar": "Kamar C",
      "virtualAccount": "88776655452",
      "transactions": _generateTransactions(210000, 50000),
    },
    {
      "nama": "Omar Faruk",
      "saldo": 170000.0,
      "uangMasuk": 220000.0,
      "uangKeluar": 50000.0,
      "kamar": "Kamar C",
      "virtualAccount": "88776655453",
      "transactions": _generateTransactions(220000, 50000),
    },
    {
      "nama": "Putra Pratama",
      "saldo": 180000.0,
      "uangMasuk": 230000.0,
      "uangKeluar": 50000.0,
      "kamar": "Kamar C",
      "virtualAccount": "88776655454",
      "transactions": _generateTransactions(230000, 50000),
    },
    {
      "nama": "Qodir Jaelani",
      "saldo": 190000.0,
      "uangMasuk": 240000.0,
      "uangKeluar": 50000.0,
      "kamar": "Kamar C",
      "virtualAccount": "88776655455",
      "transactions": _generateTransactions(240000, 50000),
    },
  ];

  static void _updateFinancialSummary(Map<String, dynamic> student) {
    double totalMasuk = 0;
    double totalKeluar = 0;

    for (Transaction trans in student["transactions"]) {
      if (trans.type == "masuk") {
        totalMasuk += trans.amount;
      } else {
        totalKeluar += trans.amount;
      }
    }

    student["uangMasuk"] = totalMasuk;
    student["uangKeluar"] = totalKeluar;
    student["saldo"] = totalMasuk - totalKeluar;
  }

  static List<Transaction> _generateTransactions(double masuk, double keluar) {
    return [
      Transaction(
        type: "masuk",
        amount: masuk,
        date: DateTime.now().subtract(Duration(days: 3)),
        description: "Kiriman orangtua",
      ),
      Transaction(
        type: "keluar",
        amount: keluar,
        date: DateTime.now().subtract(Duration(days: 1)),
        description: "Pengeluaran rutin",
      ),
    ];
  }

  static List<Map<String, dynamic>> getSantriByKamar(String kamar) {
    var filteredList = santriList.where((santri) => santri["kamar"] == kamar).toList();
    
    // Update financial summaries for each student
    for (var student in filteredList) {
      _updateFinancialSummary(student);
    }
    
    return filteredList;
  }

  static void addTransaction(String virtualAccount, Transaction transaction) {
    var student = santriList.firstWhere(
      (s) => s["virtualAccount"] == virtualAccount,
      orElse: () => throw Exception("Student not found"),
    );

    student["transactions"].add(transaction);
    _updateFinancialSummary(student);
  }

  static Map<String, dynamic> getStudentSummary(String virtualAccount) {
    var student = santriList.firstWhere(
      (s) => s["virtualAccount"] == virtualAccount,
      orElse: () => throw Exception("Student not found"),
    );

    _updateFinancialSummary(student);
    
    return {
      "saldo": student["saldo"],
      "uangMasuk": student["uangMasuk"],
      "uangKeluar": student["uangKeluar"],
      "transactions": student["transactions"],
    };
  }

  static List<String> getAvailableRooms() {
    return ["Kamar A", "Kamar B", "Kamar C"];
  }
}
