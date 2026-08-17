import 'package:flutter/material.dart';
import 'package:twogo_authentication/twogo_authentication.dart';
import 'package:twogo_security/twogo_security.dart';
import 'package:twogo_session/twogo_session.dart';

import 'app.dart';

Future<void> bootstrap({required String environment}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = SecureTokenStorageImpl();
  final sessionCubit = SessionCubit(tokenStorage: tokenStorage);

  await sessionCubit.restoreSession();

  final authRepository = AuthRepositoryImpl(tokenStorage: tokenStorage);

  runApp(
    TwoGoApp(
      environment: environment,
      sessionCubit: sessionCubit,
      authRepository: authRepository,
    ),
  );
}
