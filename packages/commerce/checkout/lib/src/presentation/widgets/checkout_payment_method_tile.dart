import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

class CheckoutPaymentMethodTile extends StatelessWidget {
  final String methodKey;
  final bool isSelected;
  final VoidCallback onTap;

  const CheckoutPaymentMethodTile({
    super.key,
    required this.methodKey,
    required this.isSelected,
    required this.onTap,
  });

  String get _title {
    switch (methodKey.toUpperCase()) {
      case 'PIX':
        return 'PIX';
      case 'CARD':
      case 'CREDIT_CARD':
        return 'Cartão de Crédito';
      default:
        return methodKey;
    }
  }

  String get _subtitle {
    switch (methodKey.toUpperCase()) {
      case 'PIX':
        return 'Aprovação instantânea via QR Code';
      case 'CARD':
      case 'CREDIT_CARD':
        return 'Pague com seu cartão';
      default:
        return 'Método de pagamento';
    }
  }

  IconData get _icon {
    switch (methodKey.toUpperCase()) {
      case 'PIX':
        return Icons.qr_code_2_rounded;
      case 'CARD':
      case 'CREDIT_CARD':
        return Icons.credit_card_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(TwoGoSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? TwoGoColors.contentPrimary.withValues(alpha: 0.05)
              : TwoGoColors.neutral0,
          borderRadius: BorderRadius.circular(TwoGoRadius.medium),
          border: Border.all(
            color: isSelected
                ? TwoGoColors.contentPrimary
                : TwoGoColors.neutral300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _icon,
              color: isSelected
                  ? TwoGoColors.contentPrimary
                  : TwoGoColors.neutral600,
              size: 24,
            ),
            const SizedBox(width: TwoGoSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
                    style: TwoGoTypography.headlineSmall.copyWith(
                      color: TwoGoColors.contentPrimary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    _subtitle,
                    style: TwoGoTypography.bodySmall.copyWith(
                      color: TwoGoColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: TwoGoColors.contentPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
