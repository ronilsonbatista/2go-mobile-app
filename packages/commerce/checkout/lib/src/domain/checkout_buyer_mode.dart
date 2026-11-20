/// Who is checking out — drives Dados pessoais / Termos visibility.
///
/// Design cases (`docs/pagamento-use-cases-2026-11-19.md`):
/// - [firstPurchase]: empty Nome/Telefone/CPF + Termos required
/// - [returning]: no Dados pessoais, no Termos
/// - [invite]: Nome+Telefone prefilled, CPF empty + Termos required
enum CheckoutBuyerMode {
  firstPurchase,
  returning,
  invite,
}

extension CheckoutBuyerModeX on CheckoutBuyerMode {
  bool get showsPersonalData =>
      this == CheckoutBuyerMode.firstPurchase ||
      this == CheckoutBuyerMode.invite;

  bool get showsTerms => showsPersonalData;
}
