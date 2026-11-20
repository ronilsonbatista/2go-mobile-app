/// Formats multi-city trip labels for Home CRM cards (design Home-1…7).
///
/// Rules measured from PDFs:
/// - 1 city → `Name`
/// - 2 cities → `A e B`
/// - 3+ → `A e B e mais N` where N = total − 2
///
/// Names must already be Core destination strings — this class never invents cities.
abstract final class HomeTripDestinationLabel {
  static const _months = <String>[
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  /// Single-line label for the trip card.
  static String format(List<String> names) {
    final cleaned = _clean(names);
    if (cleaned.isEmpty) return '';
    if (cleaned.length == 1) return cleaned.first;
    if (cleaned.length == 2) return '${cleaned[0]} e ${cleaned[1]}';
    final extra = cleaned.length - 2;
    return '${cleaned[0]} e ${cleaned[1]} e mais $extra';
  }

  /// Stacked overlay lines (Home-3/7): first city, then `e Second`.
  /// For 3+ returns the single-line [format] as one line.
  static List<String> stackedLines(List<String> names) {
    final cleaned = _clean(names);
    if (cleaned.isEmpty) return const [];
    if (cleaned.length == 1) return [cleaned.first];
    if (cleaned.length == 2) return [cleaned[0], 'e ${cleaned[1]}'];
    return [format(cleaned)];
  }

  static String formatDayMonth(DateTime date) {
    final month = _months[(date.month - 1).clamp(0, 11)];
    return '${date.day} de $month';
  }

  static List<String> _clean(List<String> names) {
    return names
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .toList(growable: false);
  }
}
