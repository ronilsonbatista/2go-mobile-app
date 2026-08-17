import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_authentication/twogo_authentication.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_design_system/design_system.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<void> requestOtp({required String email, String? purpose}) async {}

  @override
  Future<AuthTokensEntity> verifyOtp({
    required String email,
    required String code,
    String? purpose,
  }) async {
    if (code == '128434') {
      throw const InvalidOtpFailure(
        message: 'Verifique o código e tente novamente!',
        code: 'AUTH_OTP_INVALID',
      );
    }
    return const AuthTokensEntity(
      accessToken: 'access',
      refreshToken: 'refresh',
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

Widget buildTestableWidget(
  AuthenticationBloc bloc, {
  Size size = const Size(390, 844),
}) {
  return MaterialApp(
    theme: TwoGoTheme.light,
    home: MediaQuery(
      data: MediaQueryData(
        size: size,
        padding: const EdgeInsets.only(top: 44, bottom: 34),
      ),
      child: Scaffold(
        body: BlocProvider<AuthenticationBloc>.value(
          value: bloc,
          child: const AuthenticationPage(),
        ),
      ),
    ),
  );
}

void main() {
  group(
    'Authentication Visual Reference Golden Tests (390 x 844 canonical viewport)',
    () {
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

      testWidgets('01_auth_email_empty_390x844', (tester) async {
        await tester.pumpWidget(buildTestableWidget(bloc));
        expect(
          find.text('Entre ou cadastre-se\npara continuar'),
          findsOneWidget,
        );
        expect(find.text('Entrar com e-mail'), findsOneWidget);
        expect(find.text('Continuar'), findsOneWidget);
        expect(find.text('ou continue com'), findsOneWidget);
      });

      testWidgets('02_auth_email_valid_390x844', (tester) async {
        bloc.add(const EmailChanged('seu.email@gmail.com'));
        await tester.pumpWidget(buildTestableWidget(bloc));
        await tester.pump();

        expect(find.text('seu.email@gmail.com'), findsAtLeastNWidgets(1));
        expect(bloc.state.isEmailValid, isTrue);
      });

      testWidgets('03_auth_otp_empty_countdown_390x844', (tester) async {
        bloc.add(const EmailChanged('seu.email@gmail.com'));
        bloc.add(const OtpRequestSubmitted());
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        });

        await tester.pumpWidget(buildTestableWidget(bloc));
        await tester.pump();

        expect(
          find.text('Insira o código\nenviado para o e-mail'),
          findsOneWidget,
        );
        expect(find.text('seu.email@gmail.com'), findsOneWidget);
        expect(find.text('Aguarde 60 seg'), findsOneWidget);
      });

      testWidgets('04_auth_otp_complete_390x844', (tester) async {
        bloc.add(const EmailChanged('seu.email@gmail.com'));
        bloc.add(const OtpRequestSubmitted());
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        });

        await tester.pumpWidget(buildTestableWidget(bloc));
        await tester.pump();

        bloc.add(const OtpChanged('328434'));
        await tester.pump();

        expect(bloc.state.isOtpComplete, isTrue);
      });

      testWidgets('05_auth_otp_resend_enabled_390x844', (tester) async {
        bloc.add(const EmailChanged('seu.email@gmail.com'));
        bloc.add(const OtpRequestSubmitted());
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        });

        await tester.pumpWidget(buildTestableWidget(bloc));
        await tester.pump();

        // Back to email cancels the periodic timer stream cleanly
        bloc.add(const BackToEmailRequested());
        await tester.pump();

        // Re-trigger with initial 0 countdown for resend test
        bloc.add(const CountdownTicked(0));
        await tester.pump();

        expect(bloc.state.countdownSeconds, 0);
        expect(bloc.state.isCountdownActive, isFalse);
      });

      testWidgets('06_auth_otp_invalid_390x844', (tester) async {
        bloc.add(const EmailChanged('seu.email@gmail.com'));
        bloc.add(const OtpRequestSubmitted());
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        });

        await tester.pumpWidget(buildTestableWidget(bloc));
        await tester.pump();

        bloc.add(const OtpChanged('128434'));
        bloc.add(const OtpSubmitted());
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        });
        await tester.pump();

        expect(
          find.text('Verifique o código e tente novamente!'),
          findsOneWidget,
        );
        expect(find.text('Código inválido'), findsOneWidget);
      });

      testWidgets('07_auth_otp_resent_success_390x844', (tester) async {
        bloc.add(const EmailChanged('seu.email@gmail.com'));
        bloc.add(const OtpRequestSubmitted());
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        });

        await tester.pumpWidget(buildTestableWidget(bloc));
        await tester.pump();

        bloc.add(const OtpResendRequested());
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        });
        await tester.pump();

        expect(find.text('Código reenviado com sucesso'), findsOneWidget);
      });

      testWidgets('08_auth_otp_editing_after_error_390x844', (tester) async {
        bloc.add(const EmailChanged('seu.email@gmail.com'));
        bloc.add(const OtpRequestSubmitted());
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        });

        await tester.pumpWidget(buildTestableWidget(bloc));
        await tester.pump();

        bloc.add(const OtpChanged('128434'));
        bloc.add(const OtpSubmitted());
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        });
        await tester.pump();

        expect(
          find.text('Verifique o código e tente novamente!'),
          findsOneWidget,
        );

        // User types/edits digit -> clears error border & codeError
        bloc.add(const OtpChanged('28434'));
        await tester.pump();

        expect(bloc.state.codeError, isNull);
      });
    },
  );
}
