import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_tokens_entity.dart';

enum AuthenticationStep {
  emailEntry,
  requestingOtp,
  otpEntry,
  verifyingOtp,
  otpInvalid,
  otpExpired,
  otpAttemptsExceeded,
  otpRateLimited,
  resendingOtp,
  authenticated,
}

class AuthenticationState extends Equatable {
  const AuthenticationState({
    this.step = AuthenticationStep.emailEntry,
    this.email = '',
    this.isEmailValid = false,
    this.otp = '',
    this.isOtpComplete = false,
    this.countdownSeconds = 60,
    this.isCountdownActive = false,
    this.errorMessage,
    this.codeError,
    this.resentSuccess = false,
    this.tokens,
  });

  final AuthenticationStep step;
  final String email;
  final bool isEmailValid;
  final String otp;
  final bool isOtpComplete;
  final int countdownSeconds;
  final bool isCountdownActive;
  final String? errorMessage;
  final String? codeError;
  final bool resentSuccess;
  final AuthTokensEntity? tokens;

  AuthenticationState copyWith({
    AuthenticationStep? step,
    String? email,
    bool? isEmailValid,
    String? otp,
    bool? isOtpComplete,
    int? countdownSeconds,
    bool? isCountdownActive,
    String? errorMessage,
    String? codeError,
    bool? resentSuccess,
    AuthTokensEntity? tokens,
    bool clearErrors = false,
  }) {
    return AuthenticationState(
      step: step ?? this.step,
      email: email ?? this.email,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      otp: otp ?? this.otp,
      isOtpComplete: isOtpComplete ?? this.isOtpComplete,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      isCountdownActive: isCountdownActive ?? this.isCountdownActive,
      errorMessage: clearErrors ? null : (errorMessage ?? this.errorMessage),
      codeError: clearErrors ? null : (codeError ?? this.codeError),
      resentSuccess: resentSuccess ?? this.resentSuccess,
      tokens: tokens ?? this.tokens,
    );
  }

  @override
  List<Object?> get props => [
    step,
    email,
    isEmailValid,
    otp,
    isOtpComplete,
    countdownSeconds,
    isCountdownActive,
    errorMessage,
    codeError,
    resentSuccess,
    tokens,
  ];
}
