/// Caminho depois do claim.
///
/// `CHECKOUT` é a ação conhecida do contrato. Valor ausente ou desconhecido
/// segue para o checkout, que é o fluxo atual.
String claimNavigationPath({
  required String tripId,
  required String? nextAction,
}) {
  final action = nextAction?.trim().toUpperCase();
  final query = 'tripId=${Uri.encodeQueryComponent(tripId)}';
  switch (action) {
    case 'CHECKOUT':
      return '/checkout?$query';
    default:
      return '/checkout?$query';
  }
}
