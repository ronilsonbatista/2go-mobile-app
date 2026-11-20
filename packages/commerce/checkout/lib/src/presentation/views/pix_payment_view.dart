import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/checkout_currency_format.dart';

/// Pix screen — copia-e-cola, instruções 1–3, countdown progress.
class PixPaymentView extends StatelessWidget {
  final String purchaseId;
  final String? copyPaste;
  final String? qrCodeBase64;
  final int remainingSeconds;
  final int totalSeconds;
  final double amount;
  final VoidCallback? onCopied;
  final VoidCallback? onBack;
  final VoidCallback? onExpired;

  const PixPaymentView({
    super.key,
    required this.purchaseId,
    this.copyPaste,
    this.qrCodeBase64,
    required this.remainingSeconds,
    this.totalSeconds = 300,
    required this.amount,
    this.onCopied,
    this.onBack,
    this.onExpired,
  });

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds <= 0
        ? 0.0
        : (remainingSeconds / totalSeconds).clamp(0.0, 1.0);

    if (remainingSeconds <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onExpired?.call();
      });
    }

    return Scaffold(
      backgroundColor: TwoGoColors.backgroundPrimary,
      appBar: TwoGoAppBar(
        title: 'Pix',
        onBackPressed: onBack,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          TwoGoSpacing.md,
          TwoGoSpacing.sm,
          TwoGoSpacing.md,
          TwoGoSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                style: TwoGoTypography.bodyLarge.copyWith(
                  color: TwoGoColors.contentPrimary,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'Pague '),
                  TextSpan(
                    text: formatCheckoutCurrency(amount),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(
                    text: ' para concluir a compra do seu roteiro.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: TwoGoSpacing.lg),
            if (copyPaste != null && copyPaste!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(TwoGoSpacing.md),
                decoration: BoxDecoration(
                  color: TwoGoColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(TwoGoRadius.large),
                ),
                child: Text(
                  copyPaste!,
                  style: TwoGoTypography.bodySmall.copyWith(
                    color: TwoGoColors.contentPrimary,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: TwoGoSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: copyPaste!));
                    onCopied?.call();
                    if (context.mounted) {
                      TwoGoSnackbar.show(
                        context,
                        message: 'Código PIX copiado!',
                        variant: TwoGoSnackbarVariant.success,
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TwoGoColors.contentPrimary,
                    backgroundColor: TwoGoColors.brandLimeLight.withValues(
                      alpha: 0.35,
                    ),
                    side: BorderSide(
                      color: TwoGoColors.brandLime.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: TwoGoSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TwoGoRadius.large),
                    ),
                  ),
                  child: Text(
                    'Copiar código PIX',
                    style: TwoGoTypography.labelLarge.copyWith(
                      color: TwoGoColors.contentPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: TwoGoSpacing.xl),
            Text(
              'Instruções de pagamento',
              style: TwoGoTypography.titleMedium.copyWith(
                color: TwoGoColors.contentPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: TwoGoSpacing.sm),
            const _InstructionStep(
              number: '1',
              text:
                  'Abra o app do seu banco ou carteira digital e escolha pagar com Pix.',
            ),
            const _InstructionStep(
              number: '2',
              text:
                  'Selecione Pix Copia e Cola e cole o código gerado nesta tela.',
            ),
            const _InstructionStep(
              number: '3',
              text:
                  'Confirme o pagamento. Assim que o banco confirmar, o acesso ao roteiro é liberado.',
            ),
            const SizedBox(height: TwoGoSpacing.xl),
            Text(
              'Tempo restante para pagamento',
              style: TwoGoTypography.bodyMedium.copyWith(
                color: TwoGoColors.contentSecondary,
              ),
            ),
            const SizedBox(height: TwoGoSpacing.xs),
            ClipRRect(
              borderRadius: TwoGoRadius.borderFull,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: TwoGoColors.neutral200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  TwoGoColors.brandLime,
                ),
              ),
            ),
            const SizedBox(height: TwoGoSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _formatTime(remainingSeconds < 0 ? 0 : remainingSeconds),
                style: TwoGoTypography.titleMedium.copyWith(
                  color: TwoGoColors.contentPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  const _InstructionStep({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TwoGoSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number.',
            style: TwoGoTypography.bodyMedium.copyWith(
              color: TwoGoColors.contentPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: TwoGoSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: TwoGoTypography.bodyMedium.copyWith(
                color: TwoGoColors.contentSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
