import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

class AuthSocialLoginRow extends StatelessWidget {
  const AuthSocialLoginRow({
    super.key,
    this.socialLoginFacebook = false,
    this.socialLoginGoogle = false,
    this.socialLoginApple = false,
    this.onFacebookPressed,
    this.onGooglePressed,
    this.onApplePressed,
  });

  final bool socialLoginFacebook;
  final bool socialLoginGoogle;
  final bool socialLoginApple;
  final VoidCallback? onFacebookPressed;
  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ou continue com',
          style: TwoGoTypography.labelMedium.copyWith(
            color: TwoGoColors.contentSecondary,
          ),
        ),
        const SizedBox(height: TwoGoSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialIconButton(
              icon: TwoGoIcons.facebook,
              iconColor: const Color(0xFF1877F2),
              enabled: socialLoginFacebook,
              onPressed: onFacebookPressed,
              semanticLabel: 'Entrar com Facebook',
            ),
            const SizedBox(width: TwoGoSpacing.lg),
            _SocialIconButton(
              icon: TwoGoIcons.google,
              iconColor: const Color(0xFFEA4335),
              enabled: socialLoginGoogle,
              onPressed: onGooglePressed,
              semanticLabel: 'Entrar com Google',
            ),
            const SizedBox(width: TwoGoSpacing.lg),
            _SocialIconButton(
              icon: TwoGoIcons.apple,
              iconColor: TwoGoColors.contentPrimary,
              enabled: socialLoginApple,
              onPressed: onApplePressed,
              semanticLabel: 'Entrar com Apple',
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({
    required this.icon,
    required this.iconColor,
    required this.enabled,
    required this.semanticLabel,
    this.onPressed,
  });

  final IconData icon;
  final Color iconColor;
  final bool enabled;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TwoGoTouchTarget(
      minWidth: 48,
      minHeight: 48,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: TwoGoColors.surfacePrimary,
          shape: BoxShape.circle,
          border: Border.all(color: TwoGoColors.borderDefault),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            icon,
            size: 20,
            color: enabled ? iconColor : TwoGoColors.contentDisabled,
          ),
          onPressed: enabled ? onPressed : null,
          tooltip: semanticLabel,
        ),
      ),
    );
  }
}
