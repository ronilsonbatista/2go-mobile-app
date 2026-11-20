import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

/// Ops! payment failure — Voltar returns to payment entry.
class CheckoutErrorView extends StatelessWidget {
  final VoidCallback onBack;
  final String? message;

  const CheckoutErrorView({
    super.key,
    required this.onBack,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwoGoColors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TwoGoSpacing.lg),
          child: Column(
            children: [
              const Spacer(),
              Text(
                'Ops!',
                style: TwoGoTypography.display.copyWith(
                  color: TwoGoColors.contentPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 40,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TwoGoSpacing.md),
              Text(
                message ??
                    'Tivemos um problema em processar seu pagamento. '
                        'Verifique as informações e tente novamente.',
                style: TwoGoTypography.bodyLarge.copyWith(
                  color: TwoGoColors.contentSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TwoGoColors.contentPrimary,
                    side: const BorderSide(color: TwoGoColors.contentPrimary),
                    padding: const EdgeInsets.symmetric(
                      vertical: TwoGoSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TwoGoRadius.large),
                    ),
                  ),
                  child: Text(
                    'Voltar',
                    style: TwoGoTypography.labelLarge.copyWith(
                      color: TwoGoColors.contentPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
