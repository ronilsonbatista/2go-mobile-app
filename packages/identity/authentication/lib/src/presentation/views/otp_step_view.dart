import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_design_system/design_system.dart';
import '../bloc/authentication_bloc.dart';
import '../layout/auth_layout.dart';

class OtpStepView extends StatelessWidget {
  const OtpStepView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listenWhen: (previous, current) =>
          (previous.step != current.step) ||
          (previous.resentSuccess != current.resentSuccess &&
              current.resentSuccess) ||
          (previous.errorMessage != current.errorMessage &&
              current.errorMessage != null),
      listener: (context, state) {
        if (state.step == AuthenticationStep.otpInvalid ||
            state.codeError == 'AUTH_OTP_INVALID') {
          TwoGoSnackbar.show(
            context,
            message: 'Código inválido',
            variant: TwoGoSnackbarVariant.error,
          );
        } else if (state.resentSuccess) {
          TwoGoSnackbar.show(
            context,
            message: 'Código reenviado com sucesso',
            variant: TwoGoSnackbarVariant.success,
          );
        } else if (state.errorMessage != null &&
            state.step != AuthenticationStep.otpInvalid) {
          TwoGoSnackbar.show(
            context,
            message: state.errorMessage!,
            variant: TwoGoSnackbarVariant.error,
          );
        }
      },
      builder: (context, state) {
        final isVerifying = state.step == AuthenticationStep.verifyingOtp;
        final isResending = state.step == AuthenticationStep.resendingOtp;
        final hasError =
            state.step == AuthenticationStep.otpInvalid ||
            state.codeError == 'AUTH_OTP_INVALID';

        final formattedSeconds = state.countdownSeconds.toString().padLeft(
          2,
          '0',
        );

        return TwoGoCenteredContent(
          maxWidth: AuthLayout.contentMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: TwoGoSpacing.xl),

              // Title
              Text(
                'Insira o código\nenviado para o e-mail',
                textAlign: TextAlign.center,
                style: TwoGoTypography.headlineLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: TwoGoSpacing.xs),

              // Email Subtitle
              Text(
                state.email,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TwoGoTypography.bodyMedium.copyWith(
                  color: TwoGoColors.contentSecondary,
                ),
              ),

              const SizedBox(height: 28),

              // 6-digit OTP Field
              TwoGoOtpField(
                length: 6,
                value: state.otp,
                error: hasError,
                onChanged: (val) {
                  context.read<AuthenticationBloc>().add(OtpChanged(val));
                },
              ),

              // Inline Error Feedback (State 06)
              if (hasError) ...[
                const SizedBox(height: TwoGoSpacing.xs),
                const Center(
                  child: TwoGoInlineFeedback(
                    message: 'Verifique o código e tente novamente!',
                    variant: TwoGoInlineFeedbackVariant.error,
                  ),
                ),
              ],

              const SizedBox(height: AuthLayout.otpToButtonSpacing),

              // Continuar CTA Button
              TwoGoButton(
                text: 'Continuar',
                loading: isVerifying,
                onPressed: state.isOtpComplete && !isVerifying
                    ? () {
                        context.read<AuthenticationBloc>().add(
                          const OtpSubmitted(),
                        );
                      }
                    : null,
              ),

              const SizedBox(height: AuthLayout.buttonToResendSpacing),

              // Countdown / Resend Pill
              Center(
                child: isResending
                    ? const TwoGoPill(
                        label: 'Reenviando...',
                        variant: TwoGoPillVariant.neutral,
                      )
                    : (state.isCountdownActive && state.countdownSeconds > 0)
                    ? TwoGoPill(
                        label: 'Aguarde $formattedSeconds seg',
                        variant: TwoGoPillVariant.neutral,
                      )
                    : TwoGoPill(
                        label: 'Reenviar código',
                        variant: TwoGoPillVariant.outlined,
                        onTap: () {
                          context.read<AuthenticationBloc>().add(
                            const OtpResendRequested(),
                          );
                        },
                      ),
              ),

              const SizedBox(height: TwoGoSpacing.xl),
            ],
          ),
        );
      },
    );
  }
}
