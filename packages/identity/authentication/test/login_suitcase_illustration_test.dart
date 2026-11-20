import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_authentication/twogo_authentication.dart';

void main() {
  testWidgets('LoginSuitcaseIllustration loads packaged suitcase asset', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LoginSuitcaseIllustration()),
      ),
    );
    await tester.pump();

    final image = tester.widget<Image>(find.byType(Image));
    final provider = image.image;
    expect(provider, isA<AssetImage>());
    final asset = provider as AssetImage;
    expect(asset.assetName, LoginSuitcaseIllustration.assetPath);
    expect(asset.package, LoginSuitcaseIllustration.package);
  });

  testWidgets('EmailStepView shows suitcase when keyboard closed', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            viewInsets: EdgeInsets.zero,
          ),
          child: Scaffold(
            body: BlocProvider(
              create: (_) => AuthenticationBloc(
                requestOtpUseCase: RequestOtpUseCase(_NoopRepo()),
                verifyOtpUseCase: VerifyOtpUseCase(_NoopRepo()),
              ),
              child: const EmailStepView(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(LoginSuitcaseIllustration), findsOneWidget);
  });
}

class _NoopRepo implements AuthRepository {
  @override
  Future<void> requestOtp({required String email, String? purpose}) async {}

  @override
  Future<AuthTokensEntity> verifyOtp({
    required String email,
    required String code,
    String? purpose,
  }) async =>
      const AuthTokensEntity(accessToken: 'a', refreshToken: 'r');

  @override
  Future<UserEntity> signup({
    required String email,
    required String fullName,
    required String password,
  }) async =>
      const UserEntity(id: '1', email: 'a@b.c', fullName: 'T');

  @override
  Future<AuthTokensEntity> login({
    required String email,
    required String password,
  }) async =>
      const AuthTokensEntity(accessToken: 'a', refreshToken: 'r');

  @override
  Future<AuthTokensEntity> refreshTokens(String refreshToken) async =>
      const AuthTokensEntity(accessToken: 'a', refreshToken: 'r');

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
