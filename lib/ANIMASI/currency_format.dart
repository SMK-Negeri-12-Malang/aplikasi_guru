class CurrencyFormat {
  static String formatRupiah(double amount) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String formatted = amount.toStringAsFixed(0);
    return formatted.replaceAllMapped(reg, (Match match) => '${match[1]}.');
  }
}
