import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_core/twogo_core.dart';
import '../../domain/usecases/request_otp_use_case.dart';
import '../../domain/usecases/verify_otp_use_case.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';

export 'authentication_event.dart';
export 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required RequestOtpUseCase requestOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
  }) : _requestOtpUseCase = requestOtpUseCase,
       _verifyOtpUseCase = verifyOtpUseCase,
       super(const AuthenticationState()) {
    on<EmailChanged>(_onEmailChanged);
    on<OtpRequestSubmitted>(_onOtpRequestSubmitted);
    on<OtpChanged>(_onOtpChanged);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<OtpResendRequested>(_onOtpResendRequested);
    on<BackToEmailRequested>(_onBackToEmailRequested);
    on<CountdownTicked>(_onCountdownTicked);
  }

  final RequestOtpUseCase _requestOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  StreamSubscription<int>? _timerSubscription;

  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  void _onEmailChanged(EmailChanged event, Emitter<AuthenticationState> emit) {
    final email = event.email.trim();
    final isValid = email.isNotEmpty && _emailRegExp.hasMatch(email);
    emit(
      state.copyWith(email: email, isEmailValid: isValid, clearErrors: true),
    );
  }

  Future<void> _onOtpRequestSubmitted(
    OtpRequestSubmitted event,
    Emitter<AuthenticationState> emit,
  ) async {
    if (!state.isEmailValid) return;

    emit(
      state.copyWith(step: AuthenticationStep.requestingOtp, clearErrors: true),
    );

    try {
      await _requestOtpUseCase(email: state.email);
      _startTimer(60);
      emit(
        state.copyWith(
          step: AuthenticationStep.otpEntry,
          otp: '',
          isOtpComplete: false,
          countdownSeconds: 60,
          isCountdownActive: true,
          resentSuccess: false,
        ),
      );
    } on AppFailure catch (failure) {
      emit(
        state.copyWith(
          step: AuthenticationStep.emailEntry,
          errorMessage: failure.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          step: AuthenticationStep.emailEntry,
          errorMessage: 'Falha ao solicitar código. Tente novamente.',
        ),
      );
    }
  }

  void _onOtpChanged(OtpChanged event, Emitter<AuthenticationState> emit) {
    final otp = event.otp.trim();
    final isComplete = otp.length == 6;

    // RULE 30/67: State 08 (Editing after error)
    // As soon as user edits any digit, clear error border & inline message
    emit(
      state.copyWith(
        step: AuthenticationStep.otpEntry,
        otp: otp,
        isOtpComplete: isComplete,
        clearErrors: true,
        resentSuccess: false,
      ),
    );
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<AuthenticationState> emit,
  ) async {
    if (!state.isOtpComplete) return;

    emit(
      state.copyWith(step: AuthenticationStep.verifyingOtp, clearErrors: true),
    );

    try {
      final tokens = await _verifyOtpUseCase(
        email: state.email,
        code: state.otp,
      );
      _cancelTimer();
      emit(
        state.copyWith(
          step: AuthenticationStep.authenticated,
          tokens: tokens,
          isCountdownActive: false,
        ),
      );
    } on AppFailure catch (failure) {
      if (failure.code == 'AUTH_OTP_INVALID') {
        emit(
          state.copyWith(
            step: AuthenticationStep.otpInvalid,
            codeError: 'AUTH_OTP_INVALID',
            errorMessage: 'Verifique o código e tente novamente!',
          ),
        );
      } else if (failure.code == 'AUTH_OTP_EXPIRED') {
        emit(
          state.copyWith(
            step: AuthenticationStep.otpExpired,
            errorMessage: 'Código expirado. Solicite um novo código.',
          ),
        );
      } else if (failure.code == 'AUTH_OTP_TOO_MANY_ATTEMPTS') {
        emit(
          state.copyWith(
            step: AuthenticationStep.otpAttemptsExceeded,
            errorMessage:
                'Limite de tentativas excedido. Solicite um novo código.',
          ),
        );
      } else if (failure.code == 'AUTH_OTP_RATE_LIMITED') {
        emit(
          state.copyWith(
            step: AuthenticationStep.otpRateLimited,
            errorMessage: 'Aguarde antes de solicitar um novo código.',
          ),
        );
      } else {
        emit(
          state.copyWith(
            step: AuthenticationStep.otpInvalid,
            errorMessage: failure.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          step: AuthenticationStep.otpInvalid,
          errorMessage: 'Falha ao verificar código. Tente novamente.',
        ),
      );
    }
  }

  Future<void> _onOtpResendRequested(
    OtpResendRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(
      state.copyWith(step: AuthenticationStep.resendingOtp, clearErrors: true),
    );

    try {
      await _requestOtpUseCase(email: state.email);
      _startTimer(60);
      emit(
        state.copyWith(
          step: AuthenticationStep.otpEntry,
          otp: '',
          isOtpComplete: false,
          countdownSeconds: 60,
          isCountdownActive: true,
          resentSuccess: true,
          clearErrors: true,
        ),
      );
    } on AppFailure catch (failure) {
      emit(
        state.copyWith(
          step: AuthenticationStep.otpEntry,
          errorMessage: failure.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          step: AuthenticationStep.otpEntry,
          errorMessage: 'Falha ao reenviar código.',
        ),
      );
    }
  }

  void _onBackToEmailRequested(
    BackToEmailRequested event,
    Emitter<AuthenticationState> emit,
  ) {
    _cancelTimer();
    emit(
      state.copyWith(
        step: AuthenticationStep.emailEntry,
        otp: '',
        isOtpComplete: false,
        isCountdownActive: false,
        clearErrors: true,
        resentSuccess: false,
      ),
    );
  }

  void _onCountdownTicked(
    CountdownTicked event,
    Emitter<AuthenticationState> emit,
  ) {
    final remaining = event.secondsRemaining;
    if (remaining <= 0) {
      _cancelTimer();
    }
    emit(
      state.copyWith(
        countdownSeconds: remaining < 0 ? 0 : remaining,
        isCountdownActive: remaining > 0,
      ),
    );
  }

  void _startTimer(int seconds) {
    _cancelTimer();
    _timerSubscription =
        Stream.periodic(
          const Duration(seconds: 1),
          (x) => seconds - x - 1,
        ).take(seconds).listen((remaining) {
          add(CountdownTicked(remaining));
        });
  }

  void _cancelTimer() {
    _timerSubscription?.cancel();
    _timerSubscription = null;
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}
