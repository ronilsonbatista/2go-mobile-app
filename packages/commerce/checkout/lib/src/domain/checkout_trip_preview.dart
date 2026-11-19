/// Layout stub for the Carrinho trip card (destino / pessoas / datas / thumb).
///
/// Core checkout summary does not yet ship these fields — until the API
/// agent lands them, screens pass a stub (Roma demo) for layout-first UI.
class CheckoutTripPreview {
  final String destination;
  final int peopleCount;
  final String datesLabel;
  final String? imageUrl;
  final String? imageAssetPath;

  const CheckoutTripPreview({
    required this.destination,
    required this.peopleCount,
    required this.datesLabel,
    this.imageUrl,
    this.imageAssetPath,
  });

  /// Design-frame stub used by goldens / layout QA.
  static const demoRoma = CheckoutTripPreview(
    destination: 'Roma',
    peopleCount: 2,
    datesLabel: '25 a 28 de julho',
  );

  String get peopleLabel =>
      peopleCount == 1 ? '1 pessoa' : '$peopleCount pessoas';
}
