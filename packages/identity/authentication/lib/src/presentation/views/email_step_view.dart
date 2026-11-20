import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_design_system/design_system.dart';
import '../bloc/authentication_bloc.dart';
import '../layout/auth_layout.dart';
import '../widgets/auth_social_login_row.dart';
import '../widgets/login_suitcase_illustration.dart';

class EmailStepView extends StatefulWidget {
  const EmailStepView({super.key});

  @override
  State<EmailStepView> createState() => _EmailStepViewState();
}

class _EmailStepViewState extends State<EmailStepView> {
  late final TextEditingController _controller;
  bool _showLocalFieldError = false;

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

  String? _resolveFieldError(AuthenticationState state) {
    if (state.emailFieldError != null) return state.emailFieldError;
    if (!_showLocalFieldError) return null;
    if (state.email.trim().isEmpty) return TwoGoErrorFeedback.requiredField;
    if (!state.isEmailValid) return TwoGoErrorFeedback.invalidField;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listenWhen: (previous, current) =>
          previous.failure != current.failure && current.failure != null,
      listener: (context, state) {
        final failure = state.failure;
        if (failure == null) return;
        TwoGoErrorFeedback.present(context, failure);
      },
      builder: (context, state) {
        final isLoading = state.step == AuthenticationStep.requestingOtp;
        final fieldError = _resolveFieldError(state);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TwoGoCenteredContent(
                maxWidth: AuthLayout.contentMaxWidth,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: TwoGoSpacing.xs),
                      Text(
                        'Entre ou cadastre-se\npara continuar',
                        textAlign: TextAlign.center,
                        style: TwoGoTypography.headlineLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: TwoGoSpacing.lg),

                      TwoGoTextField(
                        label: 'Entrar com e-mail',
                        hint: 'seu.email@gmail.com',
                        controller: _controller,
                        keyboardType: TextInputType.emailAddress,
                        errorText: fieldError,
                        prefix: const Icon(
                          Icons.email_outlined,
                          size: 20,
                          color: TwoGoColors.contentSecondary,
                        ),
                        onChanged: (val) {
                          if (_showLocalFieldError) {
                            setState(() => _showLocalFieldError = false);
                          }
                          context.read<AuthenticationBloc>().add(
                            EmailChanged(val),
                          );
                        },
                      ),

                      const SizedBox(height: TwoGoSpacing.md),

                      // Continuar → POST /auth/otp/request { email }
                      TwoGoButton(
                        text: 'Continuar',
                        loading: isLoading,
                        onPressed: isLoading
                            ? null
                            : () {
                                if (!state.isEmailValid) {
                                  setState(() => _showLocalFieldError = true);
                                  return;
                                }
                                context.read<AuthenticationBloc>().add(
                                  const OtpRequestSubmitted(),
                                );
                              },
                      ),

                      const SizedBox(height: TwoGoSpacing.md),

                      // Social: UI-only until Core supports FB/Google/Apple.
                      const AuthSocialLoginRow(
                        socialLoginFacebook: false,
                        socialLoginGoogle: false,
                        socialLoginApple: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Full-bleed footer matching design-login.png (hidden under keyboard).
            if (!isKeyboardOpen) const LoginSuitcaseIllustration(),
          ],
        );
      },
    );
  }
}
