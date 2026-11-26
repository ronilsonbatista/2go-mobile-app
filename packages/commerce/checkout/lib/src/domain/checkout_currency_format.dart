/// Formats BRL amounts as design copy: `R$ 99,90`.
String formatCheckoutCurrency(double value) {
  final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
  return 'R\$ $formatted';
}
