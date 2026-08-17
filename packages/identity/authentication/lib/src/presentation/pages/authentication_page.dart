import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_design_system/design_system.dart';
import '../bloc/authentication_bloc.dart';
import '../views/email_step_view.dart';
import '../views/otp_step_view.dart';

class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        final isOtpStep =
            state.step == AuthenticationStep.otpEntry ||
            state.step == AuthenticationStep.verifyingOtp ||
            state.step == AuthenticationStep.otpInvalid ||
            state.step == AuthenticationStep.otpExpired ||
            state.step == AuthenticationStep.otpAttemptsExceeded ||
            state.step == AuthenticationStep.otpRateLimited ||
            state.step == AuthenticationStep.resendingOtp;

        return TwoGoKeyboardAwareScaffold(
          appBar: TwoGoAppBar(
            title: '',
            showBackButton: true,
            onBackPressed: () {
              if (isOtpStep) {
                context.read<AuthenticationBloc>().add(
                  const BackToEmailRequested(),
                );
              } else if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            },
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isOtpStep
                ? const OtpStepView(key: ValueKey('OtpStepView'))
                : const EmailStepView(key: ValueKey('EmailStepView')),
          ),
        );
      },
    );
  }
}
