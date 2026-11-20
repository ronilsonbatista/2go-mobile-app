/// Formats BRL amounts as design copy: `R$ 21,99`.
String formatCheckoutCurrency(double value) {
  final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
  return 'R\$ $formatted';
}
