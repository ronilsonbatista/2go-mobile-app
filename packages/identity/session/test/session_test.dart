import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_security/twogo_security.dart';
import 'package:twogo_session/session.dart';
import 'package:twogo_test_support/test_support.dart';

void main() {
  group('SessionCubit Lifecycle Tests', () {
    late TokenStorage storage;
    late SessionCubit sessionCubit;

    setUp(() {
      storage = InMemoryTokenStorage();
      sessionCubit = SessionCubit(tokenStorage: storage);
    });

    tearDown(() {
      sessionCubit.close();
    });

    test(
      'restoreSession transitions to unauthenticated when storage is empty',
      () async {
        await sessionCubit.restoreSession();
        expect(sessionCubit.state.status, SessionStatus.unauthenticated);
        expect(sessionCubit.state.isAuthenticated, isFalse);
      },
    );

    test(
      'restoreSession transitions to authenticated when valid tokens exist',
      () async {
        const tokens = AuthTokens(
          accessToken: 'valid_acc',
          refreshToken: 'valid_ref',
        );
        await storage.saveTokens(tokens);

        await sessionCubit.restoreSession();

        expect(sessionCubit.state.status, SessionStatus.authenticated);
        expect(sessionCubit.state.isAuthenticated, isTrue);
        expect(sessionCubit.state.tokens, equals(tokens));
      },
    );

    test('onLogout clears tokens and sets unauthenticated', () async {
      const tokens = AuthTokens(
        accessToken: 'valid_acc',
        refreshToken: 'valid_ref',
      );
      await storage.saveTokens(tokens);
      await sessionCubit.restoreSession();

      await sessionCubit.onLogout();

      expect(sessionCubit.state.status, SessionStatus.unauthenticated);
      expect(await storage.readTokens(), isNull);
    });
  });
}
