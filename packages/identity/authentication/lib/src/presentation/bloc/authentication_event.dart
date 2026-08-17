import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

/// User typed/changed email input.
class EmailChanged extends AuthenticationEvent {
  const EmailChanged(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

/// User tapped "Continuar" on email screen to request OTP code.
class OtpRequestSubmitted extends AuthenticationEvent {
  const OtpRequestSubmitted();
}

/// User typed/edited OTP code digit(s).
class OtpChanged extends AuthenticationEvent {
  const OtpChanged(this.otp);

  final String otp;

  @override
  List<Object?> get props => [otp];
}

/// User tapped "Continuar" on OTP screen to verify code.
class OtpSubmitted extends AuthenticationEvent {
  const OtpSubmitted();
}

/// User tapped "Reenviar código" when countdown finished.
class OtpResendRequested extends AuthenticationEvent {
  const OtpResendRequested();
}

/// User tapped back button on OTP screen to return to email screen.
class BackToEmailRequested extends AuthenticationEvent {
  const BackToEmailRequested();
}

/// Timer ticker tick event.
class CountdownTicked extends AuthenticationEvent {
  const CountdownTicked(this.secondsRemaining);

  final int secondsRemaining;

  @override
  List<Object?> get props => [secondsRemaining];
}
