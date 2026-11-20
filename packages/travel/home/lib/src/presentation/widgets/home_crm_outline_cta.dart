import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

/// Pill outline "Criar novo roteiro" used on CRM next-trip states (Home-1…7).
class HomeCrmOutlineCta extends StatelessWidget {
  const HomeCrmOutlineCta({
    super.key,
    required this.onPressed,
    this.label = 'Criar novo roteiro',
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: TwoGoColors.contentPrimary,
          side: const BorderSide(color: TwoGoColors.neutral900, width: 1.2),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(
            horizontal: TwoGoSpacing.xl,
            vertical: TwoGoSpacing.md,
          ),
          textStyle: TwoGoTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
