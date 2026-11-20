import 'package:flutter/material.dart';

/// Login footer art: suitcase + beach + 2GO ROTEIROS stamp (design-login).
///
/// Resolution-aware PNGs live under `assets/login/suitcase.png` (+ 2.0x / 3.0x).
class LoginSuitcaseIllustration extends StatelessWidget {
  const LoginSuitcaseIllustration({super.key, this.height});

  /// Optional fixed height; otherwise scales to width at native ~402∶249.
  final double? height;

  static const package = 'twogo_authentication';
  static const assetPath = 'assets/login/suitcase.png';

  /// Native 1x aspect (402×249).
  static const aspectRatio = 402 / 249;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath,
      package: package,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'Ilustração de mala de viagem 2GO Roteiros',
    );

    if (height != null) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: image,
      );
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: SizedBox(width: double.infinity, child: image),
    );
  }
}
