import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_session/twogo_session.dart';

class AuthenticatedPlaceholderPage extends StatelessWidget {
  const AuthenticatedPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        final email = state.userId ?? 'passageiro@2go.com';

        return Scaffold(
          appBar: const TwoGoAppBar(
            title: 'Minha Conta 2GO',
            showBackButton: false,
          ),
          body: SafeArea(
            child: TwoGoCenteredContent(
              maxWidth: 390,
              child: Padding(
                padding: const EdgeInsets.all(TwoGoSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: TwoGoColors.brandLime,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: TwoGoColors.surfacePrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: TwoGoSpacing.lg),
                    Text(
                      'Sessão Ativa!',
                      textAlign: TextAlign.center,
                      style: TwoGoTypography.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: TwoGoSpacing.xs),
                    Text(
                      'Você está autenticado no 2GO Mobile com a sua conta oficial.',
                      textAlign: TextAlign.center,
                      style: TwoGoTypography.bodyMedium.copyWith(
                        color: TwoGoColors.contentSecondary,
                      ),
                    ),
                    const SizedBox(height: TwoGoSpacing.xl),
                    TwoGoCard(
                      child: Padding(
                        padding: const EdgeInsets.all(TwoGoSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IDENTIFICAÇÃO DA SESSÃO',
                              style: TwoGoTypography.labelSmall.copyWith(
                                color: TwoGoColors.contentSecondary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: TwoGoSpacing.xs),
                            Text(
                              email,
                              style: TwoGoTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: TwoGoSpacing.sm),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: TwoGoColors.feedbackSuccess,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: TwoGoSpacing.xs),
                                Text(
                                  'Token JWT Válido & Protegido',
                                  style: TwoGoTypography.labelSmall.copyWith(
                                    color: TwoGoColors.feedbackSuccess,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: TwoGoSpacing.xxl),
                    TwoGoButton(
                      text: 'Sair / Encerrar Sessão',
                      variant: TwoGoButtonVariant.secondary,
                      onPressed: () {
                        context.read<SessionCubit>().logout();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
