import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_authentication/twogo_authentication.dart';
import 'package:twogo_core/twogo_core.dart';

class FakeAuthRepository implements AuthRepository {
  bool shouldFailRequestOtp = false;
  bool shouldFailVerifyOtp = false;
  String? verifyFailureCode;
  String? verifyFailureMessage;

  @override
  Future<void> requestOtp({required String email, String? purpose}) async {
    if (shouldFailRequestOtp) {
      throw const NetworkFailure(message: 'Falha na conexão ao solicitar OTP');
    }
  }

  @override
  Future<AuthTokensEntity> verifyOtp({
    required String email,
    required String code,
    String? purpose,
  }) async {
    if (shouldFailVerifyOtp) {
      throw InvalidOtpFailure(
        message: verifyFailureMessage ?? 'Código inválido',
        code: verifyFailureCode ?? 'AUTH_OTP_INVALID',
      );
    }
    return const AuthTokensEntity(
      accessToken: 'test_access_token',
      refreshToken: 'test_refresh_token',
    );
  }

  @override
  Future<UserEntity> signup({
    required String email,
    required String fullName,
    required String password,
  }) async =>
      const UserEntity(id: '1', email: 'test@example.com', fullName: 'Test');

  @override
  Future<AuthTokensEntity> login({
    required String email,
    required String password,
  }) async =>
      const AuthTokensEntity(accessToken: 'access', refreshToken: 'refresh');

  @override
  Future<AuthTokensEntity> refreshTokens(String refreshToken) async =>
      const AuthTokensEntity(
        accessToken: 'new_access',
        refreshToken: 'new_refresh',
      );

  @override
  Future<UserEntity?> getCurrentUser() async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<void> logoutAll() async {}

  @override
  Future<void> forgotPassword({required String email}) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {}
}

void main() {
  group('AuthenticationBloc Unit Tests', () {
    late FakeAuthRepository repository;
    late RequestOtpUseCase requestOtpUseCase;
    late VerifyOtpUseCase verifyOtpUseCase;
    late AuthenticationBloc bloc;

    setUp(() {
      repository = FakeAuthRepository();
      requestOtpUseCase = RequestOtpUseCase(repository);
      verifyOtpUseCase = VerifyOtpUseCase(repository);
      bloc = AuthenticationBloc(
        requestOtpUseCase: requestOtpUseCase,
        verifyOtpUseCase: verifyOtpUseCase,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is emailEntry with empty values', () {
      expect(bloc.state.step, equals(AuthenticationStep.emailEntry));
      expect(bloc.state.email, isEmpty);
      expect(bloc.state.isEmailValid, isFalse);
    });

    test('EmailChanged updates email and isEmailValid', () async {
      bloc.add(const EmailChanged('invalid-email'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.email, equals('invalid-email'));
      expect(bloc.state.isEmailValid, isFalse);

      bloc.add(const EmailChanged('seu.email@gmail.com'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.email, equals('seu.email@gmail.com'));
      expect(bloc.state.isEmailValid, isTrue);
    });

    test(
      'OtpRequestSubmitted triggers requestOtp and moves to otpEntry with countdown 60',
      () async {
        bloc.add(const EmailChanged('seu.email@gmail.com'));
        await Future<void>.delayed(Duration.zero);

        bloc.add(const OtpRequestSubmitted());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.step, equals(AuthenticationStep.otpEntry));
        expect(bloc.state.isCountdownActive, isTrue);
        expect(bloc.state.countdownSeconds, equals(60));
      },
    );

    test('OtpChanged updates otp and isOtpComplete', () async {
      bloc.add(const OtpChanged('123'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.otp, equals('123'));
      expect(bloc.state.isOtpComplete, isFalse);

      bloc.add(const OtpChanged('123456'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.otp, equals('123456'));
      expect(bloc.state.isOtpComplete, isTrue);
    });

    test(
      'State 08 Editing After Error: OtpChanged clears codeError and inline errorMessage',
      () async {
        repository.shouldFailVerifyOtp = true;
        repository.verifyFailureCode = 'AUTH_OTP_INVALID';
        repository.verifyFailureMessage =
            'Verifique o código e tente novamente!';

        bloc.add(const EmailChanged('seu.email@gmail.com'));
        bloc.add(const OtpRequestSubmitted());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        bloc.add(const OtpChanged('123456'));
        bloc.add(const OtpSubmitted());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.step, equals(AuthenticationStep.otpInvalid));
        expect(bloc.state.codeError, equals('AUTH_OTP_INVALID'));
        expect(
          bloc.state.errorMessage,
          equals('Verifique o código e tente novamente!'),
        );

        // Editing digit clears error immediately!
        bloc.add(const OtpChanged('12345'));
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.step, equals(AuthenticationStep.otpEntry));
        expect(bloc.state.codeError, isNull);
        expect(bloc.state.errorMessage, isNull);
      },
    );

    test(
      'OtpSubmitted verifies OTP and transitions to authenticated state',
      () async {
        bloc.add(const EmailChanged('seu.email@gmail.com'));
        bloc.add(const OtpRequestSubmitted());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        bloc.add(const OtpChanged('123456'));
        bloc.add(const OtpSubmitted());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.step, equals(AuthenticationStep.authenticated));
        expect(bloc.state.tokens?.accessToken, equals('test_access_token'));
      },
    );

    test(
      'OtpResendRequested triggers request and restarts countdown',
      () async {
        bloc.add(const EmailChanged('seu.email@gmail.com'));
        bloc.add(const OtpRequestSubmitted());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        bloc.add(const OtpResendRequested());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.resentSuccess, isTrue);
        expect(bloc.state.countdownSeconds, equals(60));
      },
    );

    test(
      'BackToEmailRequested returns to emailEntry preserving email',
      () async {
        bloc.add(const EmailChanged('seu.email@gmail.com'));
        bloc.add(const OtpRequestSubmitted());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        bloc.add(const BackToEmailRequested());
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.step, equals(AuthenticationStep.emailEntry));
        expect(bloc.state.email, equals('seu.email@gmail.com'));
      },
    );
  });
}
