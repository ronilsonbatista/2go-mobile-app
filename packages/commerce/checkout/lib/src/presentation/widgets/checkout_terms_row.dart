import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

/// "Li e aceito os Termos de Uso" — checkbox + tappable link.
class CheckoutTermsRow extends StatelessWidget {
  final bool accepted;
  final ValueChanged<bool> onChanged;
  final VoidCallback onOpenTerms;

  const CheckoutTermsRow({
    super.key,
    required this.accepted,
    required this.onChanged,
    required this.onOpenTerms,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TwoGoCheckbox(
          value: accepted,
          onChanged: (value) => onChanged(value ?? false),
        ),
        const SizedBox(width: TwoGoSpacing.xs),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Li e aceito os ',
                style: TwoGoTypography.bodyMedium.copyWith(
                  color: TwoGoColors.contentPrimary,
                ),
              ),
              GestureDetector(
                onTap: onOpenTerms,
                child: Text(
                  'Termos de Uso',
                  style: TwoGoTypography.bodyMedium.copyWith(
                    color: TwoGoColors.contentPrimary,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
