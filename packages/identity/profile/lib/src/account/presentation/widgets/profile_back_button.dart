import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../profile_tokens.dart';

/// Circular grey back control matching Perfil prints.
class ProfileBackButton extends StatelessWidget {
  const ProfileBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TwoGoIconButton(
      icon: TwoGoIcons.back,
      variant: TwoGoIconButtonVariant.secondary,
      size: 20,
      backgroundColor: TwoGoColors.neutral100,
      iconColor: TwoGoColors.contentPrimary,
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      tooltip: 'Voltar',
    );
  }
}

PreferredSizeWidget profileAppBar({
  required String title,
  VoidCallback? onBack,
}) {
  return TwoGoAppBar(
    title: title,
    showBackButton: false,
    leading: Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: ProfileTokens.backCircleSize,
          height: ProfileTokens.backCircleSize,
          child: ProfileBackButton(onPressed: onBack),
        ),
      ),
    ),
  );
}
