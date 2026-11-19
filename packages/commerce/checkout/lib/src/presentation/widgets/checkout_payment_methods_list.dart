import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_payments/twogo_payments.dart';

/// Forma de pagamento rows driven by Core `paymentMethodAvailability`.
class CheckoutPaymentMethodsList extends StatelessWidget {
  final List<String> methods;
  final List<PaymentMethodAvailability> availability;
  final ValueChanged<String> onSelect;
  final bool includeComingSoon;

  const CheckoutPaymentMethodsList({
    super.key,
    required this.methods,
    this.availability = const [],
    required this.onSelect,
    this.includeComingSoon = true,
  });

  List<_MethodRow> get _rows {
    if (availability.isNotEmpty) {
      return availability
          .where((m) => m.available || includeComingSoon)
          .map(
            (m) => _MethodRow(
              keyName: m.method.toUpperCase(),
              available: m.available,
              comingSoon: m.isComingSoon || !m.available,
            ),
          )
          .toList();
    }

    final resolved = <_MethodRow>[];
    for (final method in methods) {
      final key = method.toUpperCase();
      if (key == 'CARD' || key == 'CREDIT_CARD') {
        if (!resolved.any((r) => r.keyName == 'CARD')) {
          resolved.add(const _MethodRow(keyName: 'CARD', available: true));
        }
      } else if (key == 'PIX') {
        if (!resolved.any((r) => r.keyName == 'PIX')) {
          resolved.add(const _MethodRow(keyName: 'PIX', available: true));
        }
      }
    }

    // Layout stubs when Core availability is absent.
    if (includeComingSoon) {
      if (defaultTargetPlatform == TargetPlatform.iOS || kIsWeb) {
        if (!resolved.any((r) => r.keyName == 'APPLE_PAY')) {
          resolved.add(
            const _MethodRow(
              keyName: 'APPLE_PAY',
              available: false,
              comingSoon: true,
            ),
          );
        }
      }
      if (defaultTargetPlatform == TargetPlatform.android) {
        if (!resolved.any((r) => r.keyName == 'GOOGLE_PAY')) {
          resolved.add(
            const _MethodRow(
              keyName: 'GOOGLE_PAY',
              available: false,
              comingSoon: true,
            ),
          );
        }
      }
    }
    return resolved;
  }

  String _title(String key) {
    switch (key) {
      case 'PIX':
        return 'Pix';
      case 'CARD':
        return 'Cartão de crédito';
      case 'APPLE_PAY':
        return 'Apple Pay';
      case 'GOOGLE_PAY':
        return 'Google Pay';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _rows;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forma de pagamento',
          style: TwoGoTypography.titleMedium.copyWith(
            color: TwoGoColors.contentPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: TwoGoSpacing.sm),
        ...items.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: TwoGoSpacing.xs),
            child: Material(
              color: TwoGoColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(TwoGoRadius.large),
              child: InkWell(
                onTap: row.available
                    ? () => onSelect(row.keyName)
                    : () {
                        TwoGoSnackbar.show(
                          context,
                          message: row.keyName == 'APPLE_PAY' ||
                                  row.keyName == 'GOOGLE_PAY'
                              ? 'Em breve — carteira ainda em configuração'
                              : 'Método indisponível no momento',
                          variant: TwoGoSnackbarVariant.info,
                        );
                      },
                borderRadius: BorderRadius.circular(TwoGoRadius.large),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TwoGoSpacing.md,
                    vertical: TwoGoSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _title(row.keyName),
                          style: TwoGoTypography.bodyLarge.copyWith(
                            color: row.available
                                ? TwoGoColors.contentPrimary
                                : TwoGoColors.contentSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (row.comingSoon && !row.available)
                        Padding(
                          padding: const EdgeInsets.only(right: TwoGoSpacing.xs),
                          child: Text(
                            'Em breve',
                            style: TwoGoTypography.labelSmall.copyWith(
                              color: TwoGoColors.contentSecondary,
                            ),
                          ),
                        ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: row.available
                            ? TwoGoColors.contentSecondary
                            : TwoGoColors.contentDisabled,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _MethodRow {
  const _MethodRow({
    required this.keyName,
    required this.available,
    this.comingSoon = false,
  });

  final String keyName;
  final bool available;
  final bool comingSoon;
}
