import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_session/twogo_session.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        final email = state.userId ?? 'passageiro@2go.com';

        return Scaffold(
          appBar: const TwoGoAppBar(title: 'Perfil', showBackButton: false),
          body: SafeArea(
            child: SingleChildScrollView(
              child: TwoGoCenteredContent(
                maxWidth: 390,
                child: Padding(
                  padding: const EdgeInsets.all(TwoGoSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: TwoGoSpacing.md),
                      const Center(
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: TwoGoColors.brandLime,
                          child: Icon(
                            TwoGoIcons.profile,
                            size: 40,
                            color: TwoGoColors.surfacePrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: TwoGoSpacing.md),
                      Text(
                        email,
                        textAlign: TextAlign.center,
                        style: TwoGoTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: TwoGoSpacing.xs),
                      Text(
                        'Passageiro 2GO',
                        textAlign: TextAlign.center,
                        style: TwoGoTypography.bodyMedium.copyWith(
                          color: TwoGoColors.contentSecondary,
                        ),
                      ),
                      const SizedBox(height: TwoGoSpacing.xl),
                      TwoGoCard(
                        child: Column(
                          children: [
                            TwoGoListTile(
                              leading: const Icon(TwoGoIcons.profileOutlined),
                              title: 'Dados pessoais',
                              subtitle: 'E-mail e preferências de conta',
                              onTap: () {},
                            ),
                            const TwoGoDivider(),
                            TwoGoListTile(
                              leading: const Icon(
                                TwoGoIcons.notificationsOutlined,
                              ),
                              title: 'Notificações',
                              subtitle: 'Alertas e avisos de viagem',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: TwoGoSpacing.xl),
                      TwoGoButton(
                        text: 'Sair / Encerrar Sessão',
                        variant: TwoGoButtonVariant.secondary,
                        onPressed: () {
                          context.read<SessionCubit>().logout();
                        },
                      ),
                      const SizedBox(height: TwoGoSpacing.md),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
