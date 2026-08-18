import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TwoGoAppBar(title: 'Notificações', showBackButton: false),
      body: SafeArea(
        child: TwoGoCenteredContent(
          maxWidth: 390,
          child: Padding(
            padding: const EdgeInsets.all(TwoGoSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  TwoGoIcons.notificationsOutlined,
                  size: 48,
                  color: TwoGoColors.contentSecondary,
                ),
                const SizedBox(height: TwoGoSpacing.md),
                Text(
                  'Notificações',
                  style: TwoGoTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: TwoGoSpacing.xs),
                Text(
                  'Avisos e atualizações sobre seus voos e reservas.',
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
