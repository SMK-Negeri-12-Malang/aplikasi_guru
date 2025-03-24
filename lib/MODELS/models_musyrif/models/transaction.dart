class Transaction {
  final String type;
  final double amount;
  final DateTime date;
  final String description;

  Transaction({
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
  });
}
