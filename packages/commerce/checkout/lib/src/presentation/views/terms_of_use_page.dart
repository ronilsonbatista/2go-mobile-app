import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

/// Full-screen Termos de Uso (sections 1–7 from design frames).
class TermsOfUsePage extends StatelessWidget {
  final VoidCallback? onBack;

  const TermsOfUsePage({super.key, this.onBack});

  static const _sections = <(String, String)>[
    (
      '1. Sobre o serviço',
      'A 2GO oferecece roteiros de viagem personalizados por meio do aplicativo. '
          'Ao adquirir o acesso, você obtém o conteúdo do roteiro contratado '
          'conforme a oferta apresentada no momento da compra.',
    ),
    (
      '2. Cadastro e acesso',
      'Você é responsável por manter seus dados cadastrais atualizados e por '
          'proteger o acesso à sua conta. O uso indevido pode resultar em '
          'suspensão do acesso.',
    ),
    (
      '3. Uso da plataforma',
      'O conteúdo do roteiro é para uso pessoal. É vedada a redistribuição, '
          'revenda ou cópia comercial sem autorização prévia da 2GO.',
    ),
    (
      '4. Pagamentos',
      'Os valores, cupons e métodos de pagamento disponíveis são os exibidos '
          'no Carrinho. A confirmação do pagamento é condição para liberação '
          'do acesso completo ao roteiro.',
    ),
    (
      '5. Cancelamentos e suporte',
      'Solicitações de suporte, dúvidas e pedidos relacionados à compra '
          'podem ser feitos pelos canais oficiais indicados no aplicativo.',
    ),
    (
      '6. Privacidade',
      'Tratamos dados pessoais conforme nossa Política de Privacidade, '
          'incluindo dados necessários para faturamento e prevenção a fraudes.',
    ),
    (
      '7. Alterações',
      'Estes Termos podem ser atualizados. Continuando a usar o serviço após '
          'alterações, você concorda com a versão vigente no aplicativo.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwoGoColors.backgroundPrimary,
      appBar: TwoGoAppBar(
        title: 'Termos de Uso',
        onBackPressed: onBack,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          TwoGoSpacing.md,
          TwoGoSpacing.sm,
          TwoGoSpacing.md,
          TwoGoSpacing.xl,
        ),
        itemCount: _sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: TwoGoSpacing.lg),
        itemBuilder: (context, index) {
          final (title, body) = _sections[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TwoGoTypography.titleMedium.copyWith(
                  color: TwoGoColors.contentPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: TwoGoSpacing.xs),
              Text(
                body,
                style: TwoGoTypography.bodyMedium.copyWith(
                  color: TwoGoColors.contentSecondary,
                  height: 1.45,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
