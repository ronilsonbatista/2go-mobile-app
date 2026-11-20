/// Prefill for invite / Caso 2 — Nome + Telefone known, CPF still required.
class CheckoutInvitePrefill {
  final String fullName;
  final String phone;

  const CheckoutInvitePrefill({
    required this.fullName,
    required this.phone,
  });

  /// Design-frame stub (João Ribeiro Silva).
  static const demoJoao = CheckoutInvitePrefill(
    fullName: 'João Ribeiro Silva',
    phone: '(00) 9 1234-5678',
  );
}
