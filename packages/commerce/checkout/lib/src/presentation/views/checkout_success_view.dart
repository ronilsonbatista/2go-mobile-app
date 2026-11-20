import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

/// Success screen after gateway / Pix confirmation.
class CheckoutSuccessView extends StatelessWidget {
  final VoidCallback onAccessItinerary;

  const CheckoutSuccessView({
    super.key,
    required this.onAccessItinerary,
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
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (final size in [140.0, 110.0, 80.0])
                      Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: TwoGoColors.neutral200,
                            width: 1,
                          ),
                        ),
                      ),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: TwoGoColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: TwoGoColors.neutral0,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TwoGoSpacing.xl),
              Text(
                'Pagamento confirmado',
                style: TwoGoTypography.headlineMedium.copyWith(
                  color: TwoGoColors.contentPrimary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TwoGoSpacing.sm),
              Text(
                'Já pode fazer as malas! 💼\n'
                'O acesso completo ao seu roteiro já está liberado!',
                style: TwoGoTypography.bodyLarge.copyWith(
                  color: TwoGoColors.contentSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              TwoGoButton(
                text: 'Acessar roteiro',
                onPressed: onAccessItinerary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
