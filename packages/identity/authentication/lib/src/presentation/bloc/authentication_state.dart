import 'package:equatable/equatable.dart';
import 'package:twogo_core/twogo_core.dart';
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
    this.failure,
    this.fieldErrors = const {},
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
  final AppFailure? failure;
  final Map<String, String> fieldErrors;
  final bool resentSuccess;
  final AuthTokensEntity? tokens;

  String? get emailFieldError => fieldErrors['email'];

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
    AppFailure? failure,
    Map<String, String>? fieldErrors,
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
      failure: clearErrors ? null : (failure ?? this.failure),
      fieldErrors: clearErrors ? const {} : (fieldErrors ?? this.fieldErrors),
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
    failure,
    fieldErrors,
    resentSuccess,
    tokens,
  ];
}
