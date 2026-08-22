import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twogo_design_system/design_system.dart';

class PixPaymentView extends StatelessWidget {
  final String purchaseId;
  final String? copyPaste;
  final String? qrCodeBase64;
  final int remainingSeconds;
  final VoidCallback? onCopied;

  const PixPaymentView({
    super.key,
    required this.purchaseId,
    this.copyPaste,
    this.qrCodeBase64,
    required this.remainingSeconds,
    this.onCopied,
  });

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    return '$mStr:$sStr';
  }

  @override
  Widget build(BuildContext context) {
    final minutesLeft = _formatTime(remainingSeconds);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(TwoGoSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const TwoGoBadge(
            label: 'Aguardando Pagamento PIX',
            variant: TwoGoBadgeVariant.info,
          ),
          const SizedBox(height: TwoGoSpacing.md),

          Text(
            'Escaneie o QR Code ou copie a chave PIX',
            style: TwoGoTypography.headlineSmall.copyWith(
              color: TwoGoColors.contentPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TwoGoSpacing.sm),

          Text(
            'O acesso será liberado assim que o pagamento for confirmado pelo servidor.',
            style: TwoGoTypography.bodySmall.copyWith(
              color: TwoGoColors.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TwoGoSpacing.lg),

          // QR Code rendering
          if (qrCodeBase64 != null && qrCodeBase64!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(TwoGoSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(TwoGoSpacing.md),
                border: Border.all(color: TwoGoColors.neutral200),
              ),
              child: Image.memory(
                base64Decode(qrCodeBase64!),
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.qr_code_2,
                  size: 160,
                  color: Colors.black87,
                ),
              ),
            )
          else
            Container(
              width: 200,
              height: 200,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TwoGoColors.neutral100,
                borderRadius: BorderRadius.circular(TwoGoSpacing.md),
              ),
              child: const Icon(
                Icons.qr_code_2,
                size: 140,
                color: Colors.black54,
              ),
            ),
          const SizedBox(height: TwoGoSpacing.lg),

          // Countdown Timer display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined, color: TwoGoColors.primary, size: 20),
              const SizedBox(width: TwoGoSpacing.xs),
              Text(
                'Expira em: ',
                style: TwoGoTypography.bodyMedium.copyWith(
                  color: TwoGoColors.neutral600,
                ),
              ),
              Text(
                minutesLeft,
                style: TwoGoTypography.headlineSmall.copyWith(
                  color: TwoGoColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: TwoGoSpacing.lg),

          // Copia e cola code display & button
          if (copyPaste != null && copyPaste!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(TwoGoSpacing.md),
              decoration: BoxDecoration(
                color: TwoGoColors.neutral100,
                borderRadius: BorderRadius.circular(TwoGoSpacing.sm),
                border: Border.all(color: TwoGoColors.neutral200),
              ),
              child: Text(
                copyPaste!,
                style: TwoGoTypography.bodySmall.copyWith(
                  fontFamily: 'monospace',
                  color: TwoGoColors.contentPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: TwoGoSpacing.md),
            TwoGoButton(
              text: 'Copiar Código PIX',
              icon: Icons.copy,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: copyPaste!));
                onCopied?.call();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Código PIX copiado!')),
                  );
                }
              },
            ),
          ],
          const SizedBox(height: TwoGoSpacing.xl),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const TwoGoLoadingIndicator(size: 18),
              const SizedBox(width: TwoGoSpacing.sm),
              Text(
                'Checando confirmação do servidor...',
                style: TwoGoTypography.bodySmall.copyWith(
                  color: TwoGoColors.neutral600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
