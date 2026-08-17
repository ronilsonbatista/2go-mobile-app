import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_design_system/design_system.dart';
import '../bloc/authentication_bloc.dart';
import '../layout/auth_layout.dart';
import '../widgets/auth_social_login_row.dart';

class EmailStepView extends StatefulWidget {
  const EmailStepView({super.key});

  @override
  State<EmailStepView> createState() => _EmailStepViewState();
}

class _EmailStepViewState extends State<EmailStepView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final currentEmail = context.read<AuthenticationBloc>().state.email;
    _controller = TextEditingController(text: currentEmail);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        if (state.errorMessage != null) {
          TwoGoSnackbar.show(
            context,
            message: state.errorMessage!,
            variant: TwoGoSnackbarVariant.error,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.step == AuthenticationStep.requestingOtp;

        return TwoGoCenteredContent(
          maxWidth: AuthLayout.contentMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: TwoGoSpacing.xs),
              // Title
              Text(
                'Entre ou cadastre-se\npara continuar',
                textAlign: TextAlign.center,
                style: TwoGoTypography.headlineLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: TwoGoSpacing.lg),

              // Email Input Label & Field
              TwoGoTextField(
                label: 'Entrar com e-mail',
                hint: 'seu.email@gmail.com',
                controller: _controller,
                keyboardType: TextInputType.emailAddress,
                prefix: const Icon(
                  Icons.email_outlined,
                  size: 20,
                  color: TwoGoColors.contentSecondary,
                ),
                onChanged: (val) {
                  context.read<AuthenticationBloc>().add(EmailChanged(val));
                },
              ),

              const SizedBox(height: TwoGoSpacing.md),

              // Continuar CTA Button
              TwoGoButton(
                text: 'Continuar',
                loading: isLoading,
                onPressed: state.isEmailValid && !isLoading
                    ? () {
                        context.read<AuthenticationBloc>().add(
                          const OtpRequestSubmitted(),
                        );
                      }
                    : null,
              ),

              const SizedBox(height: TwoGoSpacing.md),

              // Social Login Row
              const AuthSocialLoginRow(),

              const SizedBox(height: TwoGoSpacing.sm),

              // Bottom Illustration Placeholder (collapses smoothly when keyboard opens)
              if (!isKeyboardOpen) ...[
                const _TravelIllustrationSlot(),
                const SizedBox(height: TwoGoSpacing.xs),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TravelIllustrationSlot extends StatelessWidget {
  const _TravelIllustrationSlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.xs),
      decoration: BoxDecoration(
        color: TwoGoColors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(TwoGoRadius.medium),
        border: Border.all(color: TwoGoColors.borderDefault),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.luggage_outlined,
              size: 18,
              color: TwoGoColors.contentSecondary,
            ),
            const SizedBox(width: TwoGoSpacing.xs),
            Flexible(
              child: Text(
                'AUTH ILLUSTRATION PENDING',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TwoGoTypography.labelSmall.copyWith(
                  color: TwoGoColors.contentSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
