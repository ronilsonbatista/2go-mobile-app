import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TwoGoAppBar(title: 'Início', showBackButton: false),
      body: SafeArea(
        child: TwoGoCenteredContent(
          maxWidth: 390,
          child: Padding(
            padding: const EdgeInsets.all(TwoGoSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  TwoGoIcons.homeOutlined,
                  size: 48,
                  color: TwoGoColors.contentSecondary,
                ),
                const SizedBox(height: TwoGoSpacing.md),
                Text(
                  'Bem-vindo ao 2GO',
                  style: TwoGoTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: TwoGoSpacing.xs),
                Text(
                  'Seu feed e atalhos rápidos serão disponibilizados na Fase 7B.',
                  textAlign: TextAlign.center,
                  style: TwoGoTypography.bodyMedium.copyWith(
                    color: TwoGoColors.contentSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
