import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/saved_card.dart';
import '../../profile_tokens.dart';

/// Delete confirm for Cartões salvos (design modal).
class DeleteCardSheet extends StatelessWidget {
  const DeleteCardSheet({super.key, required this.card});

  final SavedCard card;

  static Future<bool?> show(BuildContext context, {required SavedCard card}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: ProfileTokens.sheetBarrier,
      builder: (_) => DeleteCardSheet(card: card),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final mask = '•••• ${card.lastFour}';

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: TwoGoColors.surfacePrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            ProfileTokens.pageGutter,
            8,
            ProfileTokens.pageGutter / 3,
            ProfileTokens.pageGutter + bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TwoGoIconButton(
                  icon: TwoGoIcons.close,
                  variant: TwoGoIconButtonVariant.secondary,
                  size: 18,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text.rich(
                  TextSpan(
                    style: TwoGoTypography.headlineSmall.copyWith(
                      color: TwoGoColors.contentPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      const TextSpan(text: 'Deseja excluir o cartão com o final '),
                      TextSpan(
                        text: mask,
                        style: const TextStyle(color: ProfileTokens.accentOrange),
                      ),
                      const TextSpan(text: '?'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: TwoGoSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: ProfileTokens.destructiveSoft,
                    foregroundColor: ProfileTokens.destructiveInk,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TwoGoRadius.full),
                    ),
                    textStyle: TwoGoTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Excluir'),
                ),
              ),
              const SizedBox(height: TwoGoSpacing.sm),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancelar',
                  style: TwoGoTypography.titleMedium.copyWith(
                    color: TwoGoColors.contentPrimary,
                    fontWeight: FontWeight.w600,
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
