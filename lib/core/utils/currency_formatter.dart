extension CurrencyFormatter on num {
  String toSom() {
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final String formatted = toString().replaceAllMapped(
      reg,
      (Match match) => '${match[1]} ',
    );
    return '$formatted сом';
  }

  String toStartingSom() {
    return 'от ${toSom()}';
  }
}
