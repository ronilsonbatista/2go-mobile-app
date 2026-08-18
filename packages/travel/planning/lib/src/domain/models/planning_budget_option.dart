class PlanningBudgetOption {
  final String rawValue;
  final String symbol;
  final String label;
  final String subtitle;

  const PlanningBudgetOption({
    required this.rawValue,
    required this.symbol,
    required this.label,
    required this.subtitle,
  });

  static const List<PlanningBudgetOption> options = [
    PlanningBudgetOption(
      rawValue: 'LOW',
      symbol: '\$',
      label: 'Econômica',
      subtitle: 'Foco em custo-benefício e viagens acessíveis',
    ),
    PlanningBudgetOption(
      rawValue: 'MEDIUM',
      symbol: '\$\$',
      label: 'Confortável',
      subtitle: 'Boa relação custo-benefício com conforto',
    ),
    PlanningBudgetOption(
      rawValue: 'HIGH',
      symbol: '\$\$\$',
      label: 'Premium',
      subtitle: 'Hospedagem e passeios diferenciados de alto nível',
    ),
    PlanningBudgetOption(
      rawValue: 'PREMIUM',
      symbol: '\$\$\$\$',
      label: 'Luxuosa',
      subtitle: 'Máxima exclusividade, requinte e serviços de luxo',
    ),
  ];

  static PlanningBudgetOption? fromRaw(String? raw) {
    if (raw == null) return null;
    try {
      return options.firstWhere(
        (o) => o.rawValue.toUpperCase() == raw.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
